import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPagoPage extends StatefulWidget {
  final String prestamoId;
  final double balanceDisponible;

  const AddPagoPage({
    super.key,
    required this.prestamoId,
    required this.balanceDisponible,
  });

  @override
  State<AddPagoPage> createState() => _AddPagoPageState();
}

class _AddPagoPageState extends State<AddPagoPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _montoController = TextEditingController();
  String tipoPago = 'cuota';

  Future<void> registrarPago() async {
    final monto = double.tryParse(_montoController.text);

    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido.')),
      );
      return;
    }

    if (monto > widget.balanceDisponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El monto no puede exceder el balance disponible.')),
      );
      return;
    }

    try {
      await _supabase.from('pagos').insert({
        'prestamo_id': widget.prestamoId,
        'monto': monto,
        'tipo_pago': tipoPago,
      });

      await _supabase.from('Prestamos').update({
        'balance_disponible': widget.balanceDisponible - monto,
      }).eq('id', widget.prestamoId);

      Navigator.pushNamed(context, '/pagos');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago registrado correctamente')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar pago: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _montoController,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tipoPago,
                    onChanged: (value) => setState(() => tipoPago = value!),
                    items: const [
                      DropdownMenuItem(value: 'cuota', child: Text('Pago de Cuota')),
                      DropdownMenuItem(value: 'abono', child: Text('Abono')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Tipo de Pago',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: registrarPago,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Registrar Pago'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

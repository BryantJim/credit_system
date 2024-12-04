import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPagoPage extends StatefulWidget {
  final String prestamoId;
  final double balanceDisponible;
  final double montoCuota;

  const AddPagoPage({
    super.key,
    required this.prestamoId,
    required this.balanceDisponible,
    required this.montoCuota,
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
      appBar: AppBar(title: const Text('Registrar Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (tipoPago == 'cuota')
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Valor de la cuota: \$${widget.montoCuota.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            if (tipoPago == 'abono')
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Balance disponible: \$${widget.balanceDisponible.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            TextField(
              controller: _montoController,
              decoration: InputDecoration(
                labelText: 'Monto',
                hintText: tipoPago == 'cuota'
                    ? 'Monto sugerido: ${widget.montoCuota.toStringAsFixed(2)}'
                    : 'Monto sugerido: ${widget.balanceDisponible.toStringAsFixed(2)}',
              ),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: tipoPago,
              onChanged: (value) => setState(() => tipoPago = value!),
              items: const [
                DropdownMenuItem(value: 'cuota', child: Text('Pago de Cuota')),
                DropdownMenuItem(value: 'abono', child: Text('Abono')),
              ],
              decoration: const InputDecoration(labelText: 'Tipo de Pago'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: registrarPago,
              child: const Text('Registrar Pago'),
            ),
          ],
        ),
      ),
    );
  }
}

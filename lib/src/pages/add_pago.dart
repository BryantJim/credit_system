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
      // Registrar el pago en la tabla `pagos`
      await _supabase.from('pagos').insert({
        'prestamo_id': widget.prestamoId,
        'monto': monto,
        'tipo_pago': tipoPago,
      });

      // Actualizar el balance en la tabla `prestamos`
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
            TextField(
              controller: _montoController,
              decoration: const InputDecoration(labelText: 'Monto'),
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

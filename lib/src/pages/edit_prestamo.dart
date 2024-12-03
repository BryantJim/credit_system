import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPrestamosPage extends StatefulWidget {
  final Map<String, dynamic> credit;

  const EditPrestamosPage({super.key, required this.credit});

  @override
  State<EditPrestamosPage> createState() => _EditPrestamosPageState();
}

class _EditPrestamosPageState extends State<EditPrestamosPage> {
  final _supabase = Supabase.instance.client;

  late TextEditingController _montoController;
  late TextEditingController _plazoController;
  late TextEditingController _tasaController;

  late TextEditingController _totalInteresController;
  late TextEditingController _totalPrestamoController;
  late TextEditingController _montoCuotasController;

  @override
  void initState() {
    super.initState();

    _montoController =
        TextEditingController(text: widget.credit['monto'].toString());
    _plazoController =
        TextEditingController(text: widget.credit['plazo'].toString());
    _tasaController =
        TextEditingController(text: widget.credit['tasa_interes'].toString());
    _totalInteresController =
        TextEditingController(text: widget.credit['total_interes'].toString());
    _totalPrestamoController =
        TextEditingController(text: widget.credit['total_prestamo'].toString());
    _montoCuotasController =
        TextEditingController(text: widget.credit['monto_cuotas'].toString());

    _montoController.addListener(_calculateValues);
    _plazoController.addListener(_calculateValues);
    _tasaController.addListener(_calculateValues);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _plazoController.dispose();
    _tasaController.dispose();
    _totalInteresController.dispose();
    _totalPrestamoController.dispose();
    _montoCuotasController.dispose();
    super.dispose();
  }

  void _calculateValues() {
    final monto = double.tryParse(_montoController.text) ?? 0;
    final plazo = int.tryParse(_plazoController.text) ?? 0;
    final tasaInteres = double.tryParse(_tasaController.text) ?? 0;

    final interesMensual = monto * (tasaInteres / 100);
    final totalInteresCalculado = interesMensual * plazo;
    final totalPrestamoCalculado = monto + totalInteresCalculado;
    final montoCuotaCalculada = plazo > 0 ? totalPrestamoCalculado / plazo : 0;

    _totalInteresController.text = totalInteresCalculado.toStringAsFixed(2);
    _totalPrestamoController.text = totalPrestamoCalculado.toStringAsFixed(2);
    _montoCuotasController.text = montoCuotaCalculada.toStringAsFixed(2);
  }

  Future<void> updatePrestamo() async {
    try {
      await _supabase.from('Prestamos').update({
        'monto': double.parse(_montoController.text),
        'plazo': int.parse(_plazoController.text),
        'tasa_interes': double.parse(_tasaController.text),
        'monto_cuotas': double.parse(_montoCuotasController.text),
        'total_interes': double.parse(_totalInteresController.text),
        'balance_disponible': double.parse(_totalPrestamoController.text),
        'total_prestamo': double.parse(_totalPrestamoController.text),
      }).eq('id', widget.credit['id']);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préstamo actualizado correctamente')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar préstamo: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Préstamo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _montoController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _plazoController,
                decoration:
                    const InputDecoration(labelText: 'Plazo (en meses)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _tasaController,
                decoration:
                    const InputDecoration(labelText: 'Tasa de Interés (%)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _totalInteresController,
                decoration: const InputDecoration(labelText: 'Total Interés'),
                readOnly: true,
              ),
              TextField(
                controller: _totalPrestamoController,
                decoration: const InputDecoration(labelText: 'Total Préstamo'),
                readOnly: true,
              ),
              TextField(
                controller: _montoCuotasController,
                decoration: const InputDecoration(labelText: 'Monto Cuotas'),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: updatePrestamo,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

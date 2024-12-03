import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPrestamoPage extends StatefulWidget {
  const AddPrestamoPage({super.key});

  @override
  State<AddPrestamoPage> createState() => _AddPrestamoPageState();
}

class _AddPrestamoPageState extends State<AddPrestamoPage> {
  final _supabase = Supabase.instance.client;

  final _montoController = TextEditingController();
  final _plazoController = TextEditingController();
  final _tasaController = TextEditingController();

  final _totalInteresController = TextEditingController();
  final _totalPrestamoController = TextEditingController();
  final _montoCuotasController = TextEditingController();

  String? selectedClienteId;
  List<dynamic> clientes = [];

  @override
  void initState() {
    super.initState();
    fetchClientes();

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

  Future<void> fetchClientes() async {
    try {
      final response =
          await _supabase.from('Clientes').select('id, nombre, apellido');
      setState(() {
        clientes = response;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener clientes: $error')),
      );
    }
  }

  void _calculateValues() {
    final monto = double.tryParse(_montoController.text) ?? 0;
    final plazo = int.tryParse(_plazoController.text) ?? 0;
    final tasaInteres = double.tryParse(_tasaController.text) ?? 0;

    final interesMensual = monto * (tasaInteres / 100);
    final totalInteresCalculado = interesMensual * plazo;
    final totalPrestamoCalculado = monto + totalInteresCalculado;
    final double montoCuotaCalculada =
        plazo > 0 ? totalPrestamoCalculado / plazo : 0;

    _totalInteresController.text = totalInteresCalculado.toStringAsFixed(2);
    _totalPrestamoController.text = totalPrestamoCalculado.toStringAsFixed(2);
    _montoCuotasController.text = montoCuotaCalculada.toStringAsFixed(2);
  }

  Future<void> addPrestamo() async {
    if (selectedClienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un cliente.')),
      );
      return;
    }

    try {
      await _supabase.from('Prestamos').insert({
        'cliente_id': selectedClienteId,
        'monto': double.parse(_montoController.text),
        'plazo': int.parse(_plazoController.text),
        'tasa_interes': double.parse(_tasaController.text),
        'fecha_inicio': DateTime.now().toIso8601String(),
        'estado': 'activo',
        'monto_cuotas': double.parse(_montoCuotasController.text),
        'total_interes': double.parse(_totalInteresController.text),
        'balance_disponible': double.parse(_totalPrestamoController.text),
        'total_prestamo': double.parse(_totalPrestamoController.text),
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Préstamo agregado correctamente')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar préstamo: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Préstamo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedClienteId,
                onChanged: (value) => setState(() => selectedClienteId = value),
                items: clientes
                    .map((cliente) => DropdownMenuItem<String>(
                          value: cliente['id'],
                          child: Text(
                              '${cliente['nombre']} ${cliente['apellido']}'),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Cliente'),
              ),
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
              // Campos de solo lectura
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
                onPressed: addPrestamo,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

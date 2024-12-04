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
    appBar: AppBar(
      title: const Text('Agregar Préstamo'),
      centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedClienteId,
                      onChanged: (value) => setState(() => selectedClienteId = value),
                      items: clientes
                          .map((cliente) => DropdownMenuItem<String>(
                                value: cliente['id'],
                                child: Text(
                                  '${cliente['nombre']} ${cliente['apellido']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Cliente',
                        labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField('Monto', _montoController, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    _buildTextField('Plazo (en meses)', _plazoController, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    _buildTextField('Tasa de Interés (%)', _tasaController, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    // Campos de solo lectura
                    _buildTextField('Total Interés', _totalInteresController, readOnly: true),
                    const SizedBox(height: 20),
                    _buildTextField('Total Préstamo', _totalPrestamoController, readOnly: true),
                    const SizedBox(height: 20),
                    _buildTextField('Monto Cuotas', _montoCuotasController, readOnly: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: addPrestamo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blue.shade600, // Color del fondo
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white, // Texto blanco
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Widget para TextField reutilizable
Widget _buildTextField(String label, TextEditingController controller, 
    {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    readOnly: readOnly,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      fillColor: Colors.grey.shade100,
      filled: true, // Fondo suave
    ),
  );
}

}

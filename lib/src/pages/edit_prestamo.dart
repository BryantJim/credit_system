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
    appBar: AppBar(
      title: const Text('Editar Préstamo'),
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
                      onPressed: updatePrestamo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blue.shade600, // Color del fondo
                      ),
                      child: const Text(
                        'Guardar Cambios',
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

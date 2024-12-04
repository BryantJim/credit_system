import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddClientePage extends StatefulWidget {
  const AddClientePage({super.key});

  @override
  State<AddClientePage> createState() => _AddClientePageState();
}

class _AddClientePageState extends State<AddClientePage> {
  final _supabase = Supabase.instance.client;

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();

  Future<void> addClient() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró un usuario autenticado.')),
      );
      return;
    }

    try {
      await _supabase.from('Clientes').insert({
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'email': _emailController.text,
        'telefono': _telefonoController.text,
        'direccion': _direccionController.text,
        'fecha_nacimiento': _fechaNacimientoController.text,
        'usuario_id': userId,
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente agregado correctamente')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar cliente: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Agregar Cliente'),
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
                    _buildTextField('Nombre', _nombreController),
                    const SizedBox(height: 20),
                    _buildTextField('Apellido', _apellidoController),
                    const SizedBox(height: 20),
                    _buildTextField('Fecha de Nacimiento (YYYY-MM-DD)', 
                        _fechaNacimientoController,
                        keyboardType: TextInputType.datetime),
                    const SizedBox(height: 20),
                    _buildTextField('Email', _emailController, 
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildTextField('Teléfono', _telefonoController, 
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),
                    _buildTextField('Dirección', _direccionController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: addClient,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.blue.shade600, 
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTextField(String label, TextEditingController controller, 
    {TextInputType keyboardType = TextInputType.text}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
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
      filled: true,
    ),
  );
}

}

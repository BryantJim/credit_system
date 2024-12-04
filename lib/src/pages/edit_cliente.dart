import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditClientePage extends StatefulWidget {
  final Map<String, dynamic> client;

  const EditClientePage({super.key, required this.client});

  @override
  State<EditClientePage> createState() => _EditClientePageState();
}

class _EditClientePageState extends State<EditClientePage> {
  final _supabase = Supabase.instance.client;

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(text: widget.client['nombre']);
    _apellidoController =
        TextEditingController(text: widget.client['apellido']);
    _fechaNacimientoController =
        TextEditingController(text: widget.client['fecha_nacimiento']);
    _emailController = TextEditingController(text: widget.client['email']);
    _telefonoController =
        TextEditingController(text: widget.client['telefono']);
    _direccionController =
        TextEditingController(text: widget.client['direccion']);
  }

  Future<void> updateClient() async {
    try {
      await _supabase.from('Clientes').update({
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'fecha_nacimiento': _fechaNacimientoController.text,
        'email': _emailController.text,
        'telefono': _telefonoController.text,
        'direccion': _direccionController.text,
      }).eq('id', widget.client['id']);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente actualizado correctamente!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error actualizando el cliente: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                  onPressed: updateClient,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
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
    );
  }

// Widget para TextField reutilizable
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        fillColor: Colors.grey.shade100,
        filled: true, // Fondo suave
      ),
    );
  }
  
}

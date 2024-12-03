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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _fechaNacimientoController,
                decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Telefono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: updateClient,
                  child: const Text('Guardar Cambios')),
            ],
          ),
        ),
      ),
    );
  }
}

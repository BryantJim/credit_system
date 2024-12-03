import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectClienteWidget extends StatelessWidget {
  final Function(String) onClienteSelected;

  const SelectClienteWidget({super.key, required this.onClienteSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Seleccionar Cliente'), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client.from('Clientes').select(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay clientes registrados.'));
          }

          final clientes = snapshot.data!;
          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return ListTile(
                title: Text('${cliente['nombre']} ${cliente['apellido']}'),
                subtitle: Text('Email: ${cliente['email']}'),
                onTap: () => onClienteSelected(cliente['id']),
              );
            },
          );
        },
      ),
    );
  }
}

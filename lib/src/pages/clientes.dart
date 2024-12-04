import 'package:credit_system/src/pages/edit_cliente.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _supabase.from('Clientes').select();

      setState(() {
        clients = response;
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error obteniendo los clientes: $error')));
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _supabase.from('Clientes').delete().eq('id', id);
      fetchClients();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado correctamente!')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando al cliente: $error')));
    }
  }

  void _showDeleteConfirmationDialog(String clientId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este cliente? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              deleteClient(clientId); // Elimina el cliente
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/clientes/add')
                  .then((_) => fetchClients());
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4, // Sombra para que resalte
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(16.0), // Más espacio interno
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          client['nombre']!.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ), // Avatar con inicial
                      title: Text(
                        '${client['nombre']} ${client['apellido']}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Email: ${client['email']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        onPressed: () =>
                            _showDeleteConfirmationDialog(client['id']),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditClientePage(client: client),
                          ),
                        ).then((_) => fetchClients());
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

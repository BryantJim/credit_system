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
                return ListTile(
                  title: Text('${client['nombre']} ${client['apellido']}'),
                  subtitle: Text('Email: ${client['email']}'),
                  trailing: IconButton(
                      onPressed: () => deleteClient(client['id']),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditClientePage(client: client),
                      ),
                    ).then((_) => fetchClients());
                  },
                );
              },
            ),
    );
  }
}

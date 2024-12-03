import 'package:credit_system/src/pages/edit_prestamo.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrestamosPage extends StatefulWidget {
  const PrestamosPage({super.key});

  @override
  State<PrestamosPage> createState() => _PrestamosPageState();
}

class _PrestamosPageState extends State<PrestamosPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> credits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrestamos();
  }

  Future<void> fetchPrestamos() async {
    setState(() => isLoading = true);

    try {
      final response = await _supabase
          .from('Prestamos')
          .select('*, Clientes (nombre, apellido)');
      setState(() {
        credits = response;
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener préstamos: $error')),
      );
    }
  }

  Future<void> deletePrestamo(String id) async {
    try {
      await _supabase.from('Prestamos').delete().eq('id', id);
      fetchPrestamos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préstamo eliminado correctamente')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar préstamo: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Préstamos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/prestamos/add')
                  .then((_) => fetchPrestamos());
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: credits.length,
              itemBuilder: (context, index) {
                final prestamo = credits[index];
                return ListTile(
                  title: Text(
                    '${prestamo['Clientes']['nombre']} ${prestamo['Clientes']['apellido']}',
                  ),
                  subtitle: Text(
                    'Monto Total: \$${prestamo['total_prestamo']}, Interes: \$${prestamo['total_interes']}, Balance: \$${prestamo['balance_disponible']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deletePrestamo(prestamo['id']),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPrestamosPage(credit: prestamo),
                      ),
                    ).then((_) => fetchPrestamos());
                  },
                );
              },
            ),
    );
  }
}

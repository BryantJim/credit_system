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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    '${prestamo['Clientes']['nombre']} ${prestamo['Clientes']['apellido']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        'Monto Total: \$${prestamo['total_prestamo']}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Interés: \$${prestamo['total_interes']}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Balance: \$${prestamo['balance_disponible']}',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeletePrestamo(context, prestamo['id']),
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
                ),
              );
            },
          ),
  );
}

// Función para mostrar el diálogo de confirmación
void _confirmDeletePrestamo(BuildContext context, String prestamoId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar Eliminación'),
      content: const Text('¿Estás seguro de que deseas eliminar este préstamo?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo
            deletePrestamo(prestamoId); // Llama a la función para eliminar el préstamo
          },
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}


}

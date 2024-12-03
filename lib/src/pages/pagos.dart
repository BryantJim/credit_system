import 'package:credit_system/src/pages/add_pago.dart';
import 'package:credit_system/src/widgets/select_cliente.dart';
import 'package:credit_system/src/widgets/select_prestamo.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({super.key});

  @override
  State<PagosPage> createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _supabase.from('pagos').select();

      setState(() {
        payments = response;
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error obteniendo los pagos: $error')),
      );
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _supabase.from('pagos').delete().eq('id', id);
      fetchPayments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago eliminado correctamente!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando el pago: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectClienteWidget(
                    onClienteSelected: (clienteId) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectPrestamoWidget(
                            clienteId: clienteId,
                            onPrestamoSelected:
                                (prestamoId, balanceDisponible) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPagoPage(
                                    prestamoId: prestamoId,
                                    balanceDisponible: balanceDisponible,
                                  ),
                                ),
                              ).then((_) => fetchPayments());
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : payments.isEmpty
              ? const Center(child: Text('No hay pagos registrados.'))
              : ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return ListTile(
                      title: Text(
                        'Monto: \$${payment['monto'].toStringAsFixed(2)}',
                      ),
                      subtitle: Text(
                        'Fecha: ${DateTime.parse(payment['fecha_pago']).toLocal()}',
                      ),
                      trailing: IconButton(
                        onPressed: () => deletePayment(payment['id']),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

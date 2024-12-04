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
      print('Pagos recibidos: $response');
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
      final response = await _supabase
          .from('pagos')
          .select('monto, prestamo_id')
          .eq('id', id)
          .single();

      final monto = response['monto'];
      final prestamoId = response['prestamo_id'];

      final prestamoResponse = await _supabase
          .from('Prestamos')
          .select('balance_disponible')
          .eq('id', prestamoId)
          .single();

      final double balanceActual = prestamoResponse['balance_disponible'];

      await _supabase.from('pagos').delete().eq('id', id);

      await _supabase.from('Prestamos').update({
        'balance_disponible': balanceActual + monto,
      }).eq('id', prestamoId);

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
                                (prestamoId, balanceDisponible, montoCuotas) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPagoPage(
                                    prestamoId: prestamoId,
                                    balanceDisponible: balanceDisponible,
                                    montoCuota: montoCuotas,
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
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          'Monto: \$${payment['monto'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha: ${DateTime.parse(payment['fecha_pago']).toLocal()}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tipo de Pago: ${payment['tipo_pago'] ?? 'Desconocido'}',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () => deletePayment(payment['id']),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

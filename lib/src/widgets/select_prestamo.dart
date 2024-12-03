import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectPrestamoWidget extends StatelessWidget {
  final String clienteId;
  final Function(String, double) onPrestamoSelected;

  const SelectPrestamoWidget(
      {super.key, required this.clienteId, required this.onPrestamoSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Préstamo'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client
            .from('Prestamos')
            .select()
            .eq('cliente_id', clienteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No hay préstamos para este cliente.'));
          }

          final prestamos = snapshot.data!;
          return ListView.builder(
            itemCount: prestamos.length,
            itemBuilder: (context, index) {
              final prestamo = prestamos[index];
              return ListTile(
                title: Text('Monto: \$${prestamo['monto']}'),
                subtitle: Text('Balance: \$${prestamo['balance_disponible']}'),
                onTap: () => onPrestamoSelected(
                    prestamo['id'], prestamo['balance_disponible']),
              );
            },
          );
        },
      ),
    );
  }
}

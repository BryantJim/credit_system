import 'package:credit_system/src/auth/auth_service.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int overdueClients = 5;
  int totalClients = 100;
  int activeCredits = 50;
  double collectedLast30Days = 145658.58;

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          //Notificaciones
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (overdueClients > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$overdueClients',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Clientes con cuentas vencidas: $overdueClients')),
              );
            },
          ),
          // Menú
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Clientes':
                  Navigator.pushNamed(context, '/clientes');
                  break;
                case 'Préstamos':
                  Navigator.pushNamed(context, '/prestamos');
                  break;
                case 'Pagos':
                  Navigator.pushNamed(context, '/pagos');
                  break;
                case 'Consultas':
                  Navigator.pushNamed(context, '/consultas');
                  break;
                case 'Cerrar Sesión':
                  _authService.signOut();
                  Navigator.pushNamed(context, '/login');
                  break;
                default:
                  Navigator.pushNamed(context, '/dashboard');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Clientes',
                child: Text('Clientes'),
              ),
              const PopupMenuItem(
                value: 'Préstamos',
                child: Text('Préstamos'),
              ),
              const PopupMenuItem(
                value: 'Pagos',
                child: Text('Pagos'),
              ),
              const PopupMenuItem(
                value: 'Cerrar Sesión',
                child: Text('Cerrar Sesión'),
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
                child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildSummaryCard(
                  title: 'Clientes',
                  value: '$totalClients',
                  icon: Icons.people,
                ),
                _buildSummaryCard(
                  title: 'Préstamos Activos',
                  value: '$activeCredits',
                  icon: Icons.attach_money,
                ),
                _buildSummaryCard(
                  title: 'Ultimos 30 días',
                  value: '\$${collectedLast30Days.toStringAsFixed(2)}',
                  icon: Icons.money,
                ),
                _buildSummaryCard(
                  title: 'Cuentas vencidas',
                  value: '$overdueClients',
                  icon: Icons.warning,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

Widget _buildSummaryCard(
    {required String title, required String value, required IconData icon}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.blue,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, color: Colors.black87),
          )
        ],
      ),
    ),
  );
}

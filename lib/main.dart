import 'package:credit_system/src/auth/auth_service.dart';
import 'package:credit_system/src/pages/add_cliente.dart';
import 'package:credit_system/src/pages/add_pago.dart';
import 'package:credit_system/src/pages/add_prestamo.dart';
import 'package:credit_system/src/pages/clientes.dart';
import 'package:credit_system/src/pages/dashboard.dart';
import 'package:credit_system/src/pages/edit_cliente.dart';
import 'package:credit_system/src/pages/edit_prestamo.dart';
import 'package:credit_system/src/pages/login.dart';
import 'package:credit_system/src/pages/pagos.dart';
import 'package:credit_system/src/pages/prestamos.dart';
import 'package:credit_system/src/pages/register.dart';
import 'package:credit_system/src/widgets/select_cliente.dart';
import 'package:credit_system/src/widgets/select_prestamo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthGate(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/clientes': (context) => const ClientesPage(),
        '/clientes/add': (context) => const AddClientePage(),
        '/clientes/edit': (context) => EditClientePage(
            client: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
        '/prestamos': (context) => const PrestamosPage(),
        '/prestamos/add': (context) => const AddPrestamoPage(),
        '/prestamos/edit': (context) => EditPrestamosPage(
              credit: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
        '/pagos': (context) => const PagosPage(),
        '/pagos/add': (context) => SelectClienteWidget(
              onClienteSelected: (clienteId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectPrestamoWidget(
                      clienteId: clienteId,
                      onPrestamoSelected: (prestamoId, balanceDisponible) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPagoPage(
                              prestamoId: prestamoId,
                              balanceDisponible: balanceDisponible,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      },
    );
  }
}

class EditPrestamoPage {}

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    if (_authService.isAuthenticated()) {
      return const DashboardPage();
    }

    return const LoginPage();
  }
}

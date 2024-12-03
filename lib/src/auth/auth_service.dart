import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signUp(
      String email, String password, String firstName, String lastName) async {
    try {
      final response =
          await _supabase.auth.signUp(email: email, password: password);

      if (response.user == null) {
        throw Exception('Error al registrarse');
      }

      await _supabase.from('Users').insert({
        'id': response.user!.id,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName
      });
    } catch (e) {
      throw Exception('Fallo al registrarse: ${e.toString()}');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Error al iniciar sesión');
      }
    } catch (e) {
      throw Exception('Fallo en el inicio de sesión: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Fallo al cerrar sesión: ${e.toString()}');
    }
  }

  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}

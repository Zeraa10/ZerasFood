import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:zerasfood/features/sincronizacion/firestore_sincronizador.dart'; // ✅ Importa el sincronizador

/// Pantalla de inicio de sesión del usuario.
/// Permite autenticarse con correo y contraseña,
/// y realiza sincronización de datos entre Firestore y SQLite si el login es exitoso.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controlador de autenticación obtenido mediante inyección de dependencias (GetIt)
  final AuthController _authController = GetIt.I<AuthController>();
  bool _isLoading = false; // Estado para mostrar el spinner de carga

  @override
  void dispose() {
    // Limpia los campos al salir de la pantalla
    _authController.clearControllers();
    super.dispose();
  }

  /// Maneja el proceso de inicio de sesión.
  /// Si el login es exitoso, sincroniza los datos entre Firestore y SQLite
  /// y redirige al dashboard.
  Future<void> _handleLogin(BuildContext context) async {
    setState(() => _isLoading = true);

    if (await _authController.login()) {
      final sincronizador = FirestoreSincronizador();

      try {
        // 🔽 Paso 1: Descargar datos desde Firestore a SQLite
        await sincronizador.descargarDesdeFirestore();
        print('✅ Datos descargados desde Firestore');

        // 🔼 Paso 2: Subir datos locales a Firestore
        await sincronizador.sincronizarTodo();
        print('✅ Datos sincronizados de SQLite a Firestore');
      } catch (e) {
        print('❌ Error al sincronizar: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al sincronizar datos')),
        );
      }

      // ✅ Navega al dashboard si todo salió bien
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      // ❌ Mostrar error si el login falla
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Text(
                  "Registro/Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A2EDC),
                  ),
                ),
                const SizedBox(height: 40),

                // Campo de correo electrónico
                TextField(
                  controller: _authController.emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                    hintText: "Correo electrónico",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Campo de contraseña
                TextField(
                  controller: _authController.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                    hintText: "Contraseña",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                  ),
                ),
                const SizedBox(height: 8),

                // Mensaje de error si el login falla
                if (_authController.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _authController.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),

                // Botón de login o spinner de carga
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () => _handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5A2EDC),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 32),

                // Enlace para navegar al registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿No tienes una cuenta?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Regístrate",
                        style: TextStyle(
                          color: Color(0xFF5A2EDC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

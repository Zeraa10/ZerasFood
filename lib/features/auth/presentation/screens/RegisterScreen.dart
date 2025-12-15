import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'package:get_it/get_it.dart';

/// Pantalla de registro de nuevos usuarios.
/// Permite crear una cuenta ingresando nombre, correo, contraseña y confirmación.
/// Utiliza un [AuthController] para manejar la lógica de validación y comunicación con el backend.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = GetIt.I<AuthController>(); // Inyección de dependencias con GetIt
  bool _isLoading = false; // Estado para mostrar indicador de carga

  /// Maneja el proceso de registro del usuario.
  /// Muestra un diálogo en caso de éxito o un mensaje de error si falla.
  Future<void> _handleRegister(BuildContext context) async {
    setState(() => _isLoading = true);

    final success = await _authController.register();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Registro exitoso: mostrar confirmación y redirigir al login
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Registro exitoso!'),
          content: const Text('Tu cuenta ha sido creada correctamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pushReplacementNamed(context, '/login'); // Ir al login
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      // Registro fallido: mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.registerErrorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _authController.clearRegisterControllers(); // Limpia los campos al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double baseFontSize = 14.0;
    double buttonFontSize = 14.0;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Formulario de registro
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 48),
                          const Text(
                            "Regístrate",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A2EDC),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Campo nombre
                          TextField(
                            controller: _authController.nameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                              hintText: "Nombre",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xFFF2F2F7),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Campo correo
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

                          // Campo contraseña
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
                          const SizedBox(height: 16),

                          // Campo confirmar contraseña
                          TextField(
                            controller: _authController.confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                              hintText: "Confirmar contraseña",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xFFF2F2F7),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Mensaje de error (si lo hay)
                          if (_authController.registerErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                _authController.registerErrorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Botón de registro o indicador de carga
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () => _handleRegister(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5A2EDC),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Regístrate",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),

                      // Enlace para ir al login
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿Ya tienes una cuenta?",
                              style: TextStyle(color: Colors.grey, fontSize: baseFontSize),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Inicia sesión",
                                style: TextStyle(
                                  color: Color(0xFF5A2EDC),
                                  fontWeight: FontWeight.bold,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

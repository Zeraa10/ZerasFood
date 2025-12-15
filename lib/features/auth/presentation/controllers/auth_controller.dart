import 'package:flutter/material.dart';
import 'package:zerasfood/features/auth/domain/repositories/auth_repository.dart';

/// Controlador que gestiona la lógica de autenticación para la UI.
/// Interactúa con el [AuthRepository] y expone controladores y estados para formularios.
class AuthController {
  final AuthRepository authRepository;

  /// Constructor que recibe una implementación del repositorio de autenticación.
  AuthController({required this.authRepository});

  // Controladores de texto para los formularios de login y registro
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Mensajes de error que pueden ser mostrados en la interfaz
  String errorMessage = '';
  String registerErrorMessage = '';

  /// Limpia los campos del formulario de login y reinicia el mensaje de error.
  void clearLoginControllers() {
    emailController.clear();
    passwordController.clear();
    errorMessage = '';
  }

  /// Limpia los campos del formulario de registro y reinicia el mensaje de error.
  void clearRegisterControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    registerErrorMessage = '';
  }

  /// Limpia todos los controladores del formulario, tanto de login como de registro.
  void clearControllers() {
    clearLoginControllers();
    clearRegisterControllers();
  }

  /// Ejecuta el inicio de sesión validando campos vacíos antes de delegar al repositorio.
  /// Retorna `true` si la autenticación fue exitosa, `false` si falla o hay errores.
  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Por favor, completa todos los campos.';
      return false;
    }

    final result = await authRepository.login(email, password);
    errorMessage = authRepository.errorMessage; // Mensaje del repositorio
    return result;
  }

  /// Ejecuta el proceso de registro validando que los campos estén completos.
  /// Retorna `true` si el registro fue exitoso, `false` si hay errores de validación o de backend.
  Future<bool> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      registerErrorMessage = 'Por favor, completa todos los campos.';
      return false;
    }

    final result = await authRepository.register(name, email, password, confirmPassword);
    registerErrorMessage = authRepository.registerErrorMessage; // Mensaje del repositorio
    return result;
  }

  /// Cierra la sesión actual y limpia los controladores.
  Future<void> logout() async {
    await authRepository.logout();
    clearControllers();
  }
}

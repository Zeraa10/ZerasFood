import '../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión con correo y contraseña.
/// Encapsula la lógica del proceso de autenticación.
class LoginUser {
  final AuthRepository repository;

  /// Inyecta el repositorio de autenticación que implementa la lógica real.
  LoginUser(this.repository);

  /// Ejecuta el login a través del repositorio.
  /// Devuelve `true` si el inicio de sesión fue exitoso, `false` en caso contrario.
  Future<bool> call(String email, String password) {
    return repository.login(email, password);
  }
}

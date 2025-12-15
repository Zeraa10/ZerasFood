import '../repositories/auth_repository.dart';

/// Caso de uso para registrar un nuevo usuario con nombre, correo y contraseña.
/// Aísla la lógica del proceso de registro para facilitar mantenimiento y pruebas.
class RegisterUser {
  final AuthRepository repository;

  /// Inyecta el repositorio de autenticación encargado del registro.
  RegisterUser(this.repository);

  /// Ejecuta el proceso de registro con los datos proporcionados.
  /// Retorna `true` si el registro fue exitoso, `false` en caso de error.
  Future<bool> call(String name, String email, String password, String confirmPassword) {
    return repository.register(name, email, password, confirmPassword);
  }
}

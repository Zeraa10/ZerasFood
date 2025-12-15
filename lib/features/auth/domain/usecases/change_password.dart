import '../repositories/auth_repository.dart';

/// Caso de uso que encapsula la lógica para cambiar la contraseña del usuario.
/// Separa la lógica de dominio de la implementación concreta del repositorio,
/// permitiendo pruebas unitarias y desacoplamiento.
class ChangePassword {
  final AuthRepository repository;

  /// Recibe una implementación de [AuthRepository] para aplicar el cambio de contraseña.
  ChangePassword(this.repository);

  /// Ejecuta el cambio de contraseña mediante el repositorio.
  /// Retorna `true` si el cambio fue exitoso, `false` en caso contrario.
  Future<bool> call(String currentPassword, String newPassword) {
    return repository.changePassword(currentPassword, newPassword);
  }
}

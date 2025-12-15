/// Interfaz abstracta para manejar operaciones de autenticación.
/// Define el contrato que cualquier implementación concreta (como AuthRepositoryImpl)
/// debe cumplir para facilitar el login, registro, cierre de sesión y cambios de contraseña.
abstract class AuthRepository {
  /// Inicia sesión con el correo y contraseña proporcionados.
  /// Devuelve `true` si la autenticación fue exitosa, `false` en caso contrario.
  Future<bool> login(String email, String password);

  /// Registra un nuevo usuario con nombre, correo, contraseña y confirmación.
  /// Devuelve `true` si el registro fue exitoso, `false` en caso contrario.
  Future<bool> register(String name, String email, String password, String confirmPassword);

  /// Cierra la sesión del usuario autenticado actual.
  Future<void> logout();

  /// Cambia la contraseña del usuario actual después de reautenticarse.
  /// Devuelve `true` si el cambio fue exitoso, `false` en caso de error.
  Future<bool> changePassword(String currentPassword, String newPassword);

  /// Limpia los controladores del formulario de login.
  void clearLoginControllers();

  /// Limpia los controladores del formulario de registro.
  void clearRegisterControllers();

  /// Mensaje de error obtenido tras intentar iniciar sesión.
  String get errorMessage;

  /// Mensaje de error obtenido tras intentar registrarse.
  String get registerErrorMessage;
}

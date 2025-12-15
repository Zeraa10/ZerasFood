import 'package:zerasfood/features/settings/domain/entities/configuracion.dart';

/// Contrato de la capa de dominio para manejar la configuración del usuario.
/// Define las operaciones disponibles sin acoplarse a la fuente de datos (Firestore, SQLite, etc.).
abstract class ConfiguracionRepository {
  /// Obtiene la configuración de preferencias de un usuario a partir de su [usuarioId].
  /// Devuelve un objeto [Configuracion] o null si no existe.
  Future<Configuracion?> obtenerConfiguracion(String usuarioId);

  /// Guarda o actualiza la configuración en la fuente de datos.
  /// Puede sobrescribir valores existentes si ya hay configuración previa.
  Future<void> guardarConfiguracion(Configuracion config);

  /// Método opcional que permite forzar una sincronización desde Firestore.
  /// Útil si trabajas con caché local (por ejemplo, SQLite o SharedPreferences).
  Future<void> sincronizarConfiguracionDesdeFirestore(String usuarioId);
}

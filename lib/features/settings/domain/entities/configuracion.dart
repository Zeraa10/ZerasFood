/// Entidad que representa la configuración de preferencias de un usuario.
/// Incluye el tema visual, el estado de notificaciones y el ID del usuario.
class Configuracion {
  final String tema;             // Tema seleccionado por el usuario (ej: 'claro', 'oscuro')
  final bool notificaciones;     // Indica si las notificaciones están activadas
  final String usuarioId;        // ID del usuario propietario de esta configuración

  /// Constructor con parámetros requeridos.
  Configuracion({
    required this.tema,
    required this.notificaciones,
    required this.usuarioId,
  });

  /// Serializa el objeto en un mapa compatible con Firestore.
  /// Se asegura de que el campo `notificaciones` sea estrictamente booleano.
  Map<String, dynamic> toFirestore() => {
    'tema': tema,
    'notificaciones': notificaciones, // 🔐 Garantizado como bool
    'usuario_id': usuarioId,
  };

  /// Crea una instancia de [Configuracion] a partir de un mapa Firestore.
  /// Soporta valores booleanos o enteros (ej. `1` → true) como fallback.
  factory Configuracion.fromFirestore(Map<String, dynamic> data, String uid) {
    final raw = data['notificaciones'];
    final bool parsed = raw is bool ? raw : raw == 1;

    return Configuracion(
      tema: data['tema'] ?? 'claro',
      notificaciones: parsed,
      usuarioId: uid,
    );
  }

  /// Clona el objeto actual, permitiendo modificar campos opcionales.
  /// Útil para mantener inmutabilidad en estructuras reactivas o estados.
  Configuracion copyWith({
    String? tema,
    bool? notificaciones,
    String? usuarioId,
  }) {
    return Configuracion(
      tema: tema ?? this.tema,
      notificaciones: notificaciones ?? this.notificaciones,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}

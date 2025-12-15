import 'package:zerasfood/features/categoria/domain/entities/categoria.dart'; // Asegúrate de importar tu modelo de categoría

/// Entidad que representa un gasto en el sistema.
/// Incluye referencias al usuario, la categoría y metadatos como descripción y fecha.
class Gasto {
  String? id;                // ID del documento en Firestore (string único generado automáticamente)
  double monto;              // Monto del gasto
  String? descripcion;       // Descripción opcional del gasto
  DateTime fecha;            // Fecha en que se registró el gasto
  int usuarioId;             // ID del usuario que registró el gasto
  int? categoriaId;          // ID de la categoría asociada (puede ser nulo)
  Categoria? categoria;      // Objeto completo de la categoría (opcional y útil para mostrar en UI)

  /// Constructor con parámetros obligatorios y opcionales.
  Gasto({
    this.id,
    required this.monto,
    this.descripcion,
    required this.fecha,
    required this.usuarioId,
    this.categoriaId,
    this.categoria,
  });

  /// Convierte la instancia de [Gasto] en un mapa para ser almacenado en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(), // Se guarda en formato estándar ISO 8601
      'usuario_id': usuarioId,
      'categoria_id': categoriaId,
    };
  }

  /// Crea una instancia de [Gasto] a partir de un mapa.
  /// Comúnmente usado al leer desde Firestore o SQLite.
  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'],
      monto: map['monto']?.toDouble() ?? 0.0,
      descripcion: map['descripcion'],
      fecha: DateTime.parse(map['fecha']),
      usuarioId: map['usuario_id'],
      categoriaId: map['categoria_id'],
    );
  }
}

import 'package:zerasfood/features/categoria/domain/entities/categoria.dart';

/// Entidad que representa un ingreso de dinero registrado por un usuario.
/// Puede estar relacionado a una categoría específica, y permite múltiples unidades (`cantidad`).
class Ingreso {
  String? id;                // ID generado por Firestore (string único)
  double monto;              // Monto del ingreso (unitario)
  String? descripcion;       // Descripción opcional del ingreso
  DateTime fecha;            // Fecha del ingreso (formato DateTime)
  String? metodoPago;        // Medio de pago (efectivo, tarjeta, etc.)
  int usuarioId;             // ID del usuario que registró el ingreso
  String? categoriaId;       // ID de la categoría asociada (en Firestore)
  int cantidad;              // Cantidad de unidades vendidas o ingresadas
  Categoria? categoria;      // Objeto completo de la categoría (opcional, para mostrar en UI)

  /// Constructor con campos obligatorios y opcionales.
  Ingreso({
    this.id,
    required this.monto,
    this.descripcion,
    required this.fecha,
    this.metodoPago,
    required this.usuarioId,
    this.categoriaId,
    this.cantidad = 1,
    this.categoria,
  });

  /// Convierte la instancia de [Ingreso] en un mapa clave-valor.
  /// Útil para almacenar el ingreso en Firestore o bases de datos locales.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'metodo_pago': metodoPago,
      'usuario_id': usuarioId,
      'categoria_id': categoriaId,
      'cantidad': cantidad,
    };
  }

  /// Crea una instancia de [Ingreso] a partir de un mapa (por ejemplo desde Firestore).
  /// Convierte tipos numéricos y fecha desde texto si es necesario.
  factory Ingreso.fromMap(Map<String, dynamic> map) {
    return Ingreso(
      id: map['id'],
      monto: map['monto']?.toDouble() ?? 0.0,
      descripcion: map['descripcion'],
      fecha: DateTime.parse(map['fecha']),
      metodoPago: map['metodo_pago'],
      usuarioId: map['usuario_id']?.toInt() ?? 0,
      categoriaId: map['categoria_id'] as String?,
      cantidad: map['cantidad']?.toInt() ?? 1,
    );
  }
}

/// Entidad que representa una categoría de productos o servicios.
/// Se utiliza tanto para persistencia local (SQLite) como para sincronización con Firestore.
class Categoria {
  final int? id;              // ID local autoincremental (SQLite)
  final String? nombre;       // Nombre de la categoría (e.g., Bebidas, Comida)
  final String? tipo;         // Tipo de categoría (e.g., ingreso, gasto, producto)
  final String? firestoreId;  // ID del documento en Firestore (para sincronización remota)

  /// Constructor con parámetros opcionales.
  Categoria({
    this.id,
    this.nombre,
    this.tipo,
    this.firestoreId,
  });

  /// Convierte la instancia de [Categoria] en un mapa clave-valor.
  /// Útil para operaciones de escritura en SQLite o Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'firestore_id': firestoreId, // ✅ Incluye firestoreId para mantener la referencia remota
    };
  }

  /// Crea una instancia de [Categoria] a partir de un mapa.
  /// Generalmente usado al leer registros desde SQLite.
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      firestoreId: map['firestore_id'], // ✅ Leer firestoreId desde almacenamiento local
    );
  }
}

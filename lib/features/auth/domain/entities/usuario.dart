/// Modelo de datos para representar a un usuario.
/// Se utiliza principalmente para operaciones locales (como almacenamiento en SQLite).
class Usuario {
  int? id;
  String? nombre;
  String? correo;
  String? contrasena;

  /// Constructor con parámetros opcionales, permite crear instancias vacías o completas.
  Usuario({this.id, this.nombre, this.correo, this.contrasena});

  /// Convierte la instancia actual en un mapa clave-valor.
  /// Útil para guardar en bases de datos como SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
    };
  }

  /// Crea una instancia de [Usuario] a partir de un mapa.
  /// Este patrón es común al leer datos desde SQLite o Firestore.
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      correo: map['correo'],
      contrasena: map['contrasena'],
    );
  }
}

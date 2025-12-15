import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "zeras_food.db");

    return await openDatabase(
      path,
      version: 7, // ← Incrementado para incluir firestore_id
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        correo TEXT UNIQUE,
        contrasena TEXT
      );
    ''');

    // Crear tabla de categorías con firestore_id
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        tipo TEXT CHECK(tipo IN ('ingreso', 'gasto')),
        firestore_id TEXT
      );
    ''');

    // Precargar categorías si están vacías
    List<Map<String, dynamic>> categoriasExistentes = await db.query('categorias');
    if (categoriasExistentes.isEmpty) {
      final categorias = [
        'Salchipapa Sencilla',
        'Salchipapa Especial',
        'Hamburguesa Sencilla',
        'Hamburguesa en Combo',
        'Empanadas',
        'Perro Caliente',
        'Mazorcada',
        'Canasta de Patacón',
        'Quesadillas',
        'Arepas Rellenas',
      ];
      for (var nombre in categorias) {
        await db.insert('categorias', {'nombre': nombre, 'tipo': 'ingreso'});
      }
    }

    // Crear tabla de ingresos
    await db.execute('''
      CREATE TABLE ingresos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monto REAL CHECK(monto > 0),
        descripcion TEXT,
        fecha TEXT,
        metodo_pago TEXT,
        usuario_id INTEGER,
        categoria_id INTEGER,
        cantidad INTEGER DEFAULT 1,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (categoria_id) REFERENCES categorias (id) ON DELETE CASCADE
      );
    ''');

    // Crear tabla de gastos
    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monto REAL CHECK(monto > 0),
        descripcion TEXT,
        fecha TEXT,
        usuario_id INTEGER,
        categoria_id INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (categoria_id) REFERENCES categorias (id) ON DELETE CASCADE
      );
    ''');

    // Crear tabla de configuración
    await db.execute('''
      CREATE TABLE configuracion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tema TEXT,
        notificaciones INTEGER,
        usuario_id TEXT
      );
    ''');

    // Índices para optimización
    await db.execute('CREATE INDEX idx_ingresos_fecha ON ingresos (fecha);');
    await db.execute('CREATE INDEX idx_ingresos_usuario_id ON ingresos (usuario_id);');
    await db.execute('CREATE INDEX idx_ingresos_categoria_id ON ingresos (categoria_id);');
    await db.execute('CREATE INDEX idx_gastos_fecha ON gastos (fecha);');
    await db.execute('CREATE INDEX idx_gastos_usuario_id ON gastos (usuario_id);');
    await db.execute('CREATE INDEX idx_gastos_categoria_id ON gastos (categoria_id);');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE ingresos ADD COLUMN cantidad INTEGER DEFAULT 1;');
    }

    // NUEVO: Agrega columna firestore_id a categorias si vienes de versión < 6
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE categorias ADD COLUMN firestore_id TEXT;');
    }
  }

  static Future<Database> database() async {
    return await db;
  }
}

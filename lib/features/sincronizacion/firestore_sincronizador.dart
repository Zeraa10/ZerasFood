// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerasfood/db/database.dart';
import 'package:sqflite/sqflite.dart';

/// Clase responsable de sincronizar datos entre SQLite y Firestore.
/// Se encarga tanto de subir como de descargar datos para mantener la consistencia.
class FirestoreSincronizador {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Sincroniza todas las entidades locales (categorías, usuarios, ingresos, gastos) con Firestore.
  Future<void> sincronizarTodo() async {
    final db = await DBHelper.db;
    await _sincronizarCategorias(db);
    await _sincronizarUsuarios(db);
    await _sincronizarIngresos(db);
    await _sincronizarGastos(db);
    print('✅ Sincronización completa con Firestore.');
  }

  /// Descarga los datos desde Firestore y los guarda localmente en SQLite.
  Future<void> descargarDesdeFirestore() async {
    final db = await DBHelper.db;
    await _descargarCategorias(db);
    await _descargarUsuarios(db);
    await _descargarIngresos(db);
    await _descargarGastos(db);
    print('✅ Datos descargados desde Firestore a SQLite');
  }

  /// Sincroniza las categorías locales con Firestore.
  /// Si una categoría no existe en Firestore, la crea; si existe pero cambió su tipo, la actualiza.
  Future<void> _sincronizarCategorias(Database db) async {
    final categoriasLocales = await db.query('categorias');
    for (var categoria in categoriasLocales) {
      final nombre = categoria['nombre'];
      final tipo = categoria['tipo'];
      final query = await firestore
          .collection('categorias')
          .where('nombre', isEqualTo: nombre)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('categorias').add({
          'nombre': nombre,
          'tipo': tipo,
          'created_at': FieldValue.serverTimestamp(),
        });
        print('🟢 Categoría agregada: $nombre');
      } else {
        final doc = query.docs.first;
        final data = doc.data();
        if (data['tipo'] != tipo) {
          await doc.reference.update({'tipo': tipo});
          print('🟡 Categoría actualizada: $nombre');
        } else {
          print('🔵 Categoría sin cambios: $nombre');
        }
      }
    }
  }

  /// Descarga las categorías de Firestore y las inserta localmente si no existen.
  Future<void> _descargarCategorias(Database db) async {
    final snapshot = await firestore.collection('categorias').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final nombre = data['nombre'];
      final tipo = data['tipo'];
      final local = await db.query(
        'categorias',
        where: 'nombre = ? AND tipo = ?',
        whereArgs: [nombre, tipo],
      );
      if (local.isEmpty) {
        await db.insert('categorias', {
          'nombre': nombre,
          'tipo': tipo,
        });
        print('🟢 Categoría insertada desde Firestore: $nombre');
      }
    }
  }

  /// Sincroniza los usuarios locales con Firestore.
  /// Si un usuario no existe, lo crea. Si ya existe pero cambió algún dato, lo actualiza.
  Future<void> _sincronizarUsuarios(Database db) async {
    final usuariosLocales = await db.query('usuarios');
    for (var usuario in usuariosLocales) {
      final correo = usuario['correo'];
      final nombre = usuario['nombre'];
      final contrasena = usuario['contrasena'];
      final query = await firestore
          .collection('usuarios')
          .where('correo', isEqualTo: correo)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('usuarios').add({
          'nombre': nombre,
          'correo': correo,
          'contrasena': contrasena,
        });
        print('🟢 Usuario agregado: $correo');
      } else {
        final doc = query.docs.first;
        final data = doc.data();
        if (data['nombre'] != nombre || data['contrasena'] != contrasena) {
          await doc.reference.update({
            'nombre': nombre,
            'contrasena': contrasena,
          });
          print('🟡 Usuario actualizado: $correo');
        } else {
          print('🔵 Usuario sin cambios: $correo');
        }
      }
    }
  }

  /// Descarga los usuarios de Firestore y los guarda en SQLite si no existen.
  Future<void> _descargarUsuarios(Database db) async {
    final snapshot = await firestore.collection('usuarios').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final correo = data['correo'];
      final local = await db.query(
        'usuarios',
        where: 'correo = ?',
        whereArgs: [correo],
      );
      if (local.isEmpty) {
        await db.insert('usuarios', {
          'nombre': data['nombre'],
          'correo': correo,
          'contrasena': data['contrasena'],
        });
        print('🟢 Usuario insertado desde Firestore: $correo');
      }
    }
  }

  /// Sincroniza los ingresos locales con Firestore.
  /// Verifica si ya existe uno con la misma descripción, monto y fecha.
  Future<void> _sincronizarIngresos(Database db) async {
    final ingresosLocales = await db.query('ingresos');
    for (var ingreso in ingresosLocales) {
      final monto = ingreso['monto'];
      final fecha = ingreso['fecha'];
      final descripcion = ingreso['descripcion'];
      final query = await firestore
          .collection('ingresos')
          .where('monto', isEqualTo: monto)
          .where('fecha', isEqualTo: fecha)
          .where('descripcion', isEqualTo: descripcion)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('ingresos').add({
          'monto': monto,
          'descripcion': descripcion,
          'fecha': fecha,
          'metodo_pago': ingreso['metodo_pago'],
          'usuario_id': ingreso['usuario_id'],
          'categoria_id': ingreso['categoria_id'],
          'cantidad': ingreso['cantidad'],
        });
        print('🟢 Ingreso agregado: $descripcion');
      } else {
        print('🔵 Ingreso ya existe: $descripcion');
      }
    }
  }

  /// Descarga los ingresos desde Firestore y los guarda en SQLite si no existen.
  Future<void> _descargarIngresos(Database db) async {
    final snapshot = await firestore.collection('ingresos').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final descripcion = data['descripcion'];
      final fecha = data['fecha'];
      final local = await db.query(
        'ingresos',
        where: 'descripcion = ? AND fecha = ?',
        whereArgs: [descripcion, fecha],
      );
      if (local.isEmpty) {
        await db.insert('ingresos', {
          'monto': data['monto'],
          'descripcion': descripcion,
          'fecha': fecha,
          'metodo_pago': data['metodo_pago'],
          'usuario_id': data['usuario_id'],
          'categoria_id': data['categoria_id'],
          'cantidad': data['cantidad'],
        });
        print('🟢 Ingreso insertado desde Firestore: $descripcion');
      }
    }
  }

  /// Sincroniza los gastos locales con Firestore.
  /// Si no se encuentra un gasto con los mismos datos, lo agrega.
  Future<void> _sincronizarGastos(Database db) async {
    final gastosLocales = await db.query('gastos');
    for (var gasto in gastosLocales) {
      final monto = gasto['monto'];
      final fecha = gasto['fecha'];
      final descripcion = gasto['descripcion'];
      final query = await firestore
          .collection('gastos')
          .where('monto', isEqualTo: monto)
          .where('fecha', isEqualTo: fecha)
          .where('descripcion', isEqualTo: descripcion)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        await firestore.collection('gastos').add({
          'monto': monto,
          'descripcion': descripcion,
          'fecha': fecha,
          'usuario_id': gasto['usuario_id'],
          'categoria_id': gasto['categoria_id'],
        });
        print('🟢 Gasto agregado: $descripcion');
      } else {
        print('🔵 Gasto ya existe: $descripcion');
      }
    }
  }

  /// Descarga los gastos desde Firestore y los guarda en SQLite si no existen.
  Future<void> _descargarGastos(Database db) async {
    final snapshot = await firestore.collection('gastos').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final descripcion = data['descripcion'];
      final fecha = data['fecha'];
      final local = await db.query(
        'gastos',
        where: 'descripcion = ? AND fecha = ?',
        whereArgs: [descripcion, fecha],
      );
      if (local.isEmpty) {
        await db.insert('gastos', {
          'monto': data['monto'],
          'descripcion': descripcion,
          'fecha': fecha,
          'usuario_id': data['usuario_id'],
          'categoria_id': data['categoria_id'],
        });
        print('🟢 Gasto insertado desde Firestore: $descripcion');
      }
    }
  }
}

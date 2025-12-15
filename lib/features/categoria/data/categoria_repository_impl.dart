import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerasfood/db/database.dart';
import 'package:zerasfood/features/categoria/domain/entities/categoria.dart';
import 'package:zerasfood/features/categoria/domain/repositories/categoria_repository.dart';

/// Implementación concreta de [CategoriaRepository].
/// Administra operaciones CRUD de categorías sincronizadas entre Firestore y SQLite.
class CategoriaRepositoryImpl implements CategoriaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene todas las categorías desde Firestore y sincroniza en SQLite.
  /// Elimina primero las locales para evitar duplicados y asegura consistencia.
  @override
  Future<List<Categoria>> obtenerCategorias() async {
    final db = await DBHelper.db;

    // 🔁 Paso 1: Limpiar tabla local para evitar entradas repetidas
    await db.delete('categorias');

    // 🔥 Paso 2: Obtener categorías desde Firestore
    final docs = await _firestore.collection('categorias').get();

    // 💾 Paso 3: Guardar cada categoría localmente con su firestore_id
    for (var doc in docs.docs) {
      final data = doc.data();
      await db.insert('categorias', {
        'nombre': data['nombre'],
        'tipo': data['tipo'],
        'firestore_id': doc.id,
      });
      print('✅ Categoría sincronizada: ${data['nombre']} - firestoreId: ${doc.id}');
    }

    // ✅ Paso 4: Retornar lista de objetos [Categoria] desde SQLite
    final actualizadas = await db.query('categorias');
    return actualizadas.map((e) => Categoria.fromMap(e)).toList();
  }

  /// Agrega una nueva categoría a Firestore y la refleja en SQLite.
  @override
  Future<void> agregarCategoria(String nombre, String tipo) async {
    final db = await DBHelper.db;

    // Paso 1: Insertar primero en Firestore (obtiene el ID generado)
    final ref = await _firestore.collection('categorias').add({
      'nombre': nombre,
      'tipo': tipo,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Paso 2: Insertar en SQLite con el ID generado por Firestore
    await db.insert('categorias', {
      'nombre': nombre,
      'tipo': tipo,
      'firestore_id': ref.id,
    });
  }

  /// Edita una categoría existente en SQLite y Firestore.
  /// Se basa en el `firestoreId` si está disponible para actualizar el documento remoto.
  @override
  Future<void> editarCategoria(Categoria categoria) async {
    final db = await DBHelper.db;

    // Paso 1: Actualizar registro local
    await db.update(
      'categorias',
      {
        'nombre': categoria.nombre,
        'tipo': categoria.tipo,
        'firestore_id': categoria.firestoreId,
      },
      where: 'id = ?',
      whereArgs: [categoria.id],
    );

    // Paso 2: Actualizar en Firestore si existe un firestoreId confiable
    if (categoria.firestoreId != null) {
      await _firestore.collection('categorias').doc(categoria.firestoreId).update({
        'nombre': categoria.nombre,
        'tipo': categoria.tipo,
      });
    } else {
      // Fallback si no hay firestoreId (menos eficiente)
      final query = await _firestore
          .collection('categorias')
          .where('nombre', isEqualTo: categoria.nombre)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'nombre': categoria.nombre,
          'tipo': categoria.tipo,
        });
      }
    }
  }

  /// Elimina una categoría de SQLite y Firestore según su nombre.
  /// El nombre debe ser único para evitar errores.
  @override
  Future<void> eliminarCategoria(String nombre) async {
    final db = await DBHelper.db;

    // Paso 1: Eliminar categoría local
    final result = await db.query(
      'categorias',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );

    if (result.isNotEmpty) {
      final id = result.first['id'] as int;
      await db.delete(
        'categorias',
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    // Paso 2: Eliminar en Firestore (búsqueda por nombre)
    final query = await _firestore
        .collection('categorias')
        .where('nombre', isEqualTo: nombre)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    }
  }
}

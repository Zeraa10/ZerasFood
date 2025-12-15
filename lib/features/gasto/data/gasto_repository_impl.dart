import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerasfood/features/gasto/domain/entities/gasto.dart';
import 'package:zerasfood/features/gasto/domain/repositories/gasto_repository.dart';

/// Implementación del repositorio de gastos usando Firebase Firestore como fuente de datos.
/// Este repositorio gestiona operaciones CRUD y consultas específicas para la entidad [Gasto].
class GastoRepositoryImpl implements GastoRepository {
  final String _collection = 'gastos';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inserta un nuevo gasto en la colección 'gastos' de Firestore.
  /// Retorna 1 como valor simbólico (Firestore no maneja IDs numéricos).
  @override
  Future<int> insertarGasto(Gasto gasto) async {
    await _firestore.collection(_collection).add(gasto.toMap());
    return 1;
  }

  /// Método no aplicable en Firestore debido a que el ID es un string generado automáticamente.
  @override
  Future<Gasto?> obtenerGasto(int id) async {
    return null;
  }

  /// Obtiene todos los gastos ordenados por fecha descendente.
  /// Convierte los documentos Firestore a objetos [Gasto].
  @override
  Future<List<Gasto>> obtenerTodosGastos({String? orderBy}) async {
    final snapshot = await _firestore.collection(_collection).orderBy('fecha', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Gasto(
        id: doc.id,
        monto: (data['monto'] as num).toDouble(),
        descripcion: data['descripcion'],
        fecha: DateTime.parse(data['fecha']),
        usuarioId: data['usuario_id'],
        categoriaId: data['categoria_id'],
      );
    }).toList();
  }

  /// Actualiza un gasto existente basado en su descripción y monto (no ideal si hay duplicados).
  /// Devuelve 1 si se actualiza correctamente, 0 si no se encuentra coincidencia.
  @override
  Future<int> actualizarGasto(Gasto gasto) async {
    final query = await _firestore
        .collection(_collection)
        .where('descripcion', isEqualTo: gasto.descripcion)
        .where('monto', isEqualTo: gasto.monto)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(gasto.toMap());
      return 1;
    }
    return 0;
  }

  /// No implementado: Firestore no maneja IDs enteros para documentos.
  @override
  Future<int> eliminarGasto(int id) async {
    return 0;
  }

  /// Obtiene el total de gastos de un mes específico.
  /// Filtra documentos por campo 'fecha' en formato ISO.
  @override
  Future<double> obtenerTotalGastosPorMes(int year, int month) async {
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 0);

    final snapshot = await _firestore
        .collection(_collection)
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fin.toIso8601String())
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final monto = (data['monto'] ?? 0) as num;
      total += monto.toDouble();
    }

    return total;
  }

  /// Obtiene todos los gastos registrados en un mes específico.
  /// Se filtra por el campo 'fecha' almacenado en formato ISO 8601.
  @override
  Future<List<Gasto>> obtenerGastosPorMes(int year, int month) async {
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 0);

    final snapshot = await _firestore
        .collection(_collection)
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fin.toIso8601String())
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Gasto(
        id: doc.id,
        monto: (data['monto'] as num).toDouble(),
        descripcion: data['descripcion'],
        fecha: DateTime.parse(data['fecha']),
        usuarioId: data['usuario_id'],
        categoriaId: data['categoria_id'],
      );
    }).toList();
  }
}

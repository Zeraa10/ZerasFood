import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerasfood/features/ingreso/domain/entities/ingreso.dart';
import 'package:zerasfood/features/ingreso/domain/repositories/ingreso_repository.dart';

/// Implementación del repositorio de ingresos utilizando Firebase Firestore como fuente de datos.
/// Esta clase se enfoca en operaciones estadísticas y consultas específicas para reportes financieros.
class IngresoRepositoryImpl implements IngresoRepository {
  final _firestore = FirebaseFirestore.instance;
  final String _tableName = 'ingresos';

  /// Calcula el total de ingresos en un mes determinado.
  /// Suma `monto * cantidad` para cada ingreso registrado en ese mes.
  @override
  Future<double> obtenerTotalIngresosPorMes(int year, int month) async {
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 0);

    final snapshot = await _firestore
        .collection(_tableName)
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fin.toIso8601String())
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final monto = (data['monto'] as num).toDouble();
      final cantidad = data['cantidad'] ?? 1;
      total += monto * cantidad;
    }
    return total;
  }

  /// Obtiene el nombre de la categoría con más ventas (por cantidad) en un mes específico.
  /// Busca la categoría que más veces se repite sumando la cantidad asociada.
  @override
  Future<String?> obtenerCategoriaMasVendidaPorMes(int year, int month) async {
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 0);

    final snapshot = await _firestore
        .collection(_tableName)
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fin.toIso8601String())
        .get();

    final Map<String, int> categoriaCantidad = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final categoriaId = data['categoria_id']?.toString();
      final cantidad = (data['cantidad'] ?? 1) as int;

      if (categoriaId != null) {
        categoriaCantidad[categoriaId] = (categoriaCantidad[categoriaId] ?? 0) + cantidad;
      }
    }

    if (categoriaCantidad.isEmpty) return null;

    // Determina la categoría con mayor cantidad acumulada
    final idMasVendido = categoriaCantidad.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Obtiene el nombre de la categoría más vendida desde la colección 'categorias'
    final categoriaDoc = await _firestore.collection('categorias').doc(idMasVendido).get();
    if (categoriaDoc.exists) {
      return categoriaDoc.data()?['nombre'] ?? 'Sin nombre';
    }

    return 'Categoría desconocida';
  }

  /// Calcula el total de ingresos por método de pago en un mes específico.
  /// Ideal para reportes que discriminan entre efectivo, tarjeta, etc.
  @override
  Future<double> obtenerTotalIngresosPorMetodoPago(int year, int month, String metodoPago) async {
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 0);

    final snapshot = await _firestore
        .collection(_tableName)
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fin.toIso8601String())
        .where('metodo_pago', isEqualTo: metodoPago)
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final monto = (data['monto'] as num).toDouble();
      final cantidad = data['cantidad'] ?? 1;
      total += monto * cantidad;
    }
    return total;
  }

  /// Alias de `obtenerTotalIngresosPorMes`, conservado por compatibilidad.
  @override
  Future<double> obtenerTotalIngresosPorMesPorAnio(int anio, int mes) async {
    final inicio = DateTime(anio, mes, 1);
    final fin = DateTime(anio, mes + 1, 0);

    final snapshot = await _firestore
        .collection(_tableName)
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThanOrEqualTo: fin.toIso8601String())
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final monto = (data['monto'] ?? 0);
      final cantidad = data['cantidad'] ?? 1;
      total += (monto as num).toDouble() * (cantidad as num).toDouble();
    }

    return total;
  }

  // Métodos no implementados en esta clase, reservados para futuras versiones o fuentes como SQLite.

  @override
  Future<int> insertarIngreso(Ingreso ingreso) => throw UnimplementedError();

  @override
  Future<Ingreso?> obtenerIngreso(int id) => throw UnimplementedError();

  @override
  Future<List<Ingreso>> obtenerTodosIngresos({String? orderBy}) => throw UnimplementedError();

  @override
  Future<int> actualizarIngreso(Ingreso ingreso) => throw UnimplementedError();

  @override
  Future<int> eliminarIngreso(int id) => throw UnimplementedError();

  @override
  Future<List<Ingreso>> obtenerIngresosPorMes(int year, int month) => throw UnimplementedError();
}

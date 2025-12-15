import 'package:zerasfood/features/gasto/domain/entities/gasto.dart';

/// Contrato de la capa de dominio para el manejo de gastos.
/// Define las operaciones disponibles sin acoplarse a la fuente de datos (Firestore, SQLite, etc.).
abstract class GastoRepository {
  /// Inserta un nuevo gasto en la fuente de datos.
  /// Devuelve un valor entero como confirmación (por ejemplo: 1 si se inserta correctamente).
  Future<int> insertarGasto(Gasto gasto);

  /// Obtiene un gasto por su ID numérico.
  /// Este método es más útil en implementaciones con SQLite o bases relacionales.
  Future<Gasto?> obtenerGasto(int id);

  /// Retorna todos los gastos almacenados.
  /// Permite opcionalmente ordenar por algún campo.
  Future<List<Gasto>> obtenerTodosGastos({String? orderBy});

  /// Actualiza un gasto existente.
  /// Devuelve 1 si se actualiza correctamente, 0 si no se encuentra o no se modifica.
  Future<int> actualizarGasto(Gasto gasto);

  /// Elimina un gasto por su ID numérico.
  /// Similar a `obtenerGasto`, es más aplicable en fuentes que usan identificadores enteros.
  Future<int> eliminarGasto(int id);

  /// Calcula el total de gastos registrados en un mes y año específicos.
  Future<double> obtenerTotalGastosPorMes(int year, int month);

  /// Obtiene todos los gastos de un mes y año específicos.
  /// Útil para estadísticas mensuales o reportes filtrados por fecha.
  Future<List<Gasto>> obtenerGastosPorMes(int year, int month);
}

import 'package:zerasfood/features/ingreso/domain/entities/ingreso.dart';

/// Contrato de la capa de dominio para gestionar operaciones relacionadas con ingresos.
/// Permite desacoplar la lógica de negocio de la fuente de datos (Firestore, SQLite, etc.).
abstract class IngresoRepository {
  /// Inserta un nuevo ingreso en la fuente de datos.
  /// Retorna un valor entero como confirmación del éxito (ej. 1 si se insertó).
  Future<int> insertarIngreso(Ingreso ingreso);

  /// Obtiene un ingreso por su ID numérico.
  /// Más útil en implementaciones con bases locales como SQLite.
  Future<Ingreso?> obtenerIngreso(int id);

  /// Retorna todos los ingresos almacenados.
  /// Puede incluir ordenamiento opcional (por fecha, monto, etc.).
  Future<List<Ingreso>> obtenerTodosIngresos({String? orderBy});

  /// Actualiza un ingreso existente.
  /// Retorna 1 si se actualiza exitosamente, 0 si no se encuentra.
  Future<int> actualizarIngreso(Ingreso ingreso);

  /// Elimina un ingreso por su ID numérico.
  /// Generalmente usado en SQLite o estructuras con ID incremental.
  Future<int> eliminarIngreso(int id);

  /// Calcula el total de ingresos de un mes específico (sumando monto * cantidad).
  Future<double> obtenerTotalIngresosPorMes(int year, int month);

  /// Obtiene todos los ingresos registrados en un mes y año determinados.
  Future<List<Ingreso>> obtenerIngresosPorMes(int year, int month);

  /// Alias para obtener el total mensual por año (útil en dashboards anuales).
  Future<double> obtenerTotalIngresosPorMesPorAnio(int anio, int mes);

  /// Retorna el nombre de la categoría con mayor cantidad de ingresos en el mes especificado.
  Future<String?> obtenerCategoriaMasVendidaPorMes(int anio, int mes);

  /// Obtiene el total de ingresos por un método de pago específico (efectivo, tarjeta, etc.).
  Future<double> obtenerTotalIngresosPorMetodoPago(int anio, int mes, String metodoPago);
}

import 'package:zerasfood/features/gasto/domain/entities/gasto.dart';
import 'package:zerasfood/features/gasto/domain/repositories/gasto_repository.dart';

/// Caso de uso que encapsula la lógica para actualizar un gasto existente.
/// Permite actualizar la descripción, monto, fecha o categoría.
class EditGasto {
  final GastoRepository repository;

  EditGasto(this.repository);

  /// Ejecuta la acción de actualizar el gasto proporcionado.
  /// Devuelve 1 si fue actualizado, 0 si no se encontró coincidencia.
  Future<int> call(Gasto gasto) {
    return repository.actualizarGasto(gasto);
  }
}

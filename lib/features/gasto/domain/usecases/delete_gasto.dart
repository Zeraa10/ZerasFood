import 'package:zerasfood/features/gasto/domain/repositories/gasto_repository.dart';

/// Caso de uso para eliminar un gasto existente por su ID.
/// Encapsula la lógica de eliminación para mantener la separación de capas.
class DeleteGasto {
  final GastoRepository repository;

  DeleteGasto(this.repository);

  /// Ejecuta la acción de eliminar un gasto dado su ID numérico.
  /// Devuelve 1 si se eliminó correctamente, 0 si no se encontró.
  Future<int> call(int id) {
    return repository.eliminarGasto(id);
  }
}

import 'package:zerasfood/features/categoria/domain/repositories/categoria_repository.dart';

/// Caso de uso para eliminar una categoría existente.
/// Se basa en el nombre como identificador (debe ser único).
class DeleteCategoria {
  final CategoriaRepository repository;

  DeleteCategoria(this.repository);

  /// Ejecuta la eliminación de la categoría especificada por su nombre.
  Future<void> call(String nombre) {
    return repository.eliminarCategoria(nombre);
  }
}

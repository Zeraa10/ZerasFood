import 'package:zerasfood/features/categoria/domain/entities/categoria.dart';
import 'package:zerasfood/features/categoria/domain/repositories/categoria_repository.dart';

/// Caso de uso para editar una categoría existente.
/// Se espera que el objeto [Categoria] contenga el ID local o el Firestore ID.
class EditCategoria {
  final CategoriaRepository repository;

  EditCategoria(this.repository);

  /// Ejecuta la actualización de la categoría especificada.
  Future<void> call(Categoria categoria) {
    return repository.editarCategoria(categoria);
  }
}

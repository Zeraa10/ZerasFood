import 'package:zerasfood/features/categoria/domain/repositories/categoria_repository.dart';

/// Caso de uso para agregar una nueva categoría.
/// Encapsula la lógica para insertar una categoría en el repositorio.
class AddCategoria {
  final CategoriaRepository repository;

  /// Recibe una implementación del repositorio para ejecutar la operación.
  AddCategoria(this.repository);

  /// Ejecuta el agregado de una categoría con el nombre y tipo dados.
  Future<void> call(String nombre, String tipo) {
    return repository.agregarCategoria(nombre, tipo);
  }
}

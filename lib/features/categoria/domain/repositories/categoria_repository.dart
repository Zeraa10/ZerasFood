import 'package:zerasfood/features/categoria/domain/entities/categoria.dart';

/// Contrato para las operaciones CRUD relacionadas con la entidad [Categoria].
/// Este repositorio abstrae el origen de los datos (Firestore, SQLite, etc.)
/// y permite trabajar con una capa de dominio desacoplada de la infraestructura.
abstract class CategoriaRepository {
  /// Obtiene la lista de categorías disponibles.
  /// Puede incluir lógica de sincronización entre fuentes (local y remota).
  Future<List<Categoria>> obtenerCategorias();

  /// Agrega una nueva categoría con nombre y tipo.
  /// La implementación debe encargarse de guardarla local y/o remotamente.
  Future<void> agregarCategoria(String nombre, String tipo);

  /// Actualiza los datos de una categoría existente.
  /// Se recomienda que el objeto [Categoria] contenga su `id` y/o `firestoreId`.
  Future<void> editarCategoria(Categoria categoria);

  /// Elimina una categoría identificada por su nombre.
  /// Este campo debe ser único para evitar conflictos.
  Future<void> eliminarCategoria(String nombre);
}

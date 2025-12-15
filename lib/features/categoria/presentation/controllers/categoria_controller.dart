import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerasfood/features/categoria/domain/entities/categoria.dart';
import 'package:zerasfood/features/categoria/domain/repositories/categoria_repository.dart';
import 'package:zerasfood/features/categoria/domain/usecases/add_categoria.dart';
import 'package:zerasfood/features/categoria/domain/usecases/edit_categoria.dart';
import 'package:zerasfood/features/categoria/domain/usecases/delete_categoria.dart';

/// Controlador de categorías que gestiona la lógica de presentación y sincronización.
/// Interactúa con los casos de uso del dominio y notifica cambios a la UI mediante `ValueNotifier`.
class CategoriesController {
  final CategoriaRepository categoriaRepository;
  final AddCategoria addCategoriaUseCase;
  final EditCategoria editCategoriaUseCase;
  final DeleteCategoria deleteCategoriaUseCase;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lista reactiva de categorías actualizadas, usada para reflejar cambios en la interfaz.
  final ValueNotifier<List<Categoria>> categorias = ValueNotifier([]);

  /// Filtro actual aplicado a la lista de categorías (e.g., "ingreso", "gasto", "todos").
  String filtroTipo = 'todos';

  /// Estado del mensaje para mostrar retroalimentación en la UI (éxito o error).
  final ValueNotifier<String?> mensajeEstado = ValueNotifier(null);

  CategoriesController({
    required this.categoriaRepository,
    required this.addCategoriaUseCase,
    required this.editCategoriaUseCase,
    required this.deleteCategoriaUseCase,
  });

  /// Carga categorías desde Firestore, las sincroniza con SQLite y aplica el filtro actual.
  Future<void> cargarCategorias() async {
    final locales = await categoriaRepository.obtenerCategorias();

    final docs = await _firestore.collection('categorias').orderBy('nombre').get();
    final remotas = docs.docs.map((doc) {
      final data = doc.data();
      return Categoria(
        id: null,
        nombre: data['nombre'],
        tipo: data['tipo'],
        firestoreId: doc.id,
      );
    }).toList();

    // Sincroniza categorías nuevas desde Firestore que no existen localmente
    final nombresLocales = locales.map((e) => e.nombre).toSet();
    for (final remota in remotas) {
      if (!nombresLocales.contains(remota.nombre)) {
        await categoriaRepository.agregarCategoria(remota.nombre!, remota.tipo!);
      }
    }

    final actualizadas = await categoriaRepository.obtenerCategorias();
    categorias.value = aplicarFiltro(actualizadas);
  }

  /// Aplica un filtro por tipo de categoría a la lista total.
  List<Categoria> aplicarFiltro(List<Categoria> todas) {
    if (filtroTipo == 'todos') return todas;
    return todas.where((cat) => cat.tipo == filtroTipo).toList();
  }

  /// Cambia el tipo de filtro aplicado y recarga las categorías filtradas.
  void cambiarFiltro(String nuevoFiltro) {
    filtroTipo = nuevoFiltro;
    cargarCategorias();
  }

  /// Agrega una nueva categoría validando que no exista previamente (por nombre).
  Future<void> agregarCategoria(String nombre, String tipo) async {
    try {
      final existentes = categorias.value;
      if (existentes.any((cat) => cat.nombre?.toLowerCase() == nombre.toLowerCase())) {
        mensajeEstado.value = '⚠️ Ya existe una categoría con ese nombre';
        return;
      }

      await addCategoriaUseCase(nombre, tipo);
      mensajeEstado.value = '✅ Categoría agregada con éxito';
      await cargarCategorias();
    } catch (e) {
      debugPrint('Error al agregar categoría: $e');
      mensajeEstado.value = '❌ Error al agregar categoría';
    }
  }

  /// Edita una categoría existente y actualiza la lista visible.
  Future<void> editarCategoria(Categoria categoria) async {
    try {
      await editCategoriaUseCase(categoria);
      mensajeEstado.value = '✅ Categoría actualizada';
      await cargarCategorias();
    } catch (e) {
      debugPrint('Error al editar categoría: $e');
      mensajeEstado.value = '❌ Error al editar categoría';
    }
  }

  /// Elimina una categoría por nombre y actualiza la lista visible.
  Future<void> eliminarCategoria(String nombre) async {
    try {
      await deleteCategoriaUseCase(nombre);
      mensajeEstado.value = '✅ Categoría eliminada';
      await cargarCategorias();
    } catch (e) {
      debugPrint('Error al eliminar categoría: $e');
      mensajeEstado.value = '❌ Error al eliminar categoría';
    }
  }

  /// Libera los recursos de los ValueNotifier cuando el controlador ya no se necesita.
  void dispose() {
    categorias.dispose();
    mensajeEstado.dispose();
  }
}

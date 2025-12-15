import 'package:flutter/material.dart';
import 'package:zerasfood/features/categoria/domain/entities/categoria.dart';
import 'package:zerasfood/features/categoria/presentation/controllers/categoria_controller.dart';
import 'package:zerasfood/injection_container.dart';

/// Pantalla que permite listar, filtrar, agregar, editar y eliminar categorías.
/// Conecta la UI con el [CategoriesController] que maneja la lógica de negocio.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoriesController _controller;

  @override
  void initState() {
    super.initState();

    // Inyección de dependencias vía service locator (sl)
    _controller = CategoriesController(
      categoriaRepository: sl(),
      addCategoriaUseCase: sl(),
      editCategoriaUseCase: sl(),
      deleteCategoriaUseCase: sl(),
    );

    _controller.cargarCategorias(); // Carga inicial

    // Listener para mostrar mensajes de estado (éxito o error)
    _controller.mensajeEstado.addListener(() {
      final mensaje = _controller.mensajeEstado.value;
      if (mensaje != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
        );
        _controller.mensajeEstado.value = null;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera los ValueNotifiers
    super.dispose();
  }

  /// Muestra diálogo para crear una nueva categoría.
  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    String? selectedType;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nueva Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tipo'),
              value: selectedType,
              items: const [
                DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
              ],
              onChanged: (value) => selectedType = value,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && selectedType != null) {
                await _controller.agregarCategoria(nameController.text, selectedType!);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, completa todos los campos')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo para editar una categoría existente.
  Future<void> _showEditCategoryDialog(Categoria categoria) async {
    final nameController = TextEditingController(text: categoria.nombre);
    String? selectedType = categoria.tipo;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tipo'),
              value: selectedType,
              items: const [
                DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
              ],
              onChanged: (value) => selectedType = value,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && selectedType != null) {
                final updated = Categoria(
                  id: categoria.id,
                  nombre: nameController.text,
                  tipo: selectedType!,
                  firestoreId: categoria.firestoreId,
                );
                await _controller.editarCategoria(updated);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, completa todos los campos')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de confirmación antes de eliminar una categoría.
  Future<void> _showDeleteConfirmationDialog(Categoria categoria) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar la categoría "${categoria.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await _controller.eliminarCategoria(categoria.nombre ?? '');
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF81C784), // Verde claro
      ),
      body: Column(
        children: [
          // Filtro desplegable por tipo
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _controller.filtroTipo,
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'ingreso', child: Text('Ingresos')),
                DropdownMenuItem(value: 'gasto', child: Text('Gastos')),
              ],
              onChanged: (value) {
                if (value != null) _controller.cambiarFiltro(value);
              },
            ),
          ),

          // Lista de categorías
          Expanded(
            child: ValueListenableBuilder<List<Categoria>>(
              valueListenable: _controller.categorias,
              builder: (context, categorias, _) {
                return ListView.builder(
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = categorias[index];
                    return ListTile(
                      title: Text(categoria.nombre ?? 'Sin nombre'),
                      subtitle: Text(categoria.tipo == 'ingreso' ? 'Ingreso' : 'Gasto'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditCategoryDialog(categoria),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _showDeleteConfirmationDialog(categoria),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Botón flotante para agregar nueva categoría
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF81C784),
      ),
    );
  }
}

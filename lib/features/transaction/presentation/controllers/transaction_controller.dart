import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:zerasfood/features/categoria/domain/entities/categoria.dart';
import 'package:zerasfood/features/categoria/data/categoria_repository_impl.dart';
import 'package:zerasfood/features/gasto/domain/entities/gasto.dart';
import 'package:zerasfood/features/ingreso/domain/entities/ingreso.dart';

/// Controlador central para gestionar la creación y edición de transacciones (ingresos/gastos).
class TransactionController {
  // Controladores de texto para los campos del formulario
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');

  DateTime selectedDate = DateTime.now();
  bool isIncome = true; // Define si se está manejando un ingreso o un gasto

  List<Categoria> incomeCategories = [];
  Categoria? selectedIncomeCategory;

  final _categoriaService = CategoriaRepositoryImpl();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Ingreso? ingresoEdit;
  Gasto? gastoEdit;

  /// Formato amigable para mostrar la fecha seleccionada
  String get selectedDateFormatted => DateFormat('dd/MM/yyyy').format(selectedDate);

  /// Carga las categorías disponibles desde el repositorio
  Future<void> loadIncomeCategories() async {
    incomeCategories = await _categoriaService.obtenerCategorias();

    for (var cat in incomeCategories) {
      print('🧩 ${cat.nombre} - firestoreId: ${cat.firestoreId}');
    }
  }

  /// Abre un selector de fecha y actualiza el controlador correspondiente
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      locale: const Locale('es', 'CO'),
    );
    if (picked != null) {
      selectedDate = picked;
      dateController.text = selectedDateFormatted;
    }
  }

  /// Carga los datos de un ingreso existente para su edición
  void cargarDatosParaEditarIngreso(Ingreso ingreso, Categoria categoria) {
    isIncome = true;
    ingresoEdit = ingreso;
    selectedIncomeCategory = categoria;

    amountController.text = ingreso.monto.toString();
    noteController.text = ingreso.descripcion ?? '';
    paymentMethodController.text = ingreso.metodoPago ?? '';
    quantityController.text = ingreso.cantidad.toString();
    selectedDate = ingreso.fecha;
    dateController.text = selectedDateFormatted;
  }

  /// Carga los datos de un gasto existente para su edición
  void cargarDatosParaEditarGasto(Gasto gasto) {
    isIncome = false;
    gastoEdit = gasto;

    amountController.text = gasto.monto.toString();
    noteController.text = gasto.descripcion ?? '';
    selectedDate = gasto.fecha;
    dateController.text = selectedDateFormatted;
  }

  /// Guarda una nueva transacción o actualiza una existente en Firestore
  Future<bool> saveTransaction() async {
    final double? amount = double.tryParse(amountController.text);
    final String note = noteController.text.trim();
    final String paymentMethod = paymentMethodController.text.trim();
    final int quantity = isIncome ? int.tryParse(quantityController.text) ?? 1 : 1;
    const int userId = 1; // En producción, esto debe venir del usuario autenticado

    if (amount == null || amount <= 0) return false;

    try {
      if (isIncome) {
        if (selectedIncomeCategory == null) return false;

        final data = {
          'monto': amount,
          'descripcion': note,
          'fecha': selectedDate.toIso8601String(),
          'metodo_pago': paymentMethod.isNotEmpty ? paymentMethod : null,
          'usuario_id': userId,
          'categoria_id': selectedIncomeCategory!.firestoreId,
          'cantidad': quantity,
          'updated_at': FieldValue.serverTimestamp(),
        };

        if (ingresoEdit?.id != null) {
          // Actualización
          await _firestore.collection('ingresos').doc(ingresoEdit!.id).update(data);
        } else {
          // Creación
          data['created_at'] = FieldValue.serverTimestamp();
          await _firestore.collection('ingresos').add(data);
        }
      } else {
        final data = {
          'monto': amount,
          'descripcion': note,
          'fecha': selectedDate.toIso8601String(),
          'usuario_id': userId,
          'updated_at': FieldValue.serverTimestamp(),
        };

        if (gastoEdit?.id != null) {
          await _firestore.collection('gastos').doc(gastoEdit!.id).update(data);
        } else {
          data['created_at'] = FieldValue.serverTimestamp();
          await _firestore.collection('gastos').add(data);
        }
      }

      return true;
    } catch (e) {
      print('Error guardando transacción: $e');
      return false;
    }
  }

  /// Guarda la transacción y muestra una retroalimentación visual (diálogo o snackbar)
  Future<void> saveTransactionWithFeedback(BuildContext context) async {
    final bool esEdicion = isIncome ? ingresoEdit != null : gastoEdit != null;

    final success = await saveTransaction();
    if (!context.mounted) return;

    if (success) {
      final mensaje = esEdicion
          ? 'Transacción actualizada exitosamente.'
          : 'Transacción creada exitosamente.';

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('✅ Éxito'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (context.mounted) Navigator.pop(context); // Regresa a la pantalla anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la transacción'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Libera los recursos de los controladores de texto
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    categoryController.dispose();
    paymentMethodController.dispose();
    dateController.dispose();
    quantityController.dispose();
  }
}

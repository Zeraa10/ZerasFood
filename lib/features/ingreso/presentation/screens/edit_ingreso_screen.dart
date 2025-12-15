import 'package:flutter/material.dart';
import 'package:zerasfood/features/ingreso/domain/entities/ingreso.dart';
import 'package:zerasfood/features/transaction/presentation/controllers/transaction_controller.dart';

/// Pantalla para editar un ingreso existente.
/// Utiliza el controlador [TransactionController] para manejar lógica de formulario y persistencia.
class EditIngresoScreen extends StatefulWidget {
  final Ingreso ingreso; // Objeto ingreso que será editado

  const EditIngresoScreen({super.key, required this.ingreso});

  @override
  State<EditIngresoScreen> createState() => _EditIngresoScreenState();
}

class _EditIngresoScreenState extends State<EditIngresoScreen> {
  final _formKey = GlobalKey<FormState>(); // Llave para validar el formulario
  late final TransactionController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TransactionController();
    _controller.isIncome = true; // Se indica que es ingreso, no gasto

    // Cargar datos del ingreso actual al controlador
    _controller.amountController.text = widget.ingreso.monto.toString();
    _controller.noteController.text = widget.ingreso.descripcion ?? '';
    _controller.paymentMethodController.text = widget.ingreso.metodoPago ?? '';
    _controller.quantityController.text = widget.ingreso.cantidad.toString();
    _controller.selectedDate = widget.ingreso.fecha;
    _controller.dateController.text = _controller.selectedDateFormatted;

    // Cargar categorías de ingreso y seleccionar la correspondiente
    _controller.loadIncomeCategories().then((_) {
      final categoria = _controller.incomeCategories.firstWhere(
        (cat) => cat.id == widget.ingreso.categoriaId,
        orElse: () => _controller.incomeCategories.first,
      );
      _controller.selectedIncomeCategory = categoria;

      _controller.ingresoEdit = widget.ingreso;
      setState(() {}); // Actualiza la vista una vez cargadas las categorías
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A2EDC),
        title: const Text('Editar Ingreso', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Asociar el formulario con la validación
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo: Monto
              TextFormField(
                controller: _controller.amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.add),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa el monto';
                  if (double.tryParse(value) == null) return 'Por favor ingresa un monto válido';
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo: Descripción
              TextFormField(
                controller: _controller.noteController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Campo: Fecha (solo lectura, abre date picker)
              TextFormField(
                controller: _controller.dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () => _controller.pickDate(context),
              ),
              const SizedBox(height: 16.0),

              // Campo: Cantidad de unidades
              TextFormField(
                controller: _controller.quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),

              // Botón: Guardar cambios
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A2EDC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _controller.saveTransactionWithFeedback(context); // Lógica de guardado centralizada
                  }
                },
                child: const Text('Guardar Cambios', style: TextStyle(fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

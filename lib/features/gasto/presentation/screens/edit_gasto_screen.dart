import 'package:flutter/material.dart';
import 'package:zerasfood/features/gasto/domain/entities/gasto.dart';
import 'package:zerasfood/features/transaction/presentation/controllers/transaction_controller.dart';

/// Pantalla para editar un gasto existente.
/// Utiliza el controlador [TransactionController] para gestionar estado y validación del formulario.
class EditGastoScreen extends StatefulWidget {
  final Gasto gasto; // Gasto a editar (recibido por argumento)

  const EditGastoScreen({super.key, required this.gasto});

  @override
  State<EditGastoScreen> createState() => _EditGastoScreenState();
}

class _EditGastoScreenState extends State<EditGastoScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave para validar el formulario
  late final TransactionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransactionController();
    _controller.isIncome = false; // Define que esta pantalla maneja un gasto

    // Prellenar los campos del formulario con los valores existentes
    _controller.amountController.text = widget.gasto.monto.toString();
    _controller.noteController.text = widget.gasto.descripcion ?? '';
    _controller.selectedDate = widget.gasto.fecha;
    _controller.dateController.text = _controller.selectedDateFormatted;

    _controller.gastoEdit = widget.gasto; // Referencia al gasto que se va a editar
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera los controladores de texto
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A2EDC),
        title: const Text('Editar Gasto', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Formulario con validación
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo para el monto del gasto
              TextFormField(
                controller: _controller.amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.remove),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa el monto';
                  if (double.tryParse(value) == null) return 'Por favor ingresa un monto válido';
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo para la descripción opcional
              TextFormField(
                controller: _controller.noteController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),

              // Campo de fecha (solo lectura, abre un selector)
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
              const SizedBox(height: 24.0),

              // Botón para guardar los cambios
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A2EDC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _controller.saveTransactionWithFeedback(context); // Llama al método para guardar
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

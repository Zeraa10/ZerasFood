import 'package:flutter/material.dart';
import 'package:zerasfood/injection_container.dart'; // Inyección de dependencias (GetIt)
import 'package:zerasfood/features/transaction/presentation/controllers/transaction_controller.dart';
import 'package:zerasfood/features/categoria/domain/entities/categoria.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TransactionController controller = sl<TransactionController>(); // Controller inyectado vía GetIt

  @override
  void initState() {
    super.initState();
    controller.dateController.text = controller.selectedDateFormatted;

    // Cargar categorías de ingreso desde SQLite/Firestore y refrescar estado
    controller.loadIncomeCategories().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose(); // Liberar recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de ingresos y gastos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4DB6AC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Selector tipo de transacción: ingreso o gasto
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => controller.isIncome = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: controller.isIncome ? const Color(0xFFE0F2F1) : Colors.grey[300],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
                      ),
                      child: const Center(child: Text('Ingreso')),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => controller.isIncome = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: !controller.isIncome ? const Color(0xFFE0F2F1) : Colors.grey[300],
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
                      ),
                      child: const Center(child: Text('Gasto')),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16.0),

            // Campo de monto (común a ingresos y gastos)
            TextField(
              controller: controller.amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16.0),

            // Campo de cantidad (solo para ingresos)
            if (controller.isIncome)
              TextField(
                controller: controller.quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
              ),

            // Dropdown de categoría (solo para ingresos)
            if (controller.isIncome)
              DropdownButtonFormField<Categoria>(
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                value: controller.selectedIncomeCategory,
                items: controller.incomeCategories.map((Categoria cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.nombre ?? ''));
                }).toList(),
                onChanged: (value) => setState(() => controller.selectedIncomeCategory = value),
              ),

            // Campo de descripción (solo para gastos)
            if (!controller.isIncome)
              TextField(
                controller: controller.categoryController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Gasto',
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 16.0),

            // Dropdown para seleccionar método de pago (solo ingresos)
            if (controller.isIncome)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  border: OutlineInputBorder(),
                ),
                value: controller.paymentMethodController.text.isNotEmpty
                    ? controller.paymentMethodController.text
                    : null,
                items: ['Efectivo', 'Nequi', 'Daviplata'].map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => controller.paymentMethodController.text = value ?? ''),
              ),

            const SizedBox(height: 16.0),

            // Campo para seleccionar fecha (con calendar picker)
            TextField(
              controller: controller.dateController,
              readOnly: true,
              onTap: () => controller.pickDate(context).then((_) => setState(() {})),
              decoration: const InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),

            const SizedBox(height: 16.0),

            // Campo de nota o detalle adicional
            TextField(
              controller: controller.noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nota',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24.0),

            // Botón para guardar la transacción (ingreso o gasto)
            ElevatedButton(
              onPressed: () => controller.saveTransactionWithFeedback(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DB6AC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('Guardar', style: TextStyle(fontSize: 18.0)),
            )
          ],
        ),
      ),
    );
  }
}

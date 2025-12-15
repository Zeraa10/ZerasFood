import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerasfood/features/gasto/domain/entities/gasto.dart';
import 'package:zerasfood/features/ingreso/domain/entities/ingreso.dart';
import 'package:zerasfood/features/categoria/data/categoria_repository_impl.dart';

/// Pantalla principal del usuario que muestra el balance general, 
/// totales de ingresos/gastos y lista de transacciones recientes.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _totalBalance = 0.00;
  double _income = 0.00;
  double _expenses = 0.00;
  List<dynamic> _transactions = [];
  final CategoriaRepositoryImpl _categoriaRepository = CategoriaRepositoryImpl();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Cargar transacciones al iniciar
  }

  /// Carga ingresos y gastos desde Firestore, los combina, 
  /// asocia las categorías desde SQLite y calcula totales.
  Future<void> _loadTransactions() async {
    final ingresosSnapshot = await FirebaseFirestore.instance.collection('ingresos').get();
    final gastosSnapshot = await FirebaseFirestore.instance.collection('gastos').get();
    final categorias = await _categoriaRepository.obtenerCategorias();
    final categoriaMap = {for (var cat in categorias) cat.id: cat};

    final ingresos = ingresosSnapshot.docs.map((doc) {
      final data = doc.data();
      return Ingreso(
        id: doc.id,
        monto: (data['monto'] as num).toDouble(),
        descripcion: data['descripcion'],
        fecha: DateTime.parse(data['fecha']),
        metodoPago: data['metodo_pago'],
        usuarioId: data['usuario_id'],
        categoriaId: data['categoria_id']?.toString(),
        cantidad: data['cantidad'] ?? 1,
      )..categoria = categoriaMap[data['categoria_id']?.toString()];
    }).toList();

    final gastos = gastosSnapshot.docs.map((doc) {
      final data = doc.data();
      return Gasto(
        id: doc.id,
        monto: (data['monto'] as num).toDouble(),
        descripcion: data['descripcion'],
        fecha: DateTime.parse(data['fecha']),
        usuarioId: data['usuario_id'],
        categoriaId: data['categoria_id'],
      )..categoria = categoriaMap[data['categoria_id']];
    }).toList();

    setState(() {
      _transactions = [...ingresos, ...gastos]..sort((a, b) => b.fecha.compareTo(a.fecha));
      _income = ingresos.fold(0.0, (sum, item) => sum + (item.monto * item.cantidad));
      _expenses = gastos.fold(0.0, (sum, item) => sum + item.monto);
      _totalBalance = _income - _expenses;
    });
  }

  /// Recarga las transacciones después de agregar o editar.
  Future<void> _onTransactionAddedOrUpdated() async {
    await _loadTransactions();
  }

  /// Muestra diálogo de confirmación y elimina una transacción si se confirma.
  Future<void> _deleteTransaction(dynamic transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta transacción?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final collection = transaction is Ingreso ? 'ingresos' : 'gastos';
      await FirebaseFirestore.instance.collection(collection).doc(transaction.id).delete();
      await _onTransactionAddedOrUpdated();
    }
  }

  /// Navega a la pantalla correspondiente para editar una transacción.
  void _editTransaction(dynamic transaction) {
    if (transaction is Ingreso) {
      Navigator.pushNamed(context, '/edit_ingreso', arguments: transaction).then((_) => _onTransactionAddedOrUpdated());
    } else if (transaction is Gasto) {
      Navigator.pushNamed(context, '/edit_gasto', arguments: transaction).then((_) => _onTransactionAddedOrUpdated());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A2EDC),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTotalBalanceCard(), // Tarjeta de balance total
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(child: _buildBalanceCard(Icons.arrow_upward, Colors.green, 'Ingresos', _income)),
                const SizedBox(width: 16.0),
                Expanded(child: _buildBalanceCard(Icons.arrow_downward, Colors.orange, 'Gastos', _expenses)),
              ],
            ),
            const SizedBox(height: 24.0),
            const Text('Transacciones', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final isIngreso = tx is Ingreso;
                final fecha = DateFormat('dd/MM/yyyy').format(tx.fecha);
                final cantidad = isIngreso ? tx.cantidad : 1;
                final total = tx.monto * cantidad;
                final icon = isIngreso ? Icons.attach_money : Icons.remove;
                final color = isIngreso ? Colors.green : Colors.orange;
                final title = isIngreso ? (tx.categoria?.nombre ?? 'Ingreso') : (tx.categoria?.nombre ?? 'Gasto');

                return _buildTransactionItem(
                  icon: icon,
                  color: color,
                  title: title,
                  date: fecha,
                  amount: total,
                  isIncome: isIngreso,
                  quantity: isIngreso && cantidad > 1 ? 'Cantidad: $cantidad' : null,
                  description: tx.descripcion,
                  onEdit: () => _editTransaction(tx),
                  onDelete: () => _deleteTransaction(tx),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5A2EDC),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 32), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  /// Tarjeta de balance general total
  Widget _buildTotalBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF5A2EDC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance Total', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('\$${_totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Tarjetas individuales de ingresos y gastos
  Widget _buildBalanceCard(IconData icon, Color color, String label, double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text('\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  /// Widget que construye un ítem visual para cada transacción
  Widget _buildTransactionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String date,
    required double amount,
    required bool isIncome,
    String? quantity,
    String? description,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description != null && description.isNotEmpty)
                  Text(description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.grey)),
                if (quantity != null) Text(quantity, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isIncome ? Colors.green : Colors.orange),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
    );
  }

  /// Manejador de navegación del menú inferior
  void _onNavTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/add_transaction').then((_) => _onTransactionAddedOrUpdated());
        break;
      case 2:
        Navigator.pushNamed(context, '/stats');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }
}

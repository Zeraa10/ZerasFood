import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zerasfood/features/gasto/domain/repositories/gasto_repository.dart';
import 'package:zerasfood/features/ingreso/domain/repositories/ingreso_repository.dart';
import 'package:zerasfood/injection_container.dart';

/// Pantalla encargada de mostrar estadísticas mensuales como:
/// ingresos, gastos, método de pago y producto más vendido.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedMonth = DateFormat('MMMM', 'es_CO').format(DateTime.now());
  double _currentIncome = 0.0;
  double _currentExpenses = 0.0;
  String? _mostSoldCategory;
  double _totalEfectivo = 0.0;
  double _totalNequi = 0.0;
  double _totalDaviplata = 0.0;

  final IngresoRepository _ingresoRepository = sl();
  final GastoRepository _gastoRepository = sl();

  final List<String> _spanishMonths = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _loadMonthlyData(_selectedMonth); // Carga inicial con el mes actual
  }

  /// Carga los datos financieros del mes seleccionado: ingresos, gastos,
  /// ingresos por método de pago y categoría más vendida.
  Future<void> _loadMonthlyData(String mesNombre) async {
    final year = DateTime.now().year;
    final monthIndex = _spanishMonths.indexOf(mesNombre.toLowerCase()) + 1;

    final income = await _ingresoRepository.obtenerTotalIngresosPorMes(year, monthIndex);
    final expenses = await _gastoRepository.obtenerTotalGastosPorMes(year, monthIndex);
    final mostSold = await _ingresoRepository.obtenerCategoriaMasVendidaPorMes(year, monthIndex);
    final totalEfectivo = await _ingresoRepository.obtenerTotalIngresosPorMetodoPago(year, monthIndex, 'Efectivo');
    final totalNequi = await _ingresoRepository.obtenerTotalIngresosPorMetodoPago(year, monthIndex, 'Nequi');
    final totalDaviplata = await _ingresoRepository.obtenerTotalIngresosPorMetodoPago(year, monthIndex, 'Daviplata');

    setState(() {
      _currentIncome = income;
      _currentExpenses = expenses;
      _mostSoldCategory = mostSold;
      _selectedMonth = mesNombre;
      _totalEfectivo = totalEfectivo;
      _totalNequi = totalNequi;
      _totalDaviplata = totalDaviplata;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalLibre = _currentIncome - _currentExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y estadísticas', style: TextStyle(color: Colors.white, fontSize: 22)),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transacciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            // Selector horizontal de meses
            SizedBox(
              height: 44.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _spanishMonths.length,
                itemBuilder: (context, index) {
                  final month = _spanishMonths[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _loadMonthlyData(month),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMonth == month ? const Color(0xFF3F51B5) : Colors.grey[300],
                        foregroundColor: _selectedMonth == month ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: Text(toBeginningOfSentenceCase(month)! ?? '', style: const TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
            const Text('Totales', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            // Resumen de ingresos, gastos y balance libre
            _buildTotalRow('Ingresos', '\$ ${_currentIncome.toStringAsFixed(2)}'),
            _buildTotalRow('Gastos', '\$ ${_currentExpenses.toStringAsFixed(2)}'),
            const SizedBox(height: 16.0),
            _buildTotalRow('Total Libre', '\$ ${totalLibre.toStringAsFixed(2)}', isHighlighted: true),
            const SizedBox(height: 24.0),
            const Text('Más Vendido', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            // Muestra la categoría/producto más vendido del mes
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0), boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mostSoldCategory != null
                        ? 'Categoría/Producto más vendido en $_selectedMonth:'
                        : 'No hay ventas registradas en $_selectedMonth',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 10.0),
                  Text(_mostSoldCategory ?? 'N/A', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            const Text('Resumen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10.0),
            // Tarjeta con detalles generales del mes
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen de ${toBeginningOfSentenceCase(_selectedMonth)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12.0),
                  Text('Ingresos totales: \$ ${_currentIncome.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17)),
                  Text('Gastos totales: \$ ${_currentExpenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17)),
                  Text(
                    'Total libre: \$ ${(_currentIncome - _currentExpenses).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Ingresos por método de pago:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 6.0),
                  Text('• Efectivo: \$ ${_totalEfectivo.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17)),
                  Text('• Nequi: \$ ${_totalNequi.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17)),
                  Text('• Daviplata: \$ ${_totalDaviplata.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17)),
                  if (_mostSoldCategory != null) ...[
                    const SizedBox(height: 12.0),
                    Text('Producto más vendido:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    Text(_mostSoldCategory!, style: const TextStyle(fontSize: 17)),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Construye una fila de resumen para mostrar totales financieros.
  Widget _buildTotalRow(String label, String amount, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHighlighted ? 18.0 : 16.0,
              color: isHighlighted ? const Color(0xFF4CAF50) : Colors.black87,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHighlighted ? 18.0 : 16.0,
              color: isHighlighted ? const Color(0xFF4CAF50) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

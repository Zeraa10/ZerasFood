import 'package:zerasfood/features/gasto/domain/entities/gasto.dart';
import 'package:zerasfood/features/gasto/domain/repositories/gasto_repository.dart';

/// Caso de uso que encapsula la lógica para insertar un nuevo gasto.
/// Permite mantener la lógica de dominio separada de la infraestructura.
class AddGasto {
  final GastoRepository repository;

  AddGasto(this.repository);

  /// Ejecuta la acción de insertar un gasto.
  /// Devuelve un entero indicando el resultado (ej. 1 si fue exitoso).
  Future<int> call(Gasto gasto) {
    return repository.insertarGasto(gasto);
  }
}

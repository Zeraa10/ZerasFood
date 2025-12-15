import 'package:zerasfood/features/ingreso/domain/entities/ingreso.dart';
import 'package:zerasfood/features/ingreso/domain/repositories/ingreso_repository.dart';

/// Caso de uso que permite modificar un ingreso existente.
/// Encapsula la lógica de actualización y la delega al repositorio.
class EditIngreso {
  final IngresoRepository repository;

  EditIngreso(this.repository);

  /// Ejecuta la operación de actualización del ingreso.
  /// Devuelve 1 si fue exitoso, 0 si no se encontró coincidencia.
  Future<int> call(Ingreso ingreso) {
    return repository.actualizarIngreso(ingreso);
  }
}

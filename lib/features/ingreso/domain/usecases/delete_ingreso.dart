import 'package:zerasfood/features/ingreso/domain/repositories/ingreso_repository.dart';

class DeleteIngreso {
  final IngresoRepository repository;

  DeleteIngreso(this.repository);

  Future<int> call(int id) {
    return repository.eliminarIngreso(id);
  }
}

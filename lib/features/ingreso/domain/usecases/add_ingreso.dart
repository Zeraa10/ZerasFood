import 'package:zerasfood/features/ingreso/domain/entities/ingreso.dart';
import 'package:zerasfood/features/ingreso/domain/repositories/ingreso_repository.dart';

class AddIngreso {
  final IngresoRepository repository;

  AddIngreso(this.repository);

  Future<int> call(Ingreso ingreso) {
    return repository.insertarIngreso(ingreso);
  }
}

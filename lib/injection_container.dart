import 'package:get_it/get_it.dart';

// 🔐 Módulo de Autenticación
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

// 💸 Módulo de Gasto
import 'features/gasto/data/gasto_repository_impl.dart';
import 'features/gasto/domain/repositories/gasto_repository.dart';

// 💰 Módulo de Ingreso
import 'features/ingreso/data/ingreso_repository_impl.dart';
import 'features/ingreso/domain/repositories/ingreso_repository.dart';

// 🏷️ Módulo de Categoría
import 'features/categoria/data/categoria_repository_impl.dart';
import 'features/categoria/domain/repositories/categoria_repository.dart';
import 'features/categoria/presentation/controllers/categoria_controller.dart';

// 🔄 Controlador de Transacciones
import 'features/transaction/presentation/controllers/transaction_controller.dart';

// 📦 Casos de uso: Gasto
import 'features/gasto/domain/usecases/add_gasto.dart';
import 'features/gasto/domain/usecases/edit_gasto.dart';
import 'features/gasto/domain/usecases/delete_gasto.dart';

// 📦 Casos de uso: Ingreso
import 'features/ingreso/domain/usecases/add_ingreso.dart';
import 'features/ingreso/domain/usecases/edit_ingreso.dart';
import 'features/ingreso/domain/usecases/delete_ingreso.dart';

// 📦 Casos de uso: Categoría
import 'features/categoria/domain/usecases/add_categoria.dart';
import 'features/categoria/domain/usecases/edit_categoria.dart';
import 'features/categoria/domain/usecases/delete_categoria.dart';

// ⚙️ Configuración del sistema
import 'features/settings/data/configuracion_repository_impl.dart';
import 'features/settings/domain/repositories/configuracion_repository.dart';
import 'features/settings/presentation/controllers/configuracion_controller.dart';

// 🧠 Instancia de GetIt global
final sl = GetIt.instance;

/// Configura todos los servicios y dependencias de la aplicación
Future<void> setupLocator() async {
  // 📁 Repositorios
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<GastoRepository>(() => GastoRepositoryImpl());
  sl.registerLazySingleton<IngresoRepository>(() => IngresoRepositoryImpl());
  sl.registerLazySingleton<CategoriaRepository>(() => CategoriaRepositoryImpl());
  sl.registerLazySingleton<ConfiguracionRepository>(() => ConfiguracionRepositoryImpl());

  // ✅ Casos de uso: Ingreso
  sl.registerLazySingleton(() => AddIngreso(sl()));
  sl.registerLazySingleton(() => EditIngreso(sl()));
  sl.registerLazySingleton(() => DeleteIngreso(sl()));

  // ✅ Casos de uso: Gasto
  sl.registerLazySingleton(() => AddGasto(sl()));
  sl.registerLazySingleton(() => EditGasto(sl()));
  sl.registerLazySingleton(() => DeleteGasto(sl()));

  // ✅ Casos de uso: Categoría
  sl.registerLazySingleton(() => AddCategoria(sl()));
  sl.registerLazySingleton(() => EditCategoria(sl()));
  sl.registerLazySingleton(() => DeleteCategoria(sl()));

  // 👤 Controladores
  sl.registerFactory(() => AuthController(authRepository: sl()));
  sl.registerFactory(() => CategoriesController(
        addCategoriaUseCase: sl(),
        editCategoriaUseCase: sl(),
        deleteCategoriaUseCase: sl(),
        categoriaRepository: sl(),
      ));
  sl.registerFactory(() => TransactionController());
  sl.registerFactory(() => ConfiguracionController(configuracionRepository: sl()));
}

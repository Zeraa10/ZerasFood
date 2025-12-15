import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:zerasfood/injection_container.dart' as di;
import 'package:zerasfood/features/settings/presentation/controllers/configuracion_controller.dart';
import 'package:provider/provider.dart';

// Pantallas (UI)
import 'package:zerasfood/features/auth/presentation/screens/welcome_screen.dart';
import 'package:zerasfood/features/auth/presentation/screens/LoginScreen.dart';
import 'package:zerasfood/features/auth/presentation/screens/registerscreen.dart';
import 'package:zerasfood/features/dashboard/presentation/screens/dashboardscreen.dart';
import 'package:zerasfood/features/transaction/presentation/screens/addtransactionscreen.dart';
import 'package:zerasfood/features/stats/presentation/screens/statsscreen.dart';
import 'package:zerasfood/features/settings/presentation/screens/settingscreen.dart';
import 'package:zerasfood/features/account/presentation/screens/account_screen.dart';
import 'package:zerasfood/features/categoria/presentation/screens/categoriesscreen.dart';
import 'package:zerasfood/features/settings/presentation/screens/helpscreen.dart';
import 'package:zerasfood/features/ingreso/presentation/screens/edit_ingreso_screen.dart';
import 'package:zerasfood/features/gasto/presentation/screens/edit_gasto_screen.dart';

// Entidades utilizadas en rutas con argumentos
import 'package:zerasfood/features/ingreso/domain/entities/ingreso.dart';
import 'package:zerasfood/features/gasto/domain/entities/gasto.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa Firebase con configuración generada
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configura la inyección de dependencias (GetIt)
    await di.setupLocator();
  } catch (e) {
    debugPrint('Error al inicializar Firebase o dependencias: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConfiguracionController>.value(
      // Inyecta el controlador de configuración para proveer acceso global (notificaciones, tema, etc.)
      value: di.sl<ConfiguracionController>(),
      child: MaterialApp(
        title: 'Zera\'s Food',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true), // Usa Material 3 y tema claro
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/add_transaction': (context) => const AddTransactionScreen(),
          '/stats': (context) => const StatsScreen(),
          '/settings': (context) => SettingsScreen(),
          '/account': (context) => const AccountScreen(),
          '/categories': (context) => const CategoriesScreen(),
          '/help': (context) => const HelpScreen(),

          // Rutas con argumentos: se espera recibir un objeto `Ingreso` o `Gasto`
          '/edit_ingreso': (context) => EditIngresoScreen(
                ingreso: ModalRoute.of(context)!.settings.arguments as Ingreso,
              ),
          '/edit_gasto': (context) => EditGastoScreen(
                gasto: ModalRoute.of(context)!.settings.arguments as Gasto,
              ),
        },

        // Soporte para localización en español de Colombia y fallback en inglés
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'CO'),
          Locale('en', ''),
        ],
        locale: const Locale('es', 'CO'),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:zerasfood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:zerasfood/features/settings/presentation/controllers/configuracion_controller.dart';

/// Pantalla de ajustes generales de la aplicación.
/// Permite al usuario gestionar su cuenta, preferencias de notificaciones y navegación a otras secciones.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController _authController = GetIt.I<AuthController>();
  final ConfiguracionController _configController = GetIt.I<ConfiguracionController>();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _inicializarConfiguracion(); // Cargar preferencias al iniciar
  }

  /// Inicializa la configuración desde Firestore si hay un usuario autenticado.
  Future<void> _inicializarConfiguracion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Imprime datos crudos para depuración
    final doc = await FirebaseFirestore.instance.collection('configuracion').doc(uid).get();
    print('📦 Configuración desde Firestore: ${doc.data()}');

    if (uid == null) return;

    await _configController.cargarConfiguracion(uid);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _configController,
      builder: (context, _) {
        final config = _configController.config;

        // Mostrar loader si la configuración está cargando
        if (_configController.isLoading || config == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final displayName = user?.displayName ?? 'Usuario';
        final email = user?.email ?? 'Correo no disponible';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ajustes', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFFF44336), // Rojo
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildUserInfo(displayName, email), // Perfil del usuario
              const SizedBox(height: 24.0),

              // Opciones de navegación
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Cuenta',
                onTap: () => Navigator.pushNamed(context, '/account'),
              ),
              _buildSettingsItem(
                icon: Icons.list_alt,
                title: 'Categorías',
                onTap: () => Navigator.pushNamed(context, '/categories'),
              ),
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: 'Ayuda',
                onTap: () => Navigator.pushNamed(context, '/help'),
              ),

              const Divider(),

              // Notificaciones
              SwitchListTile(
                title: const Text('Notificaciones'),
                value: config.notificaciones,
                onChanged: (value) => _configController.actualizarNotificaciones(value),
                secondary: const Icon(Icons.notifications),
              ),

              const SizedBox(height: 24.0),

              // Botón cerrar sesión
              ElevatedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 18.0)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1C4E9),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Widget para mostrar la información básica del usuario.
  Widget _buildUserInfo(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF5A2EDC),
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Elemento de navegación reutilizable con ícono, texto y flecha.
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 16.0),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16.0))),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16.0),
          ],
        ),
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de cerrar sesión.
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _authController.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A2EDC)),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

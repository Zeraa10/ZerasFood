import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zerasfood/features/auth/data/auth_repository_impl.dart';

/// Pantalla de configuración de cuenta donde el usuario puede
/// ver su información básica, actualizar su nombre y cambiar su contraseña.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthRepositoryImpl _authService = AuthRepositoryImpl(); // Servicio personalizado para lógica de autenticación
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String? _userEmail;
  String? _name;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carga los datos del usuario al iniciar la pantalla
  }

  /// Obtiene la información actual del usuario autenticado desde Firebase
  /// y la muestra en los campos correspondientes.
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;
      _name = user?.displayName;
      _nameController.text = _name ?? '';
    });
  }

  /// Guarda el nuevo nombre ingresado por el usuario en su perfil de Firebase.
  Future<void> _saveName() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty || newName == _name) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no ha sido modificado')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.currentUser!.updateDisplayName(newName);
      setState(() => _name = newName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre actualizado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el nombre: $e')),
      );
    }
  }

  /// Cambia la contraseña del usuario autenticado usando el servicio de autenticación personalizado.
  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa ambas contraseñas')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La nueva contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    bool success = await _authService.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    if (success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authService.errorMessage)),
      );
    }
  }

  /// Construye la interfaz de usuario de la pantalla de cuenta,
  /// permitiendo al usuario ver y modificar su nombre y contraseña.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF64B5F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Información de la Cuenta',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(_name ?? 'Nombre no disponible'),
              subtitle: const Text('Nombre'),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(_userEmail ?? 'Correo electrónico no disponible'),
              subtitle: const Text('Correo Electrónico'),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Editar Nombre',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nuevo Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveName,
              child: const Text('Guardar Nombre'),
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Cambiar Contraseña',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña Actual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Cambiar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}

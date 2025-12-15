import 'package:flutter/material.dart';

/// Pantalla de bienvenida (splash/intermedia) de la app.
/// Presenta el nombre y propósito de la aplicación con un botón de inicio.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A2EDC), // Color de fondo principal (púrpura)
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono central dentro de un contenedor circular amarillo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC727), // Amarillo
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant, // Representa el enfoque gastronómico de la app
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Mensajes de bienvenida
                const Text(
                  "Welcome to",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Zera's Food",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Manage your weekend sales\nwith ease",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 60),

                // Botón de acceso que redirige al login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login'); // Redirección
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC727), // Amarillo
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

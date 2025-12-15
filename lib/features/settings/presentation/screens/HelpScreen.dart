import 'package:flutter/material.dart';

/// Pantalla de ayuda que ofrece soporte e información a los usuarios de la aplicación.
/// Incluye preguntas frecuentes (FAQ) y medios de contacto con soporte técnico.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Encabezado de la pantalla
      appBar: AppBar(
        title: const Text('Ayuda', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4DB6AC), // Color teal
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Título principal
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                '¿Cómo podemos ayudarte?',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),

            // Descripción introductoria
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Si tienes alguna pregunta o necesitas ayuda con la aplicación, consulta la siguiente información de soporte:',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ),

            // Sección de FAQ
            const Text(
              'Preguntas Frecuentes (FAQ)',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),

            // Pregunta 1
            const ExpansionTile(
              title: Text('¿Cómo agrego un nuevo ingreso o gasto?'),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Para agregar una nueva transacción, toca el botón "+" en la pantalla principal. Luego, selecciona si es un ingreso o un gasto, ingresa los detalles (monto, categoría, fecha, etc.) y guarda.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),

            // Pregunta 2
            const ExpansionTile(
              title: Text('¿Cómo edito o elimino una transacción?'),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'En la pantalla del Dashboard o en la sección de Estadísticas, puedes tocar una transacción para ver los detalles. Allí encontrarás opciones para editar o eliminar la transacción.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),

            // Pregunta 3
            const ExpansionTile(
              title: Text('¿Qué significan los colores en las estadísticas?'),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Los colores en las gráficas de estadísticas representan diferentes categorías de ingresos y gastos. Puedes consultar la leyenda para identificar cada categoría.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // Sección de contacto
            const Text(
              'Información de Contacto',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),

            // Correo
            Row(
              children: <Widget>[
                const Icon(Icons.email_outlined),
                const SizedBox(width: 8.0),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('soporte@zerasfood.com'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Sitio web
            Row(
              children: <Widget>[
                const Icon(Icons.web_outlined),
                const SizedBox(width: 8.0),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Sitio Web', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('www.zerasfood.com/ayuda'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Teléfono
            Row(
              children: <Widget>[
                const Icon(Icons.phone_outlined),
                const SizedBox(width: 8.0),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Teléfono de Soporte', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('+57 300 123 4567'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32.0),

            // Mensaje de cierre
            const Text(
              '¡Gracias por usar Zera\'s Food!',
              style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

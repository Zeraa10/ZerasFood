import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerasfood/features/settings/domain/entities/configuracion.dart';
import 'package:zerasfood/features/settings/domain/repositories/configuracion_repository.dart';

/// Implementación del repositorio de configuración de usuario utilizando Firestore.
/// Administra operaciones de lectura, escritura y sincronización (si aplica) de preferencias.
class ConfiguracionRepositoryImpl implements ConfiguracionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene la configuración de un usuario específico desde Firestore.
  /// Usa el `usuarioId` como ID de documento.
  @override
  Future<Configuracion?> obtenerConfiguracion(String usuarioId) async {
    try {
      final doc = await _firestore.collection('configuracion').doc(usuarioId).get();

      if (doc.exists && doc.data() != null) {
        return Configuracion.fromFirestore(doc.data()!, usuarioId);
      }

      return null;
    } catch (e) {
      print('❌ Error al obtener configuración desde Firestore: $e');
      return null;
    }
  }

  /// Guarda o actualiza la configuración del usuario en Firestore.
  /// Utiliza `SetOptions(merge: true)` para evitar sobrescribir campos no incluidos.
  @override
  Future<void> guardarConfiguracion(Configuracion config) async {
    try {
      await _firestore
          .collection('configuracion')
          .doc(config.usuarioId)
          .set(config.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('❌ Error al guardar configuración en Firestore: $e');
    }
  }

  /// Método reservado para sincronizar desde Firestore en caso de usar almacenamiento local.
  /// En este caso, se deja como informativo porque Firestore es la única fuente.
  @override
  Future<void> sincronizarConfiguracionDesdeFirestore(String usuarioId) async {
    print('ℹ️ Firestore ya es la fuente principal. No es necesaria la sincronización local.');
  }
}

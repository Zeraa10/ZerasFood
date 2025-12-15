import 'package:flutter/material.dart';
import 'package:zerasfood/features/settings/domain/entities/configuracion.dart';
import 'package:zerasfood/features/settings/domain/repositories/configuracion_repository.dart';

/// Controlador para manejar el estado de configuración del usuario.
/// Usa [ChangeNotifier] para notificar a la UI cuando cambie la configuración o el estado de carga.
class ConfiguracionController extends ChangeNotifier {
  final ConfiguracionRepository configuracionRepository;

  Configuracion? _config;       // Objeto de configuración actual del usuario
  bool _isLoading = false;      // Estado de carga para mostrar spinners o desactivar UI

  ConfiguracionController({required this.configuracionRepository});

  /// Getter público para acceder a la configuración actual.
  Configuracion? get config => _config;

  /// Indica si hay una operación en curso (ej. cargando o guardando).
  bool get isLoading => _isLoading;

  /// Estado actual de las notificaciones (true por defecto si no hay configuración).
  bool get notificacionesActivas => _config?.notificaciones ?? true;

  /// Carga la configuración del usuario desde el repositorio (por ejemplo, Firestore).
  /// Notifica cambios para que la UI se actualice.
  Future<void> cargarConfiguracion(String usuarioId) async {
    _isLoading = true;
    notifyListeners();

    print('📲 Cargando configuración para UID: $usuarioId');
    _config = await configuracionRepository.obtenerConfiguracion(usuarioId);

    _isLoading = false;
    notifyListeners();
    print('✅ Configuración cargada');
  }

  /// Guarda una nueva configuración en el repositorio y actualiza el estado interno.
  Future<void> guardarConfiguracion(Configuracion config) async {
    _isLoading = true;
    notifyListeners();

    await configuracionRepository.guardarConfiguracion(config);
    _config = config;

    _isLoading = false;
    notifyListeners();
  }

  /// Actualiza solamente el estado de las notificaciones en la configuración actual.
  /// Si la configuración aún no se ha cargado, este método no hace nada.
  Future<void> actualizarNotificaciones(bool activo) async {
    if (_config != null) {
      final nuevaConfig = _config!.copyWith(notificaciones: activo);
      await guardarConfiguracion(nuevaConfig);
    }
  }
}

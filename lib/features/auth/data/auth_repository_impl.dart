import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerasfood/db/database.dart';
import 'package:zerasfood/features/auth/domain/repositories/auth_repository.dart';

/// Función utilitaria que aplica hash SHA-256 a la contraseña para guardarla de forma segura en SQLite y Firestore.
String hashPassword(String password) {
  final bytes = utf8.encode(password.trim());
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Implementación del repositorio de autenticación.
/// Maneja el inicio de sesión, registro, cierre de sesión, y cambio de contraseña.
/// Además, sincroniza datos entre Firebase y SQLite local.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controladores de texto usados para formularios en UI.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Mensajes de error para mostrar al usuario
  String _errorMessage = '';
  String _registerErrorMessage = '';

  @override
  String get errorMessage => _errorMessage;

  @override
  String get registerErrorMessage => _registerErrorMessage;

  /// Inicia sesión con email y contraseña usando Firebase.
  /// Si el usuario existe, sincroniza sus datos con SQLite local.
  @override
  Future<bool> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        _errorMessage = 'No se pudo obtener el usuario autenticado.';
        return false;
      }

      // Consulta Firestore para recuperar datos del usuario
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final db = await DBHelper.database();

        // Evita duplicados en SQLite
        final exists = await db.query(
          'usuarios',
          where: 'correo = ?',
          whereArgs: [user.email],
        );

        if (exists.isEmpty && data != null) {
          await db.insert('usuarios', {
            'nombre': data['nombre'],
            'correo': data['correo'],
            'contrasena': data['contrasena'],
          });
        }
      }

      _errorMessage = '';
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Error desconocido';
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado';
      return false;
    }
  }

  /// Registra un nuevo usuario en Firebase Authentication.
  /// También guarda sus datos en Firestore y SQLite local.
  @override
  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      _registerErrorMessage = 'Las contraseñas no coinciden.';
      return false;
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firebaseAuth.currentUser?.updateDisplayName(name.trim());

      // Guarda datos en Firestore
      await _firestore.collection('usuarios').doc(credential.user?.uid).set({
        'nombre': name.trim(),
        'correo': email.trim(),
        'contrasena': hashPassword(password),
      });

      // Guarda datos en SQLite si no existen previamente
      final db = await DBHelper.database();
      final existing = await db.query(
        'usuarios',
        where: 'correo = ?',
        whereArgs: [email.trim()],
      );

      if (existing.isEmpty) {
        await db.insert('usuarios', {
          'nombre': name.trim(),
          'correo': email.trim(),
          'contrasena': hashPassword(password),
        });
      }

      _registerErrorMessage = '';
      return true;
    } on FirebaseAuthException catch (e) {
      _registerErrorMessage = e.message ?? 'Error desconocido';
      return false;
    }
  }

  /// Cierra la sesión del usuario autenticado.
  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Limpia los controladores del formulario de login.
  @override
  void clearLoginControllers() {
    emailController.clear();
    passwordController.clear();
    _errorMessage = '';
  }

  /// Limpia los controladores del formulario de registro.
  @override
  void clearRegisterControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _registerErrorMessage = '';
  }

  /// Cambia la contraseña del usuario autenticado en Firebase.
  /// Primero requiere reautenticación con la contraseña actual.
  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null || user.email == null) {
        _errorMessage = 'Usuario no autenticado.';
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential); // Verifica identidad
      await user.updatePassword(newPassword); // Aplica la nueva contraseña
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Error desconocido';
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado';
      return false;
    }
  }
}

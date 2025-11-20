import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLogin = true;
  bool isLoading = false;

  User? user;

  String email = '';
  String password = '';

  String? emailError;
  String? passwordError;
  String? generalError;

  void toggleIsLogin() {
    isLogin = !isLogin;
    generalError = null;
    notifyListeners();
  }

  void localValidateEmail(String value) {
    email = value.trim();
    if (value.isEmpty) {
      emailError = null; 
    } else if (!value.contains('@')) {
      emailError = 'Correo no válido';
    } else {
      emailError = null;
    }
  }

  void localValidatePassword(String value) {
    password = value.trim();
    if (value.isEmpty) {
      passwordError = null; 
    } else if (value.length < 6) {
      passwordError = 'Mínimo 6 caracteres';
    } else {
      passwordError = null;
    }
  }

  bool validateTextField() {
    if (email.isEmpty) {
  emailError = 'El correo es obligatorio';
} else if (!email.contains('@')) {
  emailError = 'Correo debe contener @';
} else {
  final parts = email.split('@');

  if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
    emailError = 'Correo no válido';
  } else if (!parts[1].contains('.')) {
    emailError = 'Correo debe contener un dominio válido (ej: gmail.com)';
  } else {
    emailError = null;
  }
}

    if (password.isEmpty) {
      passwordError = 'La contraseña es obligatoria';
    } else if (password.length < 6) {
      passwordError = 'Mínimo 6 caracteres';
    } else {
      passwordError = null;
    }

    notifyListeners(); 

    return emailError == null && passwordError == null;
  }

  Future<void> signIn() async {
    try {
      isLoading = true;
      generalError = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _auth.currentUser!.getIdToken(true);
      
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          generalError = 'No existe un usuario con ese correo.';
          break;
        case 'wrong-password':
          generalError = 'Contraseña incorrecta.';
          break;
        case 'invalid-email':
          generalError = 'Correo inválido.';
          break;
        default:
          generalError = 'Error al iniciar sesión.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading = true;
      generalError = null;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          generalError = 'Este correo ya está registrado.';
          break;
        case 'invalid-email':
          generalError = 'Correo inválido.';
          break;
        case 'weak-password':
          generalError = 'La contraseña es demasiado débil.';
          break;
        default:
          generalError = 'Error al registrar usuario.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
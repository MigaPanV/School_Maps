

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthProvider extends ChangeNotifier{

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLogin = true;
  bool get isLogin => _isLogin;
  bool isLoading = false;

  Future<User?> singIn( String email, String password ) async {
    try{

      isLoading = true;

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      isLoading = false;
      notifyListeners();
      return result.user;

    } catch( e ){

      print( 'Error al iniciar sesion: $e' );
      return null;

    }
  }

  Future<User?> register( String email, String password ) async {
    try{

      isLoading = true;
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      isLoading = false;
      notifyListeners();
      return result.user;
    
    } catch( e ){

      print( 'Error al registrase: $e' );
      return null;

    }
  }

  Future<void> singOut() async {

    await _auth.signOut();
    notifyListeners();

  }

  void toggleisLogin(){
    _isLogin = !_isLogin;
    notifyListeners();
  }
}
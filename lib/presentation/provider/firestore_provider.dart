import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/infrastruture/model/database_padre_model.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FirestoreProvider extends ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // final AuthProvider authProvider = AuthProvider();

  bool isLoading = false;
  bool isUploaded = false;

  String nombrePadre = ''; 
  int? documentoPadre = 0 ;
  String correo = ''; 
  String direccion = ''; 
  List<int>? documentoHijo = [] ;
  String placaRutaAsignada = '';

  String? errorName;

  String documentoHijoTemp = "";

  void getNombreAcudiente( String value ){
    nombrePadre = value;
    errorName = null;
    notifyListeners();
  }

  void getDocumentoAcudiente( String value ){
    documentoPadre = int.tryParse( value );
    errorName = null;
    notifyListeners();
  }
  void getCorreoAcudiente( String value ){
    correo = value;
    errorName = null;
    notifyListeners();
  }
  void getDireccion( String value ){
    direccion = value;
    errorName = null;
    notifyListeners();
  }
  void getDocumentoHijo( String value ){

    documentoHijoTemp = value;
    notifyListeners();
    
  }

  void getPlaca( String value ){
    placaRutaAsignada = value;
    errorName = null;
    notifyListeners();
  }

  void addDocumentoHijo() {
    final entero = int.tryParse(documentoHijoTemp);

    if (entero != null) {
      documentoHijo!.add(entero);
      documentoHijoTemp = "";
      notifyListeners();
    } else {
      errorName = "Documento inválido";
      notifyListeners();
    }
  } 

  Future<void> addPadre() async {

    isLoading = true;
    isUploaded = false;
    notifyListeners();

    try{

      final padre = DatabasePadreModel(
        
        nombrePadre: nombrePadre, 
        documento: documentoPadre!, 
        correo: correo,  
        direccion: direccion, 
        documentoHijo: documentoHijo!, 
        placaRutaAsignada: placaRutaAsignada

      );

      await FirebaseAuth.instance.currentUser?.getIdToken(true);

      final callable = FirebaseFunctions.instance.httpsCallable('createUserWithRole');

      final result = await callable.call({
        "correo": correo.trim(),
        "password": documentoPadre!.toString(),
        "rol": "Padre",
      });

      await firestore.collection( 'Acudientes' ).doc( result.data[ 'uid' ] ).set( {
        ...padre.toFirebase(),
        'rol' : 'Padre'
      } );
      // await assignUserRole( result.data['uid'], 'Padre', correo);


      isUploaded = true;
      isLoading = false;
      notifyListeners();

    }on FirebaseException catch  (e){
      debugPrint( 'Error: ${e.message}'  );
    }
  }

  Future<void> addEstudiante() async {

  }

  Future<void> addConductor() async {

  }

  Future<void> addBus() async {

  }

  Future<String?> getUserRole(String uId ) async{

    DocumentSnapshot userDoc = await firestore.collection('Acudientes').doc( uId ).get();

    if(userDoc.exists){
      return userDoc.get('rol');
    }
    else {
      return null;
    }
  }

  Future<void> assignUserRole(String uId, String rol, String email) async{
    
    await firestore.collection('Acudientes').doc(uId).set({
      'email': email,
      'rol': rol
    });
  }

  Future<Padre> getUserData( String uId ) async {

    DocumentSnapshot documentSnapshot = await firestore.collection( 'Acudientes' ).doc( uId ).get();
    return DatabasePadreModel.fromFirestore( documentSnapshot.data() as Map<String, dynamic> ).toPadreEntity();

  }
}
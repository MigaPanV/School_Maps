import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_maps/infrastruture/model/database_padre_model.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FirestoreProvider extends ChangeNotifier {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // final AuthProvider authProvider = AuthProvider();

  bool isLoading = false;
  bool isUploaded = false;

  String nombrePadre = '';
  String documentoPadre = '';
  String correo = '';
  String direccion = '';
  String documentoHijo = '';
  String placaRutaAsignada = '';
  
  String? errorNombre;
  String? errorDocumento;
  String? errorCorreo;
  String? errorDireccion;
  String? errorDocumentoHijo;
  String? errorPlaca;
  String? errorGeneral;

  bool isLoading = false;

  void getNombreAcudiente(String value) {
    nombrePadre = value.trim();
    errorNombre = null;
    notifyListeners();
  }

  void getDocumentoAcudiente(String value) {
    documentoPadre = value.trim();
    errorDocumento = null;
    notifyListeners();
  }

  String documentoHijoTemp = "";

  void getNombreAcudiente( String value ){
    nombrePadre = value;
    errorName = null;
    notifyListeners();
  }

  void getDireccion(String value) {
    direccion = value.trim();
    errorDireccion = null;
    notifyListeners();
  }

  void getDocumentoHijo(String value) {
    documentoHijo = value.trim();
    errorDocumentoHijo = null;
    notifyListeners();
  }

  void getPlaca(String value) {
    placaRutaAsignada = value.trim();
    errorPlaca = null;
    notifyListeners();
  }

  bool validateForm() {
    bool valid = true;

    if (nombrePadre.isEmpty) {
      errorNombre = "Campo requerido";
      valid = false;
    }
    if (documentoPadre.isEmpty) {
      errorDocumento = "Campo requerido";
      valid = false;
    }
    if (correo.isEmpty || !correo.contains("@")) {
      errorCorreo = "Correo inválido";
      valid = false;
    }
    if (direccion.isEmpty) {
      errorDireccion = "Campo requerido";
      valid = false;
    }
    if (documentoHijo.isEmpty) {
      errorDocumentoHijo = "Campo requerido";
      valid = false;
    }
    if (placaRutaAsignada.isEmpty) {
      errorPlaca = "Campo requerido";
      valid = false;
    }

    notifyListeners();
    return valid;
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
    if (!validateForm()) return;

    try {
      isLoading = true;
      errorGeneral = null;
      notifyListeners();

      final padre = DatabasePadreModel(
        nombrePadre: nombrePadre,
        documento: int.parse(documentoPadre),
        correo: correo,
        direccion: direccion,
        documentoHijo: [int.parse(documentoHijo)],
        placaRutaAsignada: placaRutaAsignada,
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

    } on FirebaseException catch (e) {
      errorGeneral = e.message ?? "Error al guardar en la base de datos";
    } finally {
      isLoading = false;
      notifyListeners();
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
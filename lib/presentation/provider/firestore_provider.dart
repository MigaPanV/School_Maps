import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/infrastruture/model/database_conductor_model.dart';
import 'package:school_maps/infrastruture/model/database_padre_model.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FirestoreProvider extends ChangeNotifier {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool isUploaded = false;

  //* Variables padre

  String nombrePadre = '';
  String documentoPadre = '';
  String correo = '';
  String direccion = '';
  List<int> documentoHijo = [];

  //* Campos conductor

  String nombreConductor = '';
  String documentoConductor = '';
  String correoConductor = '';
  String fechavencimientoLicencia = '';
  
  String placaRutaAsignada = '';
  
  String? errorNombre;
  String? errorDocumento;
  String? errorCorreo;
  String? errorDireccion;
  String? errorDocumentoHijo;
  String? errorPlaca;
  String? errorGeneral;

  // * Funciones Getter padre

  void getNombreAcudiente( String value ) {
    nombrePadre = value.trim();
    errorNombre = null;
    notifyListeners();
  }

  void getDocumentoAcudiente( String value ) {
    documentoPadre = value.trim();
    errorDocumento = null;
    notifyListeners();
  }

  void getCorreoAcudiente( String value ){
    correo = value;
    errorCorreo = null;
    notifyListeners();
  }

  String documentoHijoTemp = "";

  void getDireccion( String value ) {
    direccion = value.trim();
    errorDireccion = null;
    notifyListeners();
  }

  void getDocumentoHijo( String value ) {
    documentoHijoTemp = value;
    errorDocumentoHijo = null;
    notifyListeners();
  }
  
  // * Funciones Getter Conductor

  void getNombreConductor( String value )
  {
    nombreConductor = value.trim();
    notifyListeners();
  }

  void getDocumentoConductor( String value ){
    documentoConductor = value.trim();
    notifyListeners();
  }

  void getCorreoConductor( String value ){
    correoConductor = value.trim();
    notifyListeners();
  }

  void getFechaVencimientoLicencia( String value ){
    fechavencimientoLicencia = value.trim();
    notifyListeners();
  }

  // * Funciones Getter Bus

  void getPlaca( String value ) {
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
      documentoHijo.add(entero);
      documentoHijoTemp = "";
      notifyListeners();
    } else {
      errorNombre = "Documento inválido";
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
        documentoHijo: documentoHijo,
        placaRutaAsignada: placaRutaAsignada,
      );

      await FirebaseAuth.instance.currentUser?.getIdToken(true);

      final callable = FirebaseFunctions.instance.httpsCallable('createFather');

      final result = await callable.call({
        "correo": correo.trim(),
        "password": documentoPadre.toString(),
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

    try{
      isUploaded = false;
      isLoading = true;
      notifyListeners();

      final conductor = DatabaseConductorModel(
        nombreConductor: nombreConductor, 
        documento: int.parse( documentoConductor ), 
        correo: correoConductor, 
        vencimientoLicencia: fechavencimientoLicencia, 
        placaRutaAsignada: placaRutaAsignada
      );

      await FirebaseAuth.instance.currentUser?.getIdToken( true );

      final callable = FirebaseFunctions.instance.httpsCallable('createDriver');

      final result = await callable.call({
        'correo' : correoConductor.trim(),
        'password' : documentoConductor.toString(),
        'rol' : 'Conductor'
      });

      await firestore.collection( 'Conductores' ).doc( result.data[ 'uid' ] ).set({
        ...conductor.toFirestore(),
        'rol' : 'Conductor'
      });

      isUploaded = true;
      isLoading = false;
      notifyListeners();

    }on FirebaseException catch(e){

      errorGeneral = e.message ?? 'Error al guardar en la base de dedatos.';

    }
  }

  Future<void> addBus() async {

  }

  Future<String?> getUserRole(String uId ) async{

    DocumentSnapshot acudienteDoc = await firestore.collection('Acudientes').doc( uId ).get();

    if(acudienteDoc.exists){
      return acudienteDoc.get('rol');
    }

    DocumentSnapshot conductorDoc = await firestore.collection( 'Conductores' ).doc( uId ).get();

    if ( conductorDoc.exists ){
      return conductorDoc.get( 'rol' );
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

  Future<dynamic> getUserData(String uId) async {

    DocumentSnapshot acudienteDoc = await firestore.collection('Acudientes').doc(uId).get();

    if( acudienteDoc.exists ){
      return DatabasePadreModel.fromFirestore(
        acudienteDoc.data() as Map<String, dynamic>
      ).toPadreEntity();
    }

    DocumentSnapshot conductorDoc = await firestore.collection( 'Conductores' ).doc( uId ).get();

    if( conductorDoc.exists ){
      return DatabaseConductorModel.fromFirestore(
        conductorDoc.data() as Map<String, dynamic>
      ).toConductorEntity();
    }

    return null;

  }
}
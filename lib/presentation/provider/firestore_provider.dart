import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_maps/domain/entities/bus.dart';
import 'package:school_maps/domain/entities/conductor.dart';
import 'package:school_maps/domain/entities/estudiante.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/infrastruture/model/database_bus_model.dart';
import 'package:school_maps/infrastruture/model/database_conductor_model.dart';
import 'package:school_maps/infrastruture/model/database_estudiante_model.dart';
import 'package:school_maps/infrastruture/model/database_padre_model.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FirestoreProvider extends ChangeNotifier {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool isUploaded = false;

  //* Variables padre

  String nombrePadre = '';
  int documentoPadre = 0;
  String correo = '';
  String direccion = '';
  List<int> documentoHijo = [];

  //* Variables conductor

  String nombreConductor = '';
  int documentoConductor = 0;
  String correoConductor = '';
  String fechavencimientoLicencia = '';
  
  // *Variables Estudiante

  String nombreEstudiante = '';
  int documentoEstudiante = 0;

  // * Variables Bus
  
  String placaRutaAsignada = '';
  String tecnoVencimiento = '';
  String monitora = '';
  String soatVencimiento = '';
  int capacidad = 0;
  String extintorVencimiento = '';
  int kmRecorridos = 0;
  
  String? errorNombre;
  String? errorDocumento;
  String? errorCorreo;
  String? errorDireccion;
  String? errorDocumentoHijo;
  String? errorPlaca;
  String? errorGeneral;
  String? errorNombreConductor;
  String? errorDocumentoConductor;
  String? errorCorreoConductor;
  String? errorFechaLicencia;
  String? errorPlacaConductor;


  // * Funciones Getter padre

  void getNombreAcudiente( String value ) {
    nombrePadre = value.trim();
    errorNombre = null;
    notifyListeners();
  }

  void getDocumentoAcudiente( String value ) {
    documentoPadre = int.parse( value.trim() );
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

  void getNombreConductor(String value) {
    nombreConductor = value.trim();
    errorNombreConductor = null;
    notifyListeners();
  }

  void getDocumentoConductor(String value) {
    documentoConductor = int.parse( value.trim() );
    errorDocumentoConductor = null;
    notifyListeners();
  }

  void getCorreoConductor(String value) {
    correoConductor = value.trim();
    errorCorreoConductor = null;
    notifyListeners();
  }

  void getFechaVencimientoLicencia(String value) {
    fechavencimientoLicencia = value.trim();
    errorFechaLicencia = null;
    notifyListeners();
  }

  // * Funciones Getter Estudiante

  void getNombreEstudiante( String value ){
    nombreEstudiante = value.trim();
    notifyListeners();
  }

  void getDocumentoEstudiante( String value ){
    documentoEstudiante = int.parse( value.trim() );
    notifyListeners();
  }

  // * Funciones Getter Bus

  void getPlaca(String value) {
    placaRutaAsignada = value.trim();
    errorPlacaConductor = null;
    notifyListeners();
  }

  void getTecnoVencimiento( String value ){
    tecnoVencimiento = value.trim();
    notifyListeners();
  }

  void getMonitora( String value ){
    monitora = value.trim();
    notifyListeners();
  }

  void getSoatVencimiento( String value ){
    soatVencimiento = value. trim();
    notifyListeners();
  }

  void getCapacidad( String value ){
    capacidad = int.parse( value. trim() );
    notifyListeners();
  }

  void getExtintorVencimiento( String value ){
    extintorVencimiento = value.trim();
    notifyListeners();
  }

  void getkmRecorridos( String value ){
    kmRecorridos = int.parse( value. trim() );
    notifyListeners();
  }

  bool validateForm() {
    bool valid = true;

    if (nombrePadre.isEmpty) {
      errorNombre = "Campo requerido";
      valid = false;
    }
    if (documentoPadre == 0) {
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

  bool validateEstudianteForm() {
  bool valid = true;

  if (nombreEstudiante.isEmpty) {
    errorNombre = "Campo requerido";
    valid = false;
  }

  if (documentoEstudiante == 0) {
    errorDocumento = "Campo requerido";
    valid = false;
  }

  if (direccion.isEmpty) {
    errorDireccion = "Campo requerido";
    valid = false;
  }

  if (placaRutaAsignada.isEmpty) {
    errorPlaca = "Campo requerido";
    valid = false;
  }

  notifyListeners();
  return valid;
}

void resetEstudianteFormulario() {
  nombreEstudiante = "";
  documentoEstudiante = 0;
  direccion = "";
  placaRutaAsignada = "";

  errorNombre = null;
  errorDocumento = null;
  errorDireccion = null;
  errorPlaca = null;
  errorGeneral = null;

  isUploaded = false;
  isLoading = false;

  notifyListeners();
}

  void resetPadreFormulario() {
    nombrePadre = '';
    documentoPadre = 0;
    correo = '';
    direccion = '';
    placaRutaAsignada = '';
    
    documentoHijo = [];
    documentoHijoTemp = "";
  
    errorNombre = null;
    errorDocumento = null;
    errorCorreo = null;
    errorDireccion = null;
    errorDocumentoHijo = null;
    errorPlaca = null;
    errorGeneral = null;
  
    isUploaded = false;
    isLoading = false;
  
    notifyListeners();
  }

  void resetConductorFormulario() {
    nombreConductor = "";
    documentoConductor = 0;
    correoConductor = "";
    fechavencimientoLicencia = "";
    placaRutaAsignada = "";

void resetConductorFormulario() {
  nombreConductor = "";
  documentoConductor = 0;
  correoConductor = "";
  fechavencimientoLicencia = "";
  placaRutaAsignada = "";
    errorNombreConductor = null;
    errorDocumentoConductor = null;
    errorCorreoConductor = null;
    errorFechaLicencia = null;
    errorPlacaConductor = null;

    isUploaded = false;
    notifyListeners();
  }

  bool validateConductorForm() {
    bool valid = true;

    if (nombreConductor.isEmpty) {
      errorNombreConductor = "Campo requerido";
      valid = false;
    }

    if (documentoConductor == 0) {
      errorDocumentoConductor = "Campo requerido";
      valid = false;
    }

  if (documentoConductor == 0) {
    errorDocumentoConductor = "Campo requerido";
    valid = false;
  }
    if (correoConductor.isEmpty || !correoConductor.contains("@")) {
      errorCorreoConductor = "Correo inválido";
      valid = false;
    }

    if (fechavencimientoLicencia.isEmpty) {
      errorFechaLicencia = "Campo requerido";
      valid = false;
    }

    if (placaRutaAsignada.isEmpty) {
      errorPlacaConductor = "Campo requerido";
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
      errorDocumento = "Documento inválido";
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
        documento: documentoPadre,
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
      notifyListeners();

    } on FirebaseException catch (e) {

      errorGeneral = e.message ?? "Error al guardar en la base de datos";

    } finally {

      isLoading = false;
      notifyListeners();

    }
  }

  Future<void> addEstudiante() async {
  if (!validateEstudianteForm()) return;

  try {
    isLoading = true;
    isUploaded = false;
    errorGeneral = null;
    notifyListeners();

    final estudiante = DatabaseEstudianteModel(
      nombreEstudiante: nombreEstudiante,
      documento: documentoEstudiante,
      cedulaAcudiente: documentoPadre,
      placaRutaAsignada: placaRutaAsignada,
      direccion: direccion
    );

    await firestore
        .collection('Estudiantes')
        .doc(estudiante.documento.toString())
        .set({
      ...estudiante.toFirestore()
    });

    isUploaded = true;
    notifyListeners();

  } on FirebaseException catch (e) {
    errorGeneral = e.message ?? "Error al guardar en la base de datos";
  } catch (e) {
    errorGeneral = "Error inesperado: ${e.toString()}";
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  Future<void> addConductor() async {
  if (!validateConductorForm()) return;

    try{
      isUploaded = false;
      isLoading = true;
      errorGeneral = null;
      notifyListeners();

      final conductor = DatabaseConductorModel(
        nombreConductor: nombreConductor, 
        documento: documentoConductor, 
        correo: correoConductor, 
        vencimientoLicencia: fechavencimientoLicencia, 
        placaRutaAsignada: placaRutaAsignada
      );

      await FirebaseAuth.instance.currentUser?.getIdToken(true);

      final callable = FirebaseFunctions.instance.httpsCallable('createDriver');

      final result = await callable.call({
        'correo': correoConductor.trim(),
        'password': documentoConductor.toString(),
        'rol': 'Conductor',
      });
      await firestore.collection( 'Conductores' ).doc( result.data[ 'uid' ] ).set({
        ...conductor.toFirestore(),
        'rol' : 'Conductor'
      });

      isUploaded = true;
      notifyListeners();

    } on FirebaseException catch (e) {
      errorGeneral = e.message ?? 'Error al guardar en la base de datos.';
    }finally {

      isLoading = false;
      notifyListeners();
      
    }
  }


  Future<void> addBus() async {

    try{

      isLoading = true;
      isUploaded = false;
      notifyListeners();

      final bus = DatabaseBusModel(
        placa: placaRutaAsignada, 
        nombreConductor: nombreConductor, 
        tecnoVencimiento: tecnoVencimiento, 
        soatVencimiento: soatVencimiento, 
        monitora: monitora, 
        capacidad: capacidad, 
        extintorVencimiento: extintorVencimiento, 
        kmRecorridos: kmRecorridos
      );

      await firestore.collection( 'Buses' ).doc( bus.placa ).set({
        ...bus.toFirestore()
      });

      isUploaded = true;

    } on FirebaseException catch (e){
      errorGeneral = e.message ?? 'Error al guardar en la base de datos.';
    } finally {

      isLoading = false;
      notifyListeners();
    }

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

    DocumentSnapshot rectorDoc = await firestore.collection( 'Rector' ).doc( uId ).get();

    if ( rectorDoc.exists ){
      return rectorDoc.get( 'rol' );
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

  Future<List<Padre>> getPadres() async {
    final snapshot = await FirebaseFirestore.instance
      .collection('Acudientes')
      .get();

    return snapshot.docs
        .map((doc) => DatabasePadreModel.fromFirestore(doc.data()).toPadreEntity())
        .toList();
  }

  Future<List<Conductor>> getConductores() async {
    final snapshot = await FirebaseFirestore.instance
      .collection('Conductores')
      .get();

    return snapshot.docs
        .map((doc) => DatabaseConductorModel.fromFirestore(doc.data()).toConductorEntity())
        .toList();
  }

  Future<List<Estudiante>> getEstudiantes( int documentoPadre ) async {
    final snapshot = await FirebaseFirestore.instance
      .collection('Estudiantes')
      .where('cedulaAcudiente', isEqualTo: documentoPadre)
      .get();

    return snapshot.docs
        .map((doc) => DatabaseEstudianteModel.fromFirestore(doc.data()).toEstudianteEntity())
        .toList();
  }

  Future<List<Bus>> getBuses() async {
    try{
      final snapshot = await FirebaseFirestore.instance
        .collection('Buses')
        .get();

    return snapshot.docs
        .map((doc) => DatabaseBusModel.fromFirestore(doc.data()).toBusEntity())
        .toList();
    } on FirebaseException catch ( e ){
      throw Exception('Error al obtener los buses: ${ e.message }');
    }
  }
}
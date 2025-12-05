import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:school_maps/constants.dart';
import 'package:school_maps/domain/entities/bus.dart';
import 'package:school_maps/domain/entities/conductor.dart';
import 'package:school_maps/domain/entities/estudiante.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/infrastruture/model/database_bus_model.dart';
import 'package:school_maps/infrastruture/model/database_conductor_model.dart';
import 'package:school_maps/infrastruture/model/database_estudiante_model.dart';
import 'package:school_maps/infrastruture/model/database_padre_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';


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
  int? grado = 0;

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
  String? errorGrado;
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

  void getGrado( value ){
    grado = value!;
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
    // if (documentoHijo.isEmpty) {
    //   errorDocumentoHijo = "Campo requerido";
    //   valid = false;
    // }
    // if (placaRutaAsignada.isEmpty) {
    //   errorPlaca = "Campo requerido";
    //   valid = false;
    // }

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
  if ( grado == 0 ) {
    errorGrado = "Campo requerido";
    valid = false;
  }

  // if (placaRutaAsignada.isEmpty) {
  //   errorPlaca = "Campo requerido";
  //   valid = false;
  // }

  notifyListeners();
  return valid;
}

void resetEstudianteFormulario() {
  nombreEstudiante = "";
  documentoEstudiante = 0;
  direccion = "";
  placaRutaAsignada = "";
  grado == 0;

  errorNombre = null;
  errorDocumento = null;
  errorDireccion = null;
  errorPlaca = null;
  errorGeneral = null;
  errorGrado == null;

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

      await FirebaseAuth.instance.currentUser?.getIdToken(true);

      final callable = FirebaseFunctions.instance.httpsCallable('createFather');

      final result = await callable.call({
        "correo": correo.trim(),
        "password": documentoPadre.toString(),
        "rol": "Padre",
      });

      DatabasePadreModel padre = DatabasePadreModel(
        nombre: nombrePadre,
        documento: documentoPadre,
        correo: correo,
        direccion: direccion,
        uId: result.data[ 'uid' ],
        // documentoHijo: documentoHijo,
        // placaRutaAsignada: placaRutaAsignada,
      );

      final estudiantesEncontrado = await getEstudiantes(padre.documento);

      if( estudiantesEncontrado.isNotEmpty ){
        for( int i = 0; i < estudiantesEncontrado.length; i++ ){
          documentoHijo.add( estudiantesEncontrado[i].documento);
        }

        padre = DatabasePadreModel(
        nombre: nombrePadre,
        documento: documentoPadre,
        correo: correo,
        direccion: direccion,
        uId: result.data[ 'uid' ],
        documentoHijo: documentoHijo,
        // placaRutaAsignada: placaRutaAsignada,
        );
     }

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

      LatLng? coords = await geocodeAddress(direccion);

        if (coords == null) {
        errorGeneral = "No se pudo encontrar la dirección.";
        isLoading = false;
        notifyListeners();
        return;
      }

      final padres = await getPadres();

      final estudiante = DatabaseEstudianteModel(
        nombreEstudiante: nombreEstudiante,
        documento: documentoEstudiante,
        grado: grado!,
        lat: coords.latitude,
        lng: coords.longitude,
        cedulaAcudiente: documentoPadre,
        // placaRutaAsignada: placaRutaAsignada,
        direccion: direccion
      );

      Padre? padreEncontrado = padres.firstWhereOrNull(
        (p) => p.documento == estudiante.cedulaAcudiente,
      );

      if( padreEncontrado != null ){
        padreEncontrado.documentoHijo.add( estudiante.documento );

        await firestore.collection( 'Acudientes' ).doc( padreEncontrado.uId ).update( { 'documentoHijo' : padreEncontrado.documentoHijo} );
      }
        
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

  Future<Map< String, List<Estudiante>>> getEstudiantesAll() async{
    try{
      final sinRutaSnap = await firestore.collection( 'Estudiantes' ).where( 'placa', isEqualTo: '' ).orderBy( 'grado' ).get();
      final conRutaSnap = await firestore.collection( 'Estudiantes' ).where( 'placa', isGreaterThan: '' ).orderBy( 'grado' ).get();

      final sinRutaEstudiantes = sinRutaSnap.docs
          .map((doc) => DatabaseEstudianteModel.fromFirestore(doc.data()).toEstudianteEntity())
          .toList();
      final conRutaEstudiantes = conRutaSnap.docs
          .map((doc) => DatabaseEstudianteModel.fromFirestore(doc.data()).toEstudianteEntity())
          .toList();

      return {
        'sinRuta' : sinRutaEstudiantes,
        'conRuta' : conRutaEstudiantes,
      };

    }on FirebaseException catch ( e ){
      throw Exception('Error al obtener los estudiantes: ${ e.message }');
    }
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

  Future<void> guardarRutaAsignada({
    required String conductor,
    required String ruta,
    required Padre padre,
    required String hijo,
    required LatLng destino,
  }) async {
    try {
      /// 1. Traer estudiantes del padre (para obtener dirección del hijo)
      final estudiantesSnapshot = await FirebaseFirestore.instance
          .collection("estudiantes")
          .where("documentoPadre", isEqualTo: padre.documento)
          .get();

      String? direccionHijo;

      for (var e in estudiantesSnapshot.docs) {
        if (e["nombreEstudiante"] == hijo) {
          direccionHijo = e["direccion"];
          break;
        }
      }

      /// Si el hijo no tiene dirección, usar la del padre
      direccionHijo ??= padre.direccion;

      /// 2. Crear documento de ruta
      await FirebaseFirestore.instance.collection("rutasAsignadas").add({
        "conductor": conductor,
        "bus": ruta,

        "padreNombre": padre.nombre,
        "padreDocumento": padre.documento,
        "padreDireccion": padre.direccion,

        "estudianteNombre": hijo,
        "estudianteDireccion": direccionHijo,

        "destino": {
          "lat": destino.latitude,
          "lng": destino.longitude,
        },

        "fechaCreacion": FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print("❌ Error guardando ruta asignada: $e");
      rethrow;
    }
  }
  Future<void> guardarRutaGenerada({
    required String placaBus,
    required int capacidadBus,
    required List<Estudiante> estudiantes,
  }) async {

    final rutaDoc = await firestore.collection("RutasGeneradas").doc(placaBus).get();

    int cantidadActual = 0;

    if (rutaDoc.exists) {
      final data = rutaDoc.data()!;
      final listaActual = (data['estudiantes'] as List?) ?? [];
      cantidadActual = listaActual.length;
    }

    final cantidadNueva = estudiantes.length;
    final total = cantidadActual + cantidadNueva;

    if (total > capacidadBus) {
      throw Exception(
        "La ruta ya tiene $cantidadActual estudiantes. "
        "No puedes agregar $cantidadNueva más porque superan la capacidad del bus ($capacidadBus)."
      );
    }

    /// --- 2. Preparar estudiantes nuevos a agregar ---
    List<Map<String, dynamic>> estudiantesParaAgregar = estudiantes.map((e) {
      return {
        "nombre": e.nombreEstudiante,
        "documento": e.documento,
        "direccion": e.direccion,
        "cedulaAcudiente": e.cedulaAcudiente,
      };
    }).toList();


    /// --- 3. Crear o actualizar la ruta CONTINUANDO la lista ---
    if (!rutaDoc.exists) {
      /// Si la ruta NO existe → la creamos
      await firestore.collection("RutasGeneradas").doc(placaBus).set({
        "placa": placaBus,
        "fechaCreacion": DateTime.now(),
        "estudiantes": estudiantesParaAgregar,
      });
    } else {
      /// Si la ruta ya existe → agregamos SIN sobrescribir
      await firestore.collection("RutasGeneradas").doc(placaBus).update({
        "estudiantes": FieldValue.arrayUnion(estudiantesParaAgregar),
      });
    }


    /// ASIGNAR PLACA A CADA ESTUDIANTE Y ACUDIENTE
    for (final est in estudiantes) {
      final estudianteRef = firestore.collection("Estudiantes").doc(est.documento.toString());
      final acudienteQuery = await firestore
          .collection("Acudientes")
          .where('documentoPadre', isEqualTo: est.cedulaAcudiente)
          .limit(1)
          .get();

      /// ACTUALIZAR ESTUDIANTE
      await estudianteRef.update({
        'placa': placaBus,
      });

      /// ACTUALIZAR ACUDIENTE (SI EXISTE)
      if (acudienteQuery.docs.isNotEmpty) {
        await acudienteQuery.docs.first.reference.update({
          'placa': placaBus,
        });
      }
    }
  }

  Future<LatLng?> geocodeAddress(String address) async {
    final apiKey = google_api_key;
    final encoded = Uri.encodeQueryComponent(address);
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?address=$encoded&key=$apiKey"
    );

    final response = await http.get(url);

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);

    if (data["status"] != "OK") return null;

    final location = data["results"][0]["geometry"]["location"];

    return LatLng(location["lat"], location["lng"]);
  }
}
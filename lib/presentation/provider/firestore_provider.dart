import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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


  void limpiarErrores() {
  errorNombre = null;
  errorDocumento = null;
  errorCorreo = null;
  errorDireccion = null;
  errorDocumentoHijo = null;
  errorPlaca = null;
  errorGeneral = null;
  errorNombreConductor = null;
  errorDocumentoConductor = null;
  errorCorreoConductor = null;
  errorFechaLicencia = null;
  errorPlacaConductor = null;

  notifyListeners();
}

  void getNombreAcudiente( String value ) {
    nombrePadre = value.trim();
    errorNombre = null;
    notifyListeners();
  }

  void getDocumentoAcudiente(String value) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null) {
    documentoPadre = 0;
    errorDocumento = "Documento inválido";
  } else {
    documentoPadre = parsed;
    errorDocumento = null;
  }
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
  final parsed = int.tryParse(value.trim());
  if (parsed == null) {
    documentoConductor = 0;
    errorDocumentoConductor = "Documento inválido";
  } else {
    documentoConductor = parsed;
    errorDocumentoConductor = null;
  }
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

  void getDocumentoEstudiante(String value) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null) {
    documentoEstudiante = 0;
    errorDocumentoHijo = "Documento inválido";
  } else {
    documentoEstudiante = parsed;
    errorDocumentoHijo = null;
  }
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

  void getCapacidad(String value) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null) {
    capacidad = 0;
    errorPlaca = "Capacidad inválida";
  } else {
    capacidad = parsed;
    errorPlaca = null;
  }
  notifyListeners();
}

  void getExtintorVencimiento( String value ){
    extintorVencimiento = value.trim();
    notifyListeners();
  }

  void getkmRecorridos(String value) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null) {
    kmRecorridos = 0;
    errorPlaca = "Km inválidos";
  } else {
    kmRecorridos = parsed;
    errorPlaca = null;
  }
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

      final padres = await getPadres();

      final estudiante = DatabaseEstudianteModel(
        nombreEstudiante: nombreEstudiante,
        documento: documentoEstudiante,
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
      limpiarErrores();
      notifyListeners();
    }
  }

  Future<bool> addConductor() async {
  if (!validateConductorForm()) return false;

  try {
    isUploaded = false;
    isLoading = true;
    errorGeneral = null;
    notifyListeners();

    final conductor = DatabaseConductorModel(
      nombreConductor: nombreConductor,
      documento: documentoConductor,
      correo: correoConductor,
      vencimientoLicencia: fechavencimientoLicencia,
      placaRutaAsignada: placaRutaAsignada,
    );

    // Refresco token (opcional)
    await FirebaseAuth.instance.currentUser?.getIdToken(true);

    final callable = FirebaseFunctions.instance.httpsCallable('createDriver');

    final result = await callable.call({
      'correo': correoConductor.trim(),
      'password': documentoConductor.toString(),
      'rol': 'Conductor',
    });

    await firestore.collection('Conductores').doc(result.data['uid']).set({
      ...conductor.toFirestore(),
      'rol': 'Conductor'
    });

    isUploaded = true;
    return true;
  } on FirebaseException catch (e, st) {
    // Guardar y mostrar error para la UI y logs
    errorGeneral = e.message ?? 'Error al guardar en la base de datos.';
    debugPrint('addConductor FirebaseException: ${e.message}');
    debugPrintStack(stackTrace: st);
    return false;
  } catch (e, st) {
    errorGeneral = 'Error inesperado: ${e.toString()}';
    debugPrint('addConductor Exception: $e');
    debugPrintStack(stackTrace: st);
    return false;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  Future<bool> addBus() async {
  try {
    isLoading = true;
    isUploaded = false;
    errorGeneral = null;
    notifyListeners();

    final bus = DatabaseBusModel(
      placa: placaRutaAsignada,
      nombreConductor: nombreConductor,
      tecnoVencimiento: tecnoVencimiento,
      soatVencimiento: soatVencimiento,
      monitora: monitora,
      capacidad: capacidad,
      extintorVencimiento: extintorVencimiento,
      kmRecorridos: kmRecorridos,
    );

    // Validación extra: placa no vacía
    if (bus.placa.isEmpty) {
      errorGeneral = 'La placa es requerida para crear el bus.';
      return false;
    }

    await firestore.collection('Buses').doc(bus.placa).set({
      ...bus.toFirestore()
    });

    isUploaded = true;
    return true;
  } on FirebaseException catch (e, st) {
    errorGeneral = e.message ?? 'Error al guardar en la base de datos.';
    debugPrint('addBus FirebaseException: ${e.message}');
    debugPrintStack(stackTrace: st);
    return false;
  } catch (e, st) {
    errorGeneral = 'Error inesperado: ${e.toString()}';
    debugPrint('addBus Exception: $e');
    debugPrintStack(stackTrace: st);
    return false;
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

  Future<List<Estudiante>> getEstudiantesAll() async{
    try{
      final snapshot = await FirebaseFirestore.instance
      .collection('Estudiantes')
      .get();

      return snapshot.docs
          .map((doc) => DatabaseEstudianteModel.fromFirestore(doc.data()).toEstudianteEntity())
          .toList();
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
  required List<Estudiante> estudiantes,
}) async {
  final firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> listaEstudiantes = estudiantes.map((e) {
    return {
      "nombre": e.nombreEstudiante,
      "documento": e.documento,
      "direccion": e.direccion,
    };
  }).toList();

  await firestore.collection("RutasGeneradas").doc(placaBus).set({
    "placa": placaBus,
    "estudiantes": listaEstudiantes,
    "fechaCreacion": DateTime.now(),
  });
}
}
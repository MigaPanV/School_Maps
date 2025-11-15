import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/infrastruture/model/database_padre_model.dart';

class FirestoreProvider extends ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String nombrePadre = ''; 
  int? documentoPadre = 0 ;
  String correo = ''; 
  String direccion = ''; 
  List<int>? documentoHijo = [] ;
  String placaRutaAsignada = '';

  String? errorName;

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

    final entero = int.tryParse( value );

    if( entero != null ){
      documentoHijo?.add( entero );
      errorName = null;
    }
    else{
      errorName = 'Documento de invalido';
    }
    notifyListeners();
    
  }
  void getPlaca( String value ){
    placaRutaAsignada = value;
    errorName = null;
    notifyListeners();
  }

  Future<void> addPadre() async {
    try{

      final padre = DatabasePadreModel(
        
        nombrePadre: nombrePadre, 
        documento: documentoPadre!, 
        correo: correo,  
        direccion: direccion, 
        documentoHijo: documentoHijo!, 
        placaRutaAsignada: placaRutaAsignada

      );

      await firestore.collection( 'Acudientes' ).doc( documentoPadre.toString() ).set( padre.toFirebase() );

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
}
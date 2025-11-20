import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_maps/infrastruture/model/database_padre_model.dart';

class FirestoreProvider extends ChangeNotifier {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  void getCorreoAcudiente(String value) {
    correo = value.trim();
    errorCorreo = null;
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

      await firestore
          .collection('Acudientes')
          .doc(documentoPadre)
          .set(padre.toFirebase());

    } on FirebaseException catch (e) {
      errorGeneral = e.message ?? "Error al guardar en la base de datos";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
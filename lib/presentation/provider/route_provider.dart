import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:school_maps/constants.dart';

class RouteProvider extends ChangeNotifier {

  String? busSeleccionado;

  Map<String, dynamic>? rutaIda;
  Map<String, dynamic>? rutaVuelta;

  bool mostrarIda = true;
  LatLng? ubicacionConductor;

  List<LatLng> polylinePoints = [];
  List<LatLng> paradas = [];
  bool cargando = false;

  Future<void> cargarRuta({
    required String placa,
    required String tipoRuta, // "ida" o "vuelta"
  }) async {
    try {
      cargando = true;
      notifyListeners();

      final snap = await FirebaseFirestore.instance
          .collection("RutasGeneradas")
          .doc(placa)
          .collection(tipoRuta)
          .doc("ruta")
          .get();

      if (!snap.exists) {
        throw "La ruta no existe";
      }

      final encodedPolyline = snap["polyline"];
      final rawParadas = snap["paradas"];

      /// Decode polyline
      final decoded = PolylinePoints.decodePolyline(encodedPolyline);

      polylinePoints = decoded
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();

      /// Convertir paradas a LatLng
      paradas = (rawParadas as List)
          .map((e) => LatLng(e["lat"], e["lng"]))
          .toList();

      cargando = false;
      notifyListeners();
    } catch (e) {
      cargando = false;
      notifyListeners();
      print("ERROR AL CARGAR RUTA: $e");
    }
  }


  // El rector selecciona un bus
  void setBusSeleccionado(String placa) {
    busSeleccionado = placa;
    notifyListeners();
  }

  // Guardar rutas
  void setRutaIda(Map<String, dynamic> data) {
    rutaIda = data;
    notifyListeners();
  }

  void setRutaVuelta(Map<String, dynamic> data) {
    rutaVuelta = data;
    notifyListeners();
  }

  // El conductor decide si ver ida o vuelta
  void cambiarTipoRuta(bool ida) {
    mostrarIda = ida;
    notifyListeners();
  }

  // Seguimiento del conductor
  void actualizarUbicacionConductor(LatLng pos) {
    ubicacionConductor = pos;
    notifyListeners();
  }

  Future<List<LatLng>> procesarDirecciones(List<Map<String, dynamic>> estudiantes) async {
    List<LatLng> puntos = [];

    for (var est in estudiantes) {
      final direccion = est['direccion'];
      final coord = await geocodeAddress( direccion );
      if (coord != null) puntos.add(coord);
    }

    return puntos;
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
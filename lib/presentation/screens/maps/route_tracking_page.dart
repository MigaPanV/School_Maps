import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_maps/constants.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;


class RouteTrackingPage extends StatefulWidget {
  const RouteTrackingPage({super.key});

  @override
  State<RouteTrackingPage> createState() => _RouteTrackingPageState();
}

class _RouteTrackingPageState extends State<RouteTrackingPage> {

  GoogleMapController? _mapController;

  static const LatLng sourceLocation = LatLng(4.60971, -74.08175);
  static const LatLng destination = LatLng(4.1420, -73.6266);

  LocationData? currentLocation;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};

  StreamSubscription<LocationData>? _locationSubscription;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    pedirPermisos();
    setCustomMarkerIcon();
    getCurrentLocation();
    getPolyPoints();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();

    if (_mapController != null) {
      // SOLO Android/iOS pueden llamar dispose
      // En Web causa error
      try {
        _mapController!.dispose();
      } catch (_) {}
    }

    super.dispose();
  }


  // ----------------------------
  //  UBICACIÓN EN TIEMPO REAL
  // ----------------------------

  void getCurrentLocation() async {

    Location location = Location();
    currentLocation = await location.getLocation();

    // ESCUCHAR UBICACIÓN
    _locationSubscription = location.onLocationChanged.listen((newLoc) async {

      if (!mounted) return;

      currentLocation = newLoc;
      setState(() {});

      // Solo mover cámara si el mapa está creado y montado
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 14.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
      }
    });
  }

  // ----------------------------
  //  PERMISOS
  // ----------------------------

  Future<void> pedirPermisos() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
      print("Permiso de localización denegado");
    }
  }

  // ----------------------------
  //  POLILÍNEAS
  // ----------------------------

  void getPolyPoints() async {
    try {
      final url = Uri.parse(
        "https://us-central1-school-maps-e69f3.cloudfunctions.net/getRoute",
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "origin": "${sourceLocation.latitude},${sourceLocation.longitude}",
          "destination": "${destination.latitude},${destination.longitude}",
        }),
      );

      final data = json.decode(response.body);

      if (data["routes"] == null || data["routes"].isEmpty) {
        print("⚠ GOOGLE NO DEVOLVIÓ RUTAS");
        return;
      }
      
      final points = data["routes"][0]["overview_polyline"]["points"];

      List<PointLatLng> decoded = PolylinePoints.decodePolyline(points);

      polylineCoordinates =
          decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();

      polylines = {
        Polyline(
          polylineId: PolylineId("route"),
          width: 6,
          color: Colors.blue,
          points: polylineCoordinates,
        ),
      };

      setState(() {});
    } catch (e) {
      print("ERROR AL OBTENER RUTA: $e");
    }
  }

  // ----------------------------
  //  ICONOS / PINES
  // ----------------------------

  Future<BitmapDescriptor> getResizedMarker(String assetPath, int width) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final frame = await codec.getNextFrame();
    final bytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  } 

  void setCustomMarkerIcon() async {
    sourceIcon = await getResizedMarker('assets/images/login.jpg', 90);
    destinationIcon = await getResizedMarker('assets/images/login.jpg', 90);
    currentLocationIcon = await getResizedMarker('assets/images/login.jpg', 70);

    setState(() {});
  }

  // ----------------------------
  //  UI DE MAPA
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? Center(child: Text('Cargando...'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ),
                zoom: 14.5,
              ),
              polylines: polylines,
              markers: {
                Marker(
                  markerId: MarkerId('currentLocation'),
                  icon: currentLocationIcon,
                  position: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                ),
                Marker(
                  markerId: MarkerId('source'),
                  icon: sourceIcon,
                  position: sourceLocation,
                ),
                Marker(
                  markerId: MarkerId('destination'),
                  icon: destinationIcon,
                  position: destination,
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
    );
  }
}
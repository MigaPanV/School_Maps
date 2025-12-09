import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/presentation/provider/route_provider.dart';


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
  Set<Marker> markers = {};


  List<LatLng> listaDeParadas = [];

  StreamSubscription<LocationData>? _locationSubscription;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    pedirPermisos();
    // setCustomMarkerIcon();
    iniciarTodo();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> iniciarTodo() async {
    await getCurrentLocation();     // ⬅ Espera ubicación
    await cargarParadasDesdeFirestore(); // ⬅ Ahora sí calcula ruta
  }

  Future<void> cargarParadasDesdeFirestore() async {
    
    final snapshot = await FirebaseFirestore.instance.collection("Estudiantes").get();

    listaDeParadas = snapshot.docs.map((d) {
      return LatLng(d["lat"], d["lng"]);
    }).toList();

    print("Paradas cargadas: ${listaDeParadas.length}");

    for (int i = 0; i < listaDeParadas.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId("parada_$i"),
          position: listaDeParadas[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: "Parada ${i + 1}"),
        ),
      );
    }
    setState(() {});

    await getPolyPoints(listaDeParadas);
  }


  // ----------------------------
  //  UBICACIÓN EN TIEMPO REAL
  // ----------------------------

  Future<void> getCurrentLocation() async {

    Location location = Location();
    currentLocation = await location.getLocation();

    setState(() {}); // actualiza UI

    _locationSubscription = location.onLocationChanged.listen((newLoc) async {
      if (!mounted) return;

      currentLocation = newLoc;
      setState(() {});

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 14.5,
              target: LatLng(newLoc.latitude!, newLoc.longitude!),
            ),
          ),
        );
      }
    });

    markers.add( Marker(
      markerId: MarkerId('currentLocation'),
      position: LatLng(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
      ),
      icon: currentLocationIcon,
      ), 
    );
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

  Future<void> getPolyPoints(List<LatLng> stops) async {
    if (currentLocation == null) return; // evita null

    try {
      final url = Uri.parse(
        "https://us-central1-school-maps-e69f3.cloudfunctions.net/computeRoute",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "origin": {
            "lat": currentLocation!.latitude!,
            "lng": currentLocation!.longitude!,
          },
          "destination": {
            "lat": destination.latitude,
            "lng": destination.longitude,
          },
          "stops": stops
              .map((s) => {"lat": s.latitude, "lng": s.longitude})
              .toList(),
        }),
      );

      final data = json.decode(response.body);

      if (!data.containsKey("polyline")) {
        print("⚠ No se recibió polyline");
        return;
      }

      List<PointLatLng> decoded =
          PolylinePoints.decodePolyline(data["polyline"]);

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

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  } 

  // void setCustomMarkerIcon() async {
  //   sourceIcon = await getResizedMarker('assets/images/login.jpg', 90);
  //   destinationIcon = await getResizedMarker('assets/images/login.jpg', 90);
  //   currentLocationIcon = await getResizedMarker('assets/images/login.jpg', 70);

  //   setState(() {});
  // }

  // ----------------------------
  //  UI DE MAPA
  // ----------------------------

  @override
  Widget build(BuildContext context) {

    final routes = context.watch<RouteProvider>();
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final FirestoreProvider firestoreProvider = context.watch<FirestoreProvider>();

    final ruta = routes.mostrarIda
        ? routes.rutaIda
        : routes.rutaVuelta;

    final polyline = ruta?["polyline"];
    final paradas = ruta?["paradas"];
    final conductor = routes.ubicacionConductor;
    final user = authProvider.user;

    return Scaffold(
      body: currentLocation == null
          ? Center(child: Text('Cargando...'))
          : FutureBuilder(
            future: firestoreProvider.getUserData( user!.uid ),
            builder: (context, snapshot) {
              final usuario = snapshot.data;

              return Stack(
                    children: [
                      GoogleMap(
              initialCameraPosition: CameraPosition(
                target: routes.polylinePoints.isNotEmpty
                    ? routes.polylinePoints.first
                    : const LatLng(4.15, -73.63),
                zoom: 14,
              ),
              
              polylines: {
                Polyline(
                  polylineId: const PolylineId("ruta"),
                  width: 6,
                  color: Colors.blue,
                  points: routes.polylinePoints,
                )
              },
              
              markers: routes.paradas
                  .map(
                    (p) => Marker(
                      markerId: MarkerId("${p.latitude}-${p.longitude}"),
                      position: p,
                    ),
                  )
                  .toSet(),
                      ),
              
                      /// BOTONES PARA CARGAR RUTA
                      Positioned(
              top: 40,
              left: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "ida",
                    onPressed: () async {
                      await routes.cargarRuta(
                        placa:usuario.placaRutaAsignada,
                        tipoRuta:   "ida",
                      );
                    },
                    child: const Icon(Icons.arrow_forward),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "vuelta",
                    onPressed: () async {
                      await routes.cargarRuta(
                        placa: usuario.placaRutaAsignada,
                        tipoRuta: "vuelta",
                      );
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
                      )
                    ],
                  );
            }
          ),
    );
  }
}
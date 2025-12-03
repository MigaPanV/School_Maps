import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  GoogleMapController? mapController;

  LatLng? currentLocation;     // Mi ubicación actual
  LatLng? selectedDestination; // Punto seleccionado en el mapa

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  // ---------------------- OBTENER UBICACIÓN ----------------------
  Future<void> _loadCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  // ---------------------- MARCADOR SELECCIONADO -------------------
  Set<Marker> _markers() {
    final markers = <Marker>{};

    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("origen"),
          position: currentLocation!,
          infoWindow: const InfoWindow(title: "Mi ubicación"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (selectedDestination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("destino"),
          position: selectedDestination!,
          infoWindow: const InfoWindow(title: "Destino seleccionado"),
        ),
      );
    }

    return markers;
  }

  // ---------------------- CONFIRMAR DESTINO ----------------------
  void _confirmDestination() {
    if (selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un punto en el mapa.")),
      );
      return;
    }

    Navigator.pop(context, selectedDestination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 15,
              ),
              markers: _markers(),
              
              onTap: (LatLng point) {
                setState(() {
                  selectedDestination = point;
                });
              },
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmDestination,
        label: const Text("Confirmar destino"),
        icon: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
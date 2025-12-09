import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/presentation/screens/conductor/conductor_est.dart';
import 'package:school_maps/presentation/screens/conductor/conductor_finRuta.dart';
import 'package:school_maps/presentation/screens/maps/route_tracking_page.dart';
import 'package:school_maps/presentation/widget/shared/custom_profile.dart';

class CondScreen extends StatefulWidget {
  const CondScreen({super.key});

  @override
  State<CondScreen> createState() => _CondScreenState();
}

class _CondScreenState extends State<CondScreen> {
  String? selectedReporte;

  void _mostrarVentanaReportes(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reporte de Ruta', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text("Retraso en el recorrido"),
                    value: "Retraso en el recorrido",
                    groupValue: selectedReporte,
                    onChanged: (value) => setState(() => selectedReporte = value),
                  ),
                  RadioListTile<String>(
                    title: const Text("Estudiante ausente"),
                    value: "Estudiante ausente",
                    groupValue: selectedReporte,
                    onChanged: (value) => setState(() => selectedReporte = value),
                  ),
                  RadioListTile<String>(
                    title: const Text("Problema mecánico"),
                    value: "Problema mecánico",
                    groupValue: selectedReporte,
                    onChanged: (value) => setState(() => selectedReporte = value),
                  ),
                ],
              );
            },
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Enviar'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarConfirmacionFinRuta(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              titlePadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              title: const Center(
                child: Text(
                  '¿Estás seguro de finalizar la ruta?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              scrollable: true,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConductorFinRuta()),
                        );
                      },
                      child: const Text('Sí'),
                    ),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white)),
                      
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final FirestoreProvider firestoreProvider = context.watch<FirestoreProvider>();

    final user = authProvider.user;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Conductor',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomProfileScreen(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/logo.jpg'),
                    radius: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: firestoreProvider.getUserData( user!.uid ),
          builder: (context, snapshot) {


            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            }
        
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text("No se encontraron datos del usuario"),
              );
            }

            final usuario = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton(
                        onPressed: () => _mostrarVentanaReportes(context),
                        child: const Text('Reportes'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ConductorEst()),
                          );
                        },
                        child: const Text('Estudiantes'),
                      ),
                    ],
                  ),
                ),
            
                Expanded(
                  child: Center(
                    child: RouteTrackingPage()
                  ),
                ),
            
                const Text(
                  'Ruta N°',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
            
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );
            
                          final res = await http.post(
                            Uri.parse(
                              "https://us-central1-school-maps-e69f3.cloudfunctions.net/createRouteIda",
                            ),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({"placa": usuario.placaRutaAsignada }),
                          );
            
                          Navigator.of(context).pop(); // Cerrar loading
            
                          if (res.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ruta de IDA generada correctamente")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${res.body}"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          Navigator.of(context).pop(); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error inesperado: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Ruta Parada → Colegio'),
                    ),
                  ),
                ),
            
                const SizedBox(height: 10),
            
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );
            
                          final res = await http.post(
                            Uri.parse(
                              "https://us-central1-school-maps-e69f3.cloudfunctions.net/createRouteVuelta",
                            ),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({"placa": usuario.placaRutaAsignada}),
                          );
            
                          Navigator.of(context).pop(); 
            
                          if (res.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ruta de VUELTA generada correctamente")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${res.body}"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          Navigator.of(context).pop(); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error inesperado: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Ruta Colegio → Paradas'),
                    ),
                  ),
                ),
            
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: FilledButton(
                      onPressed: () => _mostrarConfirmacionFinRuta(context),
                      child: const Text('Finalizar ruta'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }
        ),
      ),
    );
  }
}
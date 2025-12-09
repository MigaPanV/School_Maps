import 'package:flutter/material.dart';
import 'package:school_maps/presentation/screens/maps/route_tracking_page.dart';
import 'package:school_maps/presentation/widget/shared/custom_profile.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';

class PadreScreen extends StatefulWidget {
  const PadreScreen({super.key});

  @override
  State<PadreScreen> createState() => _PadreScreenState();
}

class _PadreScreenState extends State<PadreScreen> {
  String? selectedEstudiante;
  String? selectedReporte;

  void _mostrarVentanaReporte(BuildContext context) {

    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Center(
            child: Text(
              'Reporte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona un estudiante',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedEstudiante,
                    items: const [
                      DropdownMenuItem(
                        value: 'Estudiante 1',
                        child: Text('Estudiante 1'),
                      ),
                      DropdownMenuItem(
                        value: 'Estudiante 2',
                        child: Text('Estudiante 2'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedEstudiante = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona un motivo',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedReporte,
                    items: const [
                      DropdownMenuItem(
                        value: 'Recojo al estudiante',
                        child: Text('Recojo al estudiante'),
                      ),
                      DropdownMenuItem(
                        value: 'No hay nadie en casa',
                        child: Text('No hay nadie en casa'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedReporte = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Acción del botón "Enviar"
                    Navigator.of(context).pop();
                  },
                  child: const Text('Enviar'),
                ),
                TextButton(
                  onPressed: () {
                    // Acción del botón "Cerrar"
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar', style: TextStyle( color: Colors.black)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Acudiente',
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
        body: Center(
          child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                
                const SizedBox(height: 30),
                
                Expanded(
                  child: Center(
                    child: RouteTrackingPage()
                  )
                ),
                
                const SizedBox(height: 40),

                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: ElevatedButton(
                      onPressed: () => _mostrarVentanaReporte(context),
                      child: const Text('Reportar'),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
            
                ElevatedButton(
                      onPressed: () {
                        authProvider.signOut();
                      },
                      child: const Text('cerrar sesión'),
                    ),
            
              ],
            ),
          
        ),
      ),
    );
  }
}
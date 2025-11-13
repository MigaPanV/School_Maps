import 'package:flutter/material.dart';

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
                FilledButton(
                  onPressed: () {
                    // Acción del botón "Enviar"
                    Navigator.of(context).pop();
                  },
                  child: const Text('Enviar'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    // Acción del botón "Cerrar"
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Acudiente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          actions: const [
            IconButton(
              onPressed: null,
              icon: Icon(Icons.notifications),
            ),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/login.jpg'),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Ubicación de tu hijo...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: FilledButton(
                  onPressed: () => _mostrarVentanaReporte(context),
                  child: const Text('Reportar'),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
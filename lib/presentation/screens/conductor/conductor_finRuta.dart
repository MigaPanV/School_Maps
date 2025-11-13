import 'package:flutter/material.dart';

class ConductorFinRuta extends StatefulWidget {
  const ConductorFinRuta({super.key});

  @override
  State<ConductorFinRuta> createState() => _ConductorFinRutaState();
}

class _ConductorFinRutaState extends State<ConductorFinRuta> {
  String? selectedReporte;
  final TextEditingController _descripcionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final reportes = [
      "Ruta completada sin inconvenientes",
      "Retraso leve por tráfico",
      "Estudiante no se presentó",
      "Problemas mecánicos leves",
      "Condiciones climáticas adversas",
      "Cambio de ruta temporal",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Reportes Fin de Ruta',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Seleccione un reporte',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: reportes.length,
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    title: Text(
                      reportes[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: reportes[index],
                    groupValue: selectedReporte,
                    onChanged: (value) {
                      setState(() {
                        selectedReporte = value;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribir descripción...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 5),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'No Obligatorio*',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Por ahora no hace nada, solo regresa a la pantalla principal del conductor
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Enviar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
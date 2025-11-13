import 'package:flutter/material.dart';

class ConductorEst extends StatelessWidget {
  const ConductorEst({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
          'Estudiantes de Ruta N°',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          '*Aquí se mostrarán los estudiantes asignados a la ruta*',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
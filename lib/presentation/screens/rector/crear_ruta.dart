import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/rector_provider.dart';

class CrearRuta extends StatelessWidget {
  const CrearRuta({super.key});

  @override
  Widget build(BuildContext context) {

    final rectorProvider = context.watch<RectorProvider>();

    const double maxContentWidth = 800;
    const double maxFieldWidth = 500;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Crear Ruta'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // esto permite desplazarte por toda la pantalla
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 500,
                              minHeight: 200,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Placeholder(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Puntos de ruta',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),

                          const SizedBox(height: 12),

                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: maxFieldWidth),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                                onChanged: (value) => rectorProvider.setPuntoRuta(value),
                                decoration: InputDecoration(
                                  hintText: 'Ingresar un punto de ruta',
                                  filled: true,
                                  fillColor: Colors.white,
                                  errorText: rectorProvider.errorPuntoRuta,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueAccent),
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (rectorProvider.validarPuntoRuta()) {
                                    // Aquí agregas el punto a Firestore o a una lista temporal
                                    print("Punto válido: ${rectorProvider.puntoRuta}");
                                  }
                                },
                                child: const Text('Agregar punto'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  rectorProvider.openDialogCreateRoute(context);
                                },
                                child: const Text('Guardar ruta'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 80), // margen final
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

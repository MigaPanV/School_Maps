import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/domain/entities/estudiante.dart';

class CrearRuta extends StatefulWidget {
  const CrearRuta({super.key});

  @override
  State<CrearRuta> createState() => _CrearRutaState();
}

class _CrearRutaState extends State<CrearRuta> {
  List<Estudiante> estudiantes = [];
  List<Estudiante> seleccionados = [];
  String? busSeleccionado;

  bool loading = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final firestore = Provider.of<FirestoreProvider>(context, listen: false);

    final listaEstudiantes = await firestore.getEstudiantesAll();  
    final listaBuses = await firestore.getBuses();                 

    setState(() {
      estudiantes = listaEstudiantes;
      buses = listaBuses.map((b) => b.placa).toList();
      loading = false;
    });
  }

  List<String> buses = [];

  Future<void> guardarRuta() async {
    if (busSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un bus.")),
      );
      return;
    }

    if (seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona al menos un estudiante.")),
      );
      return;
    }

    final firestore = Provider.of<FirestoreProvider>(context, listen: false);

    setState(() => guardando = true);

    await firestore.guardarRutaGenerada(
      placaBus: busSeleccionado!,
      estudiantes: seleccionados,
    );

    setState(() => guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ruta creada correctamente.")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Ruta Escolar"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // -------- BUS SELECCIONADO --------
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButtonFormField<String>(
                    value: busSeleccionado,
                    decoration: const InputDecoration(
                      labelText: "Seleccionar bus",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                    items: buses
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        busSeleccionado = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                const Text("Seleccionar estudiantes:",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),

                Expanded(
                  child: ListView.builder(
                    itemCount: estudiantes.length,
                    itemBuilder: (context, index) {
                      final estudiante = estudiantes[index];
                      final seleccionado =
                          seleccionados.contains(estudiante);

                      return CheckboxListTile(
                        title: Text(estudiante.nombreEstudiante,
                          style: TextStyle(color: Colors.white)),
                        subtitle: Text("Documento: ${estudiante.documento}", 
                          style: TextStyle(color: Colors.white)),
                        value: seleccionado,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              seleccionados.add(estudiante);
                            } else {
                              seleccionados.remove(estudiante);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),

                guardando
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Guardar Ruta"),
                          onPressed: guardarRuta,
                        ),
                      ),
              ],
            ),
    );
  }
}
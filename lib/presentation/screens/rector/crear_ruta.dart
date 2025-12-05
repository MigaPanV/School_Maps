import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/domain/entities/bus.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/domain/entities/estudiante.dart';

class CrearRuta extends StatefulWidget {
  const CrearRuta({super.key});

  @override
  State<CrearRuta> createState() => _CrearRutaState();
}

class _CrearRutaState extends State<CrearRuta> {
  List<Estudiante> estudiantesSinRuta = [];
  List<Estudiante> estudiantesConRuta = [];
  List<Estudiante> seleccionados = [];
  Bus? busSeleccionado;

  bool loading = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final firestore = Provider.of<FirestoreProvider>(context, listen: false);

    final datos = await firestore.getEstudiantesAll();
    estudiantesSinRuta = datos[ 'sinRuta' ]!;
    estudiantesConRuta = datos[ 'conRuta' ]!;
    final listaBuses = await firestore.getBuses();                 

    setState(() {
      
      buses = listaBuses;//.map((b) => b.placa).toList();
      loading = false;
    });
  }

  List<Bus> buses = [];

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
      placaBus: busSeleccionado!.placa,
      estudiantes: seleccionados,
      capacidadBus: busSeleccionado!.capacidad
    );

    setState(() => guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ruta creada correctamente.")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Crear Ruta Escolar"),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints( maxHeight: 800, maxWidth: 1600 ),
                  child: Column(
                      children: [
                        // -------- BUS SELECCIONADO --------
                        
                        if (estudiantesSinRuta.isEmpty)...[
                          const SizedBox(height: 30),
                        
                          Text( 'Todos los estudiantes tienen ruta asignada', 
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white) 
                          ),
                          const SizedBox(height: 30),
                        
                          ]
                        else...[
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: DropdownButtonFormField<Bus>(
                              initialValue: busSeleccionado,
                              decoration: const InputDecoration(
                                labelText: "Seleccionar bus",
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                              ),
                              items: buses
                                  .map((p) => DropdownMenuItem(
                                        value: p,
                                        child: Text( p.placa, style: TextStyle( color: Colors.white ) ),
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
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                        
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: estudiantesSinRuta.length,
                            itemBuilder: (context, index) {
                              final estudiante = estudiantesSinRuta[index];
                              final seleccionado = seleccionados.contains(estudiante);
                      
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
                          
                        ],
                        
                        Text( 'Estudiantes con ruta asignada', 
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                        
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: estudiantesConRuta.length,
                          itemBuilder: (_, i) {
                            final e = estudiantesConRuta[i];
                            return ListTile(
                              title: Text("${e.nombreEstudiante} — ${e.grado}",
                                style: TextStyle(color: Colors.white)),
                              subtitle: Text("Ruta asignada: ${e.placaRutaAsignada}",
                                style: TextStyle(color: Colors.white)),
                              trailing: Icon(Icons.info, color: Colors.blue),
                            );
                          },
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
                ),
              ),
            ),
      ),
    );
  }
}
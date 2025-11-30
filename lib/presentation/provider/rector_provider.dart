import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/domain/entities/bus.dart';
import 'package:school_maps/domain/entities/estudiante.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';

class RectorProvider with ChangeNotifier {

  List<String> seleccionadas = [];

  String? conductorSeleccionado;
  List<String> puntosRuta = [];
  String puntoRuta = '';
  String? errorPuntoRuta;

  String? errorPopup;

  void setPuntoRuta(String value) {
    puntoRuta = value;
    errorPuntoRuta = null;
    notifyListeners();
  }

  bool validarPuntoRuta() {
    final regex = RegExp(
      r'^(Calle|Carrera|Diagonal|Transversal)\s+\d+[A-Za-z]?\s*#\s*\d+[A-Za-z]?$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(puntoRuta)) {
      errorPuntoRuta = 'Formato inválido. Ej: Calle 45 # 20';
      notifyListeners();
      return false;
    }

    return true;
  }

  void seleccionarConductor(String? value) {
    conductorSeleccionado = value;
    errorPopup = null;
    notifyListeners();
  }

  bool validarBeforeSave({bool requirePuntos = false}) {
    if (conductorSeleccionado == null || conductorSeleccionado!.isEmpty) {
      errorPopup = 'Debe seleccionar un conductor';
      notifyListeners();
      return false;
    }

    if (requirePuntos && puntosRuta.isEmpty) {
      errorPopup = 'Debe agregar mínimo un punto de ruta';
      notifyListeners();
      return false;
    }

    errorPopup = null;
    return true;
  }

  void mostrarRutas( BuildContext context, Future<List<Bus>> opcionesFuture, List seleccionadas,) {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<List<Bus>>(
              future: opcionesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final opciones = snapshot.data!;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Rutas Disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...opciones.map((opcion) {
                      final seleccionada = seleccionadas.contains(opcion.placa);
                      return CheckboxListTile(
                        title: Text(opcion.placa),
                        value: seleccionada,
                        onChanged: (valor) {
                          setModalState(() {
                            if (valor == true) {
                              seleccionadas.add(opcion.placa);
                              notifyListeners();
                            } else {
                              seleccionadas.remove(opcion.placa);
                              notifyListeners();
                            }
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Aceptar'),
                      
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}

  void openDialogCreateRoute(BuildContext context) async {
    final styleTitle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    final styleText = const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );

    final firestore = Provider.of<FirestoreProvider>(context, listen: false);

    final listaConductores = await firestore.getConductores();
    await firestore.getPadres();
    final listaBuses = await firestore.getBuses();

    Padre? padreSeleccionado;
    String? hijoSeleccionado;
    String? rutaSeleccionada;
    String? errorPadre;
    String? errorRuta;

    TextEditingController textController = TextEditingController();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => Consumer<FirestoreProvider>(
        builder: (context, firestore, _) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Asignar conductor', style: styleTitle),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Selecciona un conductor'),
                        value: conductorSeleccionado,
                        items: listaConductores
                          .map((c) => DropdownMenuItem(
                                value: c.nombre,
                                child: Text(c.nombre),
                              ))
                          .toList(),
                        onChanged: (value) {
                          seleccionarConductor(value);
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 16),

                      Text('Asignar ruta', style: styleTitle),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Selecciona una ruta'),
                        value: rutaSeleccionada,
                        items: listaBuses
                            .map((p) =>
                                DropdownMenuItem(
                                  value: p.placa, 
                                  child: Text(p.placa)
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            rutaSeleccionada = value;
                            errorRuta = null;
                          });
                        },
                      ),
                      if (errorRuta != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorRuta ?? '',
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),

                      const SizedBox(height: 20),

                      Text('Asignar padre', style: styleTitle),
                      const SizedBox(height: 12),
                      TypeAheadField<Padre>(
                        suggestionsCallback: (pattern) async {
                          if (pattern.isEmpty) return [];

                          final padres = await firestore.getPadres();

                          return padres
                              .where((p) =>
                                  p.nombre.toLowerCase().contains(pattern.toLowerCase()))
                              .toList();
                        },
                        itemBuilder: (context, padre) => ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(padre.nombre),
                        ),
                        onSelected: (padre) {
                          setState(() {
                            padreSeleccionado = padre;
                            textController.text = padre.nombre;
                            hijoSeleccionado = null;
                            errorPadre = null;
                          });
                        },
                        builder: (context, _controller, focusNode) {
                          textController = _controller;
                          return TextField(
                            controller: textController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Buscar padre',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                          );
                        },
                      ),  

                      if (errorPadre != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorPadre ?? '',
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),

                      const SizedBox(height: 20),

                      if (padreSeleccionado != null)
                        FutureBuilder(
                          future: firestore.getEstudiantes( padreSeleccionado!.documento),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return CircularProgressIndicator();

                            final hijos = snapshot.data!;

                            return DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: 'Hijos de ${padreSeleccionado!.nombre}',
                              ),
                              items: hijos.map((hijo) {
                                return DropdownMenuItem(
                                  value: hijo.nombreEstudiante,
                                  child: Text(hijo.nombreEstudiante),
                                );
                              }).toList(),
                              onChanged: (nuevo) {
                                setState(() {
                                  hijoSeleccionado = nuevo;
                                });
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 20),

                      if (errorPopup != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorPopup ?? '',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancelar', style: styleText),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                errorPadre = null;
                                errorRuta = null;
                              });

                              if (rutaSeleccionada == null) {
                                setState(() {
                                  errorRuta = 'Debe seleccionar una ruta';
                                });
                              }
                              if (padreSeleccionado == null) {
                                setState(() {
                                  errorPadre = 'Debe seleccionar un padre';
                                });
                              }

                              if (errorPadre != null || errorRuta != null) return;

                              bool okProvider = validarBeforeSave(requirePuntos: false);

                              if (!okProvider) {
                                setState(() {});
                                return;
                              }

                              // aquí se llama a Firestore para guardar la asignación (creo ud sabe mas)

                              Navigator.pop(context);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                notifyListeners();
                              });
                            },
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  
}
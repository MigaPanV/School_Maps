import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
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

  void mostrarRutas(BuildContext context, List opciones, List seleccionadas) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
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
                    final seleccionada = seleccionadas.contains(opcion);
                    return CheckboxListTile(
                      title: Text(opcion),
                      value: seleccionada,
                      onChanged: (valor) {
                        setModalState(() {
                          if (valor == true) {
                            seleccionadas.add(opcion);
                          } else {
                            seleccionadas.remove(opcion);
                          }
                        });
                        notifyListeners();
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openDialogCreateRoute(BuildContext context) {
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

    final Map<String, List<String>> familia = {
      'Carlos Gómez': ['Ana Gómez', 'Felipe Gómez', 'Laura Gómez'],
      'María Torres': ['Sofía Torres', 'Daniel Torres'],
      'Juan Pérez': ['Camilo Pérez', 'Valentina Pérez', 'Andrés Pérez'],
      'Lucía Ramírez': ['Julio Ramírez', 'Martina Ramírez'],
    };

    String? padreSeleccionado;
    String? hijoSeleccionado;
    String? rutaSeleccionada;
    String? errorPadre;
    String? errorRuta;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => Consumer<FirestoreProvider>(
        builder: (context, firestore, _) {
          return StatefulBuilder(
            builder: (context, setState) {
              TextEditingController textController = TextEditingController();
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
                        items: ['Pepito Perez', 'Son Goku', 'Vicente Fernandez']
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
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
                        items: ['Ruta 1', 'Ruta 2', 'Ruta 3']
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
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
                      TypeAheadField<String>(
                      suggestionsCallback: (pattern) {
                        if (pattern.isEmpty) return [];
                        return familia.keys
                            .where((nombre) =>
                                nombre.toLowerCase().contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(suggestion),
                        );
                      },
                      onSelected: (sugerencia) {
                        setState(() {
                          padreSeleccionado = sugerencia;
                          textController.text = sugerencia;
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
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Hijos de $padreSeleccionado',
                            border: const OutlineInputBorder(),
                          ),
                          value: hijoSeleccionado,
                          items: familia[padreSeleccionado]!
                              .map((hijo) =>
                                  DropdownMenuItem(value: hijo, child: Text(hijo)))
                              .toList(),
                          onChanged: (nuevo) {
                            setState(() {
                              hijoSeleccionado = nuevo;
                            });
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
                              notifyListeners();
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
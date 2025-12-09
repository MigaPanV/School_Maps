import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:school_maps/constants.dart';
import 'package:school_maps/domain/entities/bus.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/presentation/provider/route_provider.dart';
import 'package:school_maps/presentation/screens/rector/create_route_page.dart';

class RectorProvider with ChangeNotifier {


  List<String> puntosRuta = [];
  String puntoRuta = '';
  String? errorPuntoRuta;

  String? conductorSeleccionado;
  String? errorPopup;

  List<String> seleccionadas = [];
  String busSeleccionado = '';

  final List<Map<String, dynamic>> tempPuntos = [];

  void mostrarRutas( BuildContext context, Future<List<Bus>> opcionesFuture, List seleccionadas,) {

    final firestore = context.watch<FirestoreProvider>();
    final routes = context.watch<RouteProvider>();
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
                                busSeleccionado = opcion.placa;
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
                        onPressed: () async { 


                          final rutas = await firestore.getRutasDeBus(busSeleccionado);

                          // Guardamos en el provider de rutas

                          routes.setBusSeleccionado(busSeleccionado);
                          routes.setRutaIda(rutas["rutaIda"]);
                          routes.setRutaVuelta(rutas["rutaVuelta"]);
  
                          Navigator.pop(context);
                        
                        },

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

  void setPuntoRuta(String value) {
    puntoRuta = value.trim();
    errorPuntoRuta = null;
    notifyListeners();
  }

  bool validarPuntoRuta() {
    if (puntoRuta.isEmpty) {
      errorPuntoRuta = 'Ingrese una dirección';
      notifyListeners();
      return false;
    }
    return true;
  }

  void eliminarPuntoRuta(int index) {
    puntosRuta.removeAt(index);
    notifyListeners();
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
      errorPopup = 'Debe agregar al menos un punto de ruta';
      notifyListeners();
      return false;
    }
    errorPopup = null;
    return true;
  }

//   void mostrarRutas( BuildContext context, Future<List<Bus>> opcionesFuture, List seleccionadas,) {
//   showModalBottomSheet(
//     context: context,
//     builder: (_) {
//       return StatefulBuilder(
//         builder: (context, setModalState) {
//           return Container(
//             padding: const EdgeInsets.all(20.0),
//             child: FutureBuilder<List<Bus>>(
//               future: opcionesFuture,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final opciones = snapshot.data!;

//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       'Rutas Disponibles',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     ...opciones.map((opcion) {
//                       final seleccionada = seleccionadas.contains(opcion.placa);
//                       return CheckboxListTile(
//                         title: Text(opcion.placa),
//                         value: seleccionada,
//                         onChanged: (valor) {
//                           setModalState(() {
//                             if (valor == true) {
//                               seleccionadas.add(opcion.placa);
//                               notifyListeners();
//                             } else {
//                               seleccionadas.remove(opcion.placa);
//                               notifyListeners();
//                             }
//                           });
//                         },
//                       );
//                     }),

//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Aceptar'),
                      
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         },
//       );
//     },
//   );
// }

// Convierte dirección a LatLng usando Geocoding API
  Future<LatLng?> geocodeAddress(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=$encoded&key=$google_api_key'
    );

    final resp = await http.get(url);
    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body);
    if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
      final loc = data['results'][0]['geometry']['location'];
      return LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
    }
    return null;
  }

  // Agrega punto a la lista temporal (se usa cuando el usuario presiona "Agregar punto")
  Future<bool> agregarPuntoTemporal(String direccion) async {
    final coords = await geocodeAddress(direccion);
    if (coords == null) {
      return false;
    }
    tempPuntos.add({
      'lat': coords.latitude,
      'lng': coords.longitude,
      'direccion': direccion,
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
    return true;
  }

  // Guarda la ruta en Firestore bajo colección Rutas/{placa}
  Future<void> saveRuta({
    required String placa,
    required String nombreRuta,
    required String conductor,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('Rutas').doc(placa);

    await docRef.set({
      'nombreRuta': nombreRuta,
      'conductor': conductor,
      'puntos': tempPuntos,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // si quieres limpiar la lista temporal:
    tempPuntos.clear();
    notifyListeners();
  }

void openDialogCreateRoute(BuildContext context) async {
  final styleTitle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final firestore = Provider.of<FirestoreProvider>(context, listen: false);

  final listaConductores = await firestore.getConductores();
  final listaBuses = await firestore.getBuses();
  await firestore.getPadres();

  Padre? padreSeleccionado;
  String? hijoSeleccionado;
  String? rutaSeleccionada;
  String? conductorSeleccionado;

  String? errorPadre;
  String? errorHijo;
  String? errorRuta;
  String? errorPopup;

  /// 🔵 Nueva variable: destino final guardado desde CreateRoute
  LatLng? destinoSeleccionado;

  TextEditingController textController = TextEditingController();

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (dialogContext) {
      return Consumer<FirestoreProvider>(
        builder: (context, firestore, _) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Asignación de Ruta", style: styleTitle),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ---------------- CONDUCTOR ----------------
                      Text('Asignar conductor', style: styleTitle),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Selecciona un conductor'),
                        value: conductorSeleccionado,
                        items: listaConductores
                            .map((c) => DropdownMenuItem(
                                  value: c.nombre,
                                  child: Text(c.nombre),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            conductorSeleccionado = value;
                            errorPopup = null;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // ---------------- BUS / RUTA ----------------
                      Text('Asignar ruta (bus)', style: styleTitle),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Selecciona una ruta'),
                        value: rutaSeleccionada,
                        items: listaBuses
                            .map((p) => DropdownMenuItem(value: p.placa, child: Text(p.placa)))
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
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(errorRuta!, style: const TextStyle(color: Colors.red)),
                        ),

                      const SizedBox(height: 20),

                      // ---------------- NUEVA SECCIÓN: DESTINO ----------------
                      Text("Destino de la Ruta", style: styleTitle),

                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                        icon: Icon(Icons.map),
                        label: Text("Elegir destino en mapa"),
                        onPressed: () async {
                          /// 🔵 Abrir pantalla CreateRoute (la crearé en el siguiente paso)
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateRoutePage(),
                            ),
                          );

                          if (resultado != null && resultado is LatLng) {
                            setState(() {
                              destinoSeleccionado = resultado;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      if (destinoSeleccionado != null)
                        Text(
                          "Destino seleccionado:\nLat: ${destinoSeleccionado!.latitude}\nLng: ${destinoSeleccionado!.longitude}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.green, fontSize: 16),
                        ),

                      const SizedBox(height: 20),

                      // ---------------- PADRE ----------------
                      Text('Asignar padre', style: styleTitle),
                      const SizedBox(height: 12),

                      TypeAheadField<Padre>(
                        suggestionsCallback: (pattern) async {
                          if (pattern.isEmpty) return [];
                          final padres = await firestore.getPadres();
                          return padres.where((p) => p.nombre
                              .toLowerCase()
                              .contains(pattern.toLowerCase())).toList();
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
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(errorPadre!, style: const TextStyle(color: Colors.red)),
                        ),

                      const SizedBox(height: 20),

                      // ---------------- HIJO ----------------
                      if (padreSeleccionado != null)
                        FutureBuilder(
                          future: firestore.getEstudiantes(padreSeleccionado!.documento),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final hijos = snapshot.data!;

                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Hijos de ${padreSeleccionado!.nombre}',
                              ),
                              value: hijoSeleccionado,
                              items: hijos
                                  .map((hijo) => DropdownMenuItem(
                                        value: hijo.nombreEstudiante,
                                        child: Text(hijo.nombreEstudiante),
                                      ))
                                  .toList(),
                              onChanged: (nuevo) {
                                setState(() {
                                  hijoSeleccionado = nuevo;
                                  errorHijo = null;
                                });
                              },
                            );
                          },
                        ),

                      if (errorHijo != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(errorHijo!, style: const TextStyle(color: Colors.red)),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    child: const Text('Guardar'),
                    onPressed: () async {
                      setState(() {
                        errorPadre = null;
                        errorRuta = null;
                        errorHijo = null;
                        errorPopup = null;
                      });

                      if (conductorSeleccionado == null) errorPopup = "Seleccione un conductor";
                      if (rutaSeleccionada == null) errorRuta = "Seleccione una ruta";
                      if (padreSeleccionado == null) errorPadre = "Seleccione un padre";
                      if (padreSeleccionado != null && hijoSeleccionado == null)
                        errorHijo = "Seleccione un hijo";
                      if (destinoSeleccionado == null)
                        errorPopup = "Debe seleccionar un destino en el mapa";

                      if (errorPopup != null || errorRuta != null || errorPadre != null || errorHijo != null) {
                        setState(() {});
                        return;
                      }

                      /// 🔵 GUARDAR EN FIRESTORE LA NUEVA RUTA
                      await firestore.guardarRutaAsignada(
                        conductor: conductorSeleccionado!,
                        ruta: rutaSeleccionada!,
                        padre: padreSeleccionado!,
                        hijo: hijoSeleccionado!,
                        destino: destinoSeleccionado!,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Ruta asignada correctamente!')),
                      );

                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
}  

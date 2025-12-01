import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/domain/entities/conductor.dart';
import 'package:school_maps/domain/entities/estudiante.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';

class RectorProvider with ChangeNotifier {

  List<String> puntosRuta = [];
  String puntoRuta = '';
  String? errorPuntoRuta;

  String? conductorSeleccionado;
  String? errorPopup;

  List<String> seleccionadas = [];

  void mostrarRutas(BuildContext context, List<String> opciones, List<String> seleccionadas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  const Text(
                    'Rutas Disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: opciones.map((opcion) {
                        final estaSeleccionada = seleccionadas.contains(opcion);
                        return CheckboxListTile(
                          title: Text(opcion),
                          value: estaSeleccionada,
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                seleccionadas.add(opcion);
                              } else {
                                seleccionadas.remove(opcion);
                              }
                            });
                            notifyListeners();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
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

  void setPuntoRuta(String value) {
    puntoRuta = value.trim();
    errorPuntoRuta = null;
    notifyListeners();
  }

  bool validarPuntoRuta() {
    if (puntoRuta.isEmpty) {
      errorPuntoRuta = 'El punto no puede estar vacío';
      notifyListeners();
      return false;
    }
    final regex = RegExp(
      r'^(Calle|Carrera|Diagonal|Transversal)\s+\d+[A-Za-z]?\s*#\s*\d+[A-Za-z]?-?\d*[A-Za-z]?$',
      caseSensitive: false,
    );
    if (!regex.hasMatch(puntoRuta)) {
      errorPuntoRuta = 'Formato inválido. Ej: Calle 45 # 20-15';
      notifyListeners();
      return false;
    }
    puntosRuta.add(puntoRuta);
    puntoRuta = '';
    errorPuntoRuta = null;
    notifyListeners();
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


  void openDialogCreateRoute(BuildContext context) async {
    final firestore = Provider.of<FirestoreProvider>(context, listen: false);
    final listaConductores = await firestore.getConductores();

    Padre? padreSeleccionado;
    String? hijoSeleccionado;
    String? rutaSeleccionada;

    String? errorPadre;
    String? errorHijo;
    String? errorRuta;

    final searchController = TextEditingController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Asignar Estudiante a Ruta'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Conductor
                    const Text('Conductor', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: conductorSeleccionado,
                      decoration: const InputDecoration(labelText: 'Seleccionar conductor'),
                      items: listaConductores
                          .map((c) => DropdownMenuItem(value: c.nombre, child: Text(c.nombre)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => conductorSeleccionado = value);
                        seleccionarConductor(value);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Ruta
                    const Text('Ruta', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: rutaSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Seleccionar ruta',
                        errorText: errorRuta,
                      ),
                      items: ['Ruta 1', 'Ruta 2', 'Ruta 3']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          rutaSeleccionada = value;
                          errorRuta = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Padre
                    const Text('Buscar Padre', style: TextStyle(fontWeight: FontWeight.bold)),
                    TypeAheadField<Padre>(
                      controller: searchController,
                      suggestionsCallback: (pattern) async {
                        if (pattern.isEmpty) return [];
                        final padres = await firestore.getPadres();
                        return padres
                            .where((p) => p.nombre.toLowerCase().contains(pattern.toLowerCase()))
                            .toList();
                      },
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Nombre del padre/acudiente',
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            errorText: errorPadre,
                          ),
                        );
                      },
                      itemBuilder: (context, padre) => ListTile(
                        title: Text(padre.nombre),
                        subtitle: Text('Doc: ${padre.documento}'),
                      ),
                      onSelected: (padre) {
                        setState(() {
                          padreSeleccionado = padre;
                          searchController.text = padre.nombre;
                          hijoSeleccionado = null;
                          errorPadre = null;
                          errorHijo = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    if (padreSeleccionado != null) ...[
                      const Text('Seleccionar Hijo', style: TextStyle(fontWeight: FontWeight.bold)),
                      FutureBuilder<List<Estudiante>>(
                        future: firestore.getEstudiantes(padreSeleccionado!.documento),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No hay hijos registrados');
                          }
                          final hijos = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            value: hijoSeleccionado,
                            decoration: InputDecoration(
                              labelText: 'Hijo',
                              errorText: errorHijo,
                            ),
                            items: hijos
                                .map((h) => DropdownMenuItem(
                                      value: h.documento.toString(),
                                      child: Text(h.nombreEstudiante),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                hijoSeleccionado = value;
                                errorHijo = null;
                              });
                            },
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 20),
                    if (errorPopup != null)
                      Text(errorPopup!, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    errorPadre = null;
                    errorRuta = null;
                    errorHijo = null;
                    errorPopup = null;
                  });

                  if (conductorSeleccionado == null) errorPopup = 'Seleccione un conductor';
                  if (rutaSeleccionada == null) errorRuta = 'Seleccione una ruta';
                  if (padreSeleccionado == null) errorPadre = 'Seleccione un padre';
                  if (padreSeleccionado != null && hijoSeleccionado == null) {
                    errorHijo = 'Seleccione un hijo';
                  }

                  if (errorPopup != null || errorRuta != null || errorPadre != null || errorHijo != null) {
                    setState(() {});
                    return;
                  }

                  // ÉXITO
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Estudiante asignado correctamente!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
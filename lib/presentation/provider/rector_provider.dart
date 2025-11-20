import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:school_maps/presentation/provider/firestore_provider.dart';

class RectorProvider with ChangeNotifier {

  List<String> seleccionadas = [];

  void mostrarRutas( BuildContext context, List opciones, List seleccionadas ){
    showModalBottomSheet(
      context: context, 
      builder: (_) {
        return StatefulBuilder(
          builder: ( context, setModalState ) {
            return Container(
              padding: const EdgeInsets.all( 20.0 ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rutas Disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                  ...opciones.map(( opcion ){

                    final seleccionada = seleccionadas.contains( opcion );
                    return CheckboxListTile(

                      title: Text( opcion ),
                      value: seleccionada, 
                      onChanged: ( valor ){
                        setModalState ((){
                          if( valor == true ){
                          seleccionadas.add( opcion );
                          }
                          else{
                            seleccionadas.remove( opcion );
                          }
                        });
                        notifyListeners();
                      }
                    );
                  }),

                  SizedBox( height: 10 ),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text( 'Aceptar' ),
                  ),

                ],
              ),
            );

          } 
        );
      }
    );
  }

  void openDialogCreateRoute( BuildContext context ){


    final styleTitle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black
    );

    final styleText = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: Colors.black
    );

    final Map<String, List<String>> familia = {
      'Carlos Gómez': ['Ana Gómez', 'Felipe Gómez', 'Laura Gómez'],
      'María Torres': ['Sofía Torres', 'Daniel Torres'],
      'Juan Pérez': ['Camilo Pérez', 'Valentina Pérez', 'Andrés Pérez'],
      'Lucía Ramírez': ['Julio Ramírez', 'Martina Ramírez'],
    };

    String? padreSeleccionado;
    String? hijoSeleccionado;

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: ( dialogContext ) => Consumer<FirestoreProvider>(
        builder: ( context, firestore, _ ){
          return StatefulBuilder(
            builder: ( context, setState ){
              return AlertDialog(
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text( 
                        'Asignar conductor',
                        style: styleTitle
                      ),
                  
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Selecciona un condutor'),
                        items: ['Pepito Perez', 'Son Goku', 'Vicente Fernandez']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (value) {},
                      ),
                  
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Selecciona una ruta'),
                        items: ['Ruta 1', 'Ruta 2', 'Ruta 3']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (value) {},
                      ),

                      const SizedBox(height: 20),

                      Text( 
                        'Asignar padre',
                        style: styleTitle
                      ),

                      const SizedBox(height: 20),
                  
                      TypeAheadField<String>(
                        suggestionsCallback: (pattern) {
                          if (pattern.isEmpty) return [];
                          return familia.keys
                              .where((nombre) => nombre.toLowerCase().contains(pattern.toLowerCase()))
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
                            hijoSeleccionado = null;
                          });
                        },
                        builder: (context, controller, focusNode) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Buscar padre',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                          );
                        },
                      ),
                  
                      const SizedBox(height: 20),

                      if (padreSeleccionado != null)
                        Text( 
                          'Asignar hijo',
                          style: styleTitle
                        ),

                      const SizedBox(height: 20),

                      // --- Hijos según el padre ---
                      if (padreSeleccionado != null)

                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Hijos de $padreSeleccionado',
                            border: const OutlineInputBorder(),
                          ),
                          value: hijoSeleccionado,
                          items: familia[padreSeleccionado]!
                              .map(
                                (hijo) => DropdownMenuItem(
                                  value: hijo,
                                  child: Text(hijo),
                                ),
                              )
                              .toList(),
                          onChanged: (nuevo) {
                            setState(() {
                              hijoSeleccionado = nuevo;
                            });
                          },
                        ),

                      const SizedBox(height: 30),
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            }, 
                            child: Text( 'Cancelar', style: styleText )
                          ),
                          
                          ElevatedButton(
                            onPressed: (){}, 
                            child: Text( 'Guardar' )
                          ),
                          
                        ],
                      )
                    ],
                  ),
                ),
              );
            }
          );
        }
      )
    );
  }

  
}
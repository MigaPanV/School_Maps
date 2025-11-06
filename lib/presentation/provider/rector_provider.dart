import 'package:flutter/material.dart';

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
                    child: const Text('Aceptar'),
                  ),

                ],
              ),
            );

          } 
        );
      }
    );
  }
}
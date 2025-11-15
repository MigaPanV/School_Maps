import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/domain/entities/padre.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/presentation/widget/shared/custom_text_fields.dart';

class AddPadre extends StatelessWidget {
  const AddPadre({super.key});

  @override
  Widget build(BuildContext context) {

    final FirestoreProvider firestore = context.watch<FirestoreProvider>();

    const double maxContentWidth = 800;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(

          title: Text( 'Añadir Acudiente' ),

        ),
        body: LayoutBuilder(
          builder: ( context, constraints ){
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: maxContentWidth
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric( vertical: 24, horizontal: 20),
                      child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 500,
                              minHeight: 200,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                
                                  children: [
                                    Text( 'Acudiente' ),
                                
                                    SizedBox( height: 20 ),

                                    CustomTextField(
                                      errorText: null, 
                                      labeltext: 'Ingrese nombre acudiente',
                                      onChanged: firestore.getNombreAcudiente,
                                    ),

                                    SizedBox(height: 20), 

                                    CustomTextField(
                                      errorText: null, 
                                      labeltext: 'Ingrese documento acudiente',
                                      onChanged: firestore.getDocumentoAcudiente,
                                    ),

                                    SizedBox(height: 20),

                                    CustomTextField(
                                      errorText: null, 
                                      labeltext: 'Ingrese correo acudiente',
                                      onChanged: firestore.getCorreoAcudiente,
                                    ),

                                    SizedBox(height: 20),

                                    CustomTextField(
                                      errorText: null, 
                                      labeltext: 'Ingrese su dirección',
                                      onChanged: firestore.getDireccion,
                                    ),

                                    SizedBox(height: 20),

                                    Text( 'Estudiante' ),

                                    SizedBox(height: 20),

                                    CustomTextField(
                                      errorText: null, 
                                      labeltext: 'Ingrese documento estudiante',
                                      onChanged: firestore.getDocumentoHijo,
                                    ),

                                    SizedBox(height: 20),
                                    
                                    Text( 'Bus' ),

                                    SizedBox(height: 20),

                                    CustomTextField(
                                      errorText: null, 
                                      labeltext: 'Ingrese placa ruta asignada',
                                      onChanged: firestore.getPlaca,
                                    ),

                                    SizedBox(height: 20),
                                
                                    ElevatedButton(
                                      onPressed: (){
                                        firestore.addPadre();
                                      }, 
                                      child: Text( 'Guardar' )
                                    )
                                  ],
                                
                                  
                                
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                )
              ),
            );
          }
        ),
      )
    );
  }
}
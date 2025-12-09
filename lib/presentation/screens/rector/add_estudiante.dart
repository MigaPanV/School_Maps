import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/presentation/screens/auth/loading_screen.dart';
import 'package:school_maps/presentation/widget/shared/custom_text_fields.dart';

class AddEstudiante extends StatelessWidget {
  const AddEstudiante({super.key});

  @override
  Widget build(BuildContext context) {

    final FirestoreProvider firestore = context.watch<FirestoreProvider>();

    const double maxContentWidth = 800;

    int? gradoSeleccionado = 0;
    List<int> grados = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ];

    if(!firestore.isLoading && firestore.isUploaded){
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Datos cargados', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                  ],
                ),
                ElevatedButton(
                  onPressed: (){
                            
                    Navigator.pop(context);
                    firestore.isUploaded = false;
                  }, 
                  child: Text('Continuar')
                )
              ],
            )
            
          )
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(

          title: Text( 'Añadir Estudiante' ),

        ),
        body: firestore.isLoading == true 
        ? LoadingScreen(text: 'Subiendo datos') 
        : LayoutBuilder(
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

                                Text( 'Estudiante' ),
                            
                                SizedBox( height: 20 ),

                                CustomTextField(
                                  errorText: firestore.errorNombre,
                                  labeltext: 'Ingrese nombre estudiante',
                                  onChanged: firestore.getNombreEstudiante,
                                ),

                                SizedBox(height: 20), 

                                CustomTextField(
                                  errorText: firestore.errorDocumento, 
                                  labeltext: 'Ingrese documento estudiante',
                                  onChanged: firestore.getDocumentoEstudiante,
                                ),

                                DropdownButtonFormField<int>(
                                  decoration: const InputDecoration(labelText: 'Selecciona un grado'),
                                  initialValue: gradoSeleccionado,
                                  items: grados
                                      .map((c) => DropdownMenuItem(
                                            value: c,
                                            child: Text( c.toString() ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    firestore.getGrado( value );
                                    //(() {
                                    //   gradoSeleccionado = value;
                                    //   // errorPopup = null;
                                    // });
                                  },
                                ),          

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorDireccion, 
                                  labeltext: 'Ingrese su dirección',
                                  onChanged: firestore.getDireccion,
                                ),
                                
                                SizedBox(height: 20),
                                
                                Text( 'Acudiente' ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorDocumento,
                                  labeltext: 'Ingrese cedula acudiente',
                                  onChanged: firestore.getDocumentoAcudiente,
                                ),

                                SizedBox(height: 20),
                                
                                // Text( 'Bus' ),

                                // SizedBox(height: 20),

                                // CustomTextField(
                                //   errorText: firestore.errorPlaca, 
                                //   labeltext: 'Ingrese placa ruta asignada',
                                //   onChanged: firestore.getPlaca,
                                // ),

                                // SizedBox(height: 20),
                            
                                ElevatedButton(
                                  onPressed: () async{
                                    await firestore.addEstudiante( context );
                                  },
                                  child: Text('Guardar'),
                                ),

                                if (firestore.errorGeneral != null)
                                  Text(
                                    firestore.errorGeneral!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                              ],
                            )
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      )
    );
  }
}
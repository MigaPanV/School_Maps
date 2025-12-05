import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/presentation/screens/auth/loading_screen.dart';
import 'package:school_maps/presentation/widget/shared/custom_text_fields.dart';

class AddConductor extends StatelessWidget {
  const AddConductor({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreProvider firestore = context.watch<FirestoreProvider>();

    const double maxContentWidth = 800;

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

          title: Text( 'Añadir Conductor' ),

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
                                Text( 'Conductor' ),
                            
                                SizedBox( height: 20 ),

                                CustomTextField(
                                  errorText: firestore.errorNombreConductor, 
                                  labeltext: 'Ingrese nombre conductor',
                                  onChanged: firestore.getNombreConductor,
                                ),

                                SizedBox(height: 20), 

                                CustomTextField(
                                  errorText: firestore.errorDocumentoConductor, 
                                  labeltext: 'Ingrese documento conductor',
                                  onChanged: firestore.getDocumentoConductor,
                                ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorCorreoConductor, 
                                  labeltext: 'Ingrese correo conductor',
                                  onChanged: firestore.getCorreoConductor,
                                ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorFechaLicencia, 
                                  labeltext: 'Ingrese la fecha de vencimiento de la licencia',
                                  onChanged: firestore.getFechaVencimientoLicencia,
                                ),

                                SizedBox(height: 20),

                                Text( 'Bus' ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorPlacaConductor, 
                                  labeltext: 'Ingrese placa ruta asignada',
                                  onChanged: firestore.getPlaca,
                                ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorPlacaConductor, 
                                  labeltext: 'Ingrese vencimiento tecnomecanica',
                                  onChanged: firestore.getTecnoVencimiento
                                ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorPlacaConductor, 
                                  labeltext: 'Ingrese nombre monitora',
                                  onChanged: firestore.getMonitora,
                                ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorPlacaConductor, 
                                  labeltext: 'Ingrese vencimiento soat',
                                  onChanged: firestore.getSoatVencimiento,
                                ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorPlacaConductor, 
                                  labeltext: 'Ingrese capacidad max. ruta',
                                  onChanged: firestore.getCapacidad,
                                ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorPlacaConductor, 
                                  labeltext: 'Ingrese vencimiento extintor',
                                  onChanged: firestore.getExtintorVencimiento,
                                ),

                                SizedBox(height: 20),

                                CustomTextField(
                                  errorText: firestore.errorPlacaConductor, 
                                  labeltext: 'Ingrese km recorridos',
                                  onChanged: firestore.getkmRecorridos,
                                ),

                                SizedBox(height: 20),
                            
                                ElevatedButton(
                                  onPressed: firestore.isLoading ? null : () async {
                                    // Llamar addConductor y solo si fue exitosa llamar addBus
                                    final successConductor = await firestore.addConductor();

                                    if (!successConductor) {
                                      // mostrar error si existe
                                      final msg = firestore.errorGeneral ?? 'Error guardando conductor';
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                      return;
                                    }

                                    final successBus = await firestore.addBus();
                                    if (!successBus) {
                                      final msg = firestore.errorGeneral ?? 'Error guardando bus';
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                      return;
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conductor y bus guardados correctamente')));
                                  },
                                  child: firestore.isLoading ? const CircularProgressIndicator() : const Text('Guardar'),
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
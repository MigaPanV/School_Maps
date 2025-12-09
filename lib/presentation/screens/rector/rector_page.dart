import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:school_maps/presentation/provider/rector_provider.dart';
import 'package:school_maps/presentation/screens/maps/route_tracking_page.dart';
import 'package:school_maps/presentation/screens/rector/add_conductor.dart';
import 'package:school_maps/presentation/screens/rector/add_estudiante.dart';
import 'package:school_maps/presentation/screens/rector/add_padre.dart';
import 'package:school_maps/presentation/screens/rector/crear_ruta.dart';
import 'package:school_maps/presentation/widget/shared/custom_profile.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';

class RectorScreen extends StatelessWidget {
  const RectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    AuthProvider authProvider = context.watch<AuthProvider>();
    FirestoreProvider firestore = context.watch<FirestoreProvider>();
    RectorProvider rectorProvider = context.watch<RectorProvider>();
    final TextStyle styleText = TextStyle( 
      color: Colors.white
    );
    final opciones = firestore.getBuses();
    final List<String> seleccionadas = rectorProvider.seleccionadas;

    final texto = seleccionadas.isEmpty
      ? 'Selecciona una ruta'
      : seleccionadas.join(', ');
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only( top: 8.0),
            child: Text( 
              'Rector',
              style: TextStyle( 
                fontSize: 20, 
                fontWeight: FontWeight.w500
              )
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only( top: 8.0 ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomProfileScreen(),
                      ),
                  );
                }, 
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/logo.jpg'),
                  radius: 30,
                ),
              ),
            ),
            )
          ],
        ),
        body:Column(
          
          children: [
            Row(
                      
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MenuBar(
                    style: MenuStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF0D47A1)),
                    ),
                    
                    children:[
                      SubmenuButton(  
                        menuChildren: [
                          MenuItemButton(
                            onPressed: (){
                              Navigator.push( context, MaterialPageRoute<void>(
                                builder: (BuildContext context) => CrearRuta()
                                )
                              );
                            },
                            child: Text( 'Crear ruta', style: styleText )
                          ),
      
                          MenuItemButton(
                            onPressed: (){
                              // Navigator.push( context, MaterialPageRoute<void>(
                              //   builder: (BuildContext context) => EditarRuta()
                              //   )
                              // );
                            },
                            child: Text( 'Editar ruta', style: styleText ),
                          ),
                          
                          MenuItemButton(
                            onPressed: (){
                              final firestore = context.read<FirestoreProvider>();
                              firestore.resetConductorFormulario();
                              Navigator.push( context, MaterialPageRoute<void>(
                                builder: (BuildContext context) => AddConductor()
                                )
                              );
                            },
                            child: Text( 'Añadir condutor', style: styleText ),
                          ),
                          MenuItemButton(
                            onPressed: (){
                              final firestore = context.read<FirestoreProvider>();
                              firestore.resetPadreFormulario();
                              Navigator.push( context, MaterialPageRoute<void>(
                                builder: (BuildContext context) => AddPadre()
                                )
                              );
                            },
                            child: Text( 'Añadir Acudiente', style: styleText ),
                          ),
                          MenuItemButton(
                            onPressed: (){
                              Navigator.push( context, MaterialPageRoute<void>(
                                builder: (BuildContext context) => AddEstudiante()
                                )
                              );
                            },
                            child: Text( 'Añadir estudiante', style: styleText ),
                          ),
                          MenuItemButton(
                            onPressed: (){
                              authProvider.signOut();
                            },
                            child: Text( 'Cerrar sesion', style: styleText ),
                          ), 
                        ],
                        child: Text( 'Funciones', style: styleText )
                      ) 
                    ]
                  ),
                )
              ],
            ),

            Expanded(child: Center(child: RouteTrackingPage())),                  

            SizedBox( height: 20 ),
        
            ElevatedButton(
              onPressed: (){
                rectorProvider.mostrarRutas( context, opciones, seleccionadas );
              }, 
              child: Text( texto ) 
            ),
          ],
        )
      )
    ); 
  }
}
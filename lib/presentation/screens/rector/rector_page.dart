import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:school_maps/presentation/provider/rector_provider.dart';
import 'package:school_maps/presentation/screens/rector/add_padre.dart';
import 'package:school_maps/presentation/screens/rector/crear_ruta.dart';

class RectorScreen extends StatelessWidget {
  const RectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    AuthProvider authProvider = context.watch<AuthProvider>();
    RectorProvider rectorProvider = context.watch<RectorProvider>();
    final TextStyle styleText = TextStyle( 
      color: Colors.white
    );
    final List<String> opciones = ['Ruta 1', 'Ruta 2', 'Ruta 3'];
    final List<String> seleccionadas = rectorProvider.seleccionadas;

    final texto = seleccionadas.isEmpty
      ? 'Selecciona una ruta'
      : seleccionadas.join(', ');

    const double maxContentWidth = 800;
    
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
              child: IconButton(
                onPressed: (){}, 
                icon: Icon( Icons.notifications ),
                tooltip: 'Notificaciones',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only( top: 8.0, left:8.0 ),
              child: CircleAvatar(
                backgroundImage: Image.asset( 'assets/images/login.jpg' ).image,
                radius: 30,
              ),
            )
          ],
        ),
        body: Center(
          child:LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
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
                                      // Navigator.push( context, MaterialPageRoute<void>(
                                      //   builder: (BuildContext context) => AddConductor()
                                      //   )
                                      // );
                                    },
                                    child: Text( 'Añadir condutor', style: styleText ),
                                  ),
                                  MenuItemButton(
                                    onPressed: (){
                                      Navigator.push( context, MaterialPageRoute<void>(
                                        builder: (BuildContext context) => AddPadre()
                                        )
                                      );
                                    },
                                    child: Text( 'Añadir Acudiente', style: styleText ),
                                  ),
                                  MenuItemButton(
                                    onPressed: (){
                                      // Navigator.push( context, MaterialPageRoute<void>(
                                      //   builder: (BuildContext context) => AddEstudiante()
                                      //   )
                                      // );
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
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxContentWidth),
                        
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            child: Column(
                              children: [
                            
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 500,
                                    minHeight: 200,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Placeholder(),
                                  ),
                                ),
                            
                                ElevatedButton(
                                  onPressed: (){
                                    rectorProvider.mostrarRutas( context, opciones, seleccionadas );
                                  }, 
                                  child: Text( texto ) 
                                ),
                                
                                SizedBox( height: 20 ),
                              ]
                            
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              );
            }
          )
        ),
      ),
    );                                     
  }
}
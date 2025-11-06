import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:school_maps/presentation/provider/rector_provider.dart';

class RectorScreen extends StatelessWidget {
  const RectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    AuthProvider authProvider = context.watch<AuthProvider>();
    RectorProvider rectorProvider = context.watch<RectorProvider>();

    final List<String> opciones = ['Ruta 1', 'Ruta 2', 'Ruta 3'];
    final List<String> seleccionadas = rectorProvider.seleccionadas;

    final texto = seleccionadas.isEmpty
      ? 'Selecciona una opción'
      : seleccionadas.join(', ');

    final size = MediaQuery.of(context).size;
    
    if( size.width < 600 && size.height < 1000 ){

      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text( 
              'Rector',
              style: TextStyle( 
                fontSize: 20, 
                fontWeight: FontWeight.w500 
              ),
            ),
            actions: [
              IconButton(
                onPressed: (){}, 
                icon: Icon( Icons.notifications),
                tooltip: 'Notificaciones',
              ),

              Padding(
                padding: const EdgeInsets.only( right: 8, top: 8),
                child: CircleAvatar(
                  backgroundImage: Image.asset( 'assets/images/login.jpg').image,
                  radius: 25,              
                ),
              )

            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints:BoxConstraints( maxWidth: 600, maxHeight: 600 ),

                    child:  Padding(
                      padding: const EdgeInsets.symmetric( vertical: 60.0, horizontal: 20.0 ),
                      child: Placeholder(),
                    ),
                  ),

                  FilledButton(
                    onPressed: (){
                      rectorProvider.mostrarRutas( context, opciones, seleccionadas );
                    }, 
                    child: Text( texto ) 
                  ),

                  SizedBox( height: 20 ),
                ],
              )
            ),
          ),
        )
      );
    }
    else{
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
                padding: const EdgeInsets.only( top: 8.0),
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
            child:SingleChildScrollView(
              child: Column(
                children: [

                  ConstrainedBox(
                    constraints:BoxConstraints( maxWidth: 600, maxHeight: 600 ),

                    child:  Padding(
                      padding: const EdgeInsets.symmetric( vertical: 40.0, horizontal: 20.0 ),
                      child: Placeholder(),
                    ),
                  ),


                  FilledButton(
                    onPressed: (){
                      rectorProvider.mostrarRutas( context, opciones, seleccionadas );
                    }, 
                    child: Text( texto ) 
                  ),
                  
                  SizedBox( height: 20 ),
                ]

              )
            )
          ),
        ),
      );
    }
  }
}
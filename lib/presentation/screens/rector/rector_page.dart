import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';

class RectorScreen extends StatelessWidget {
  const RectorScreen({super.key});

  @override
  Widget build(BuildContext context) {

    AuthProvider authProvider = context.watch<AuthProvider>();
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text( 
            'Rector',
            style: TextStyle( fontSize: 20, fontWeight: FontWeight.w500 ),
          ),
          actions: [
            IconButton(
              onPressed: (){}, 
              icon: Icon( Icons.notifications)
            ),
            CircleAvatar(
              radius: 20,
              child: Image(image: AssetImage( 'assets/images/login.jpg'),
              ),
              
            )

          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text( 'Rector Screen' ),
                SizedBox( height: 20 ),
                FilledButton(
                  onPressed: (){
                    authProvider.signOut();
                    },
                  child: Text( 'Cerrar sesion')
                )

              ],
            )
          ),
        ),
      )
    );
  }
}
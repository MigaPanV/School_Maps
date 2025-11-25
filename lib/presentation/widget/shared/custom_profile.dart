import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';

class CustomProfileScreen extends StatelessWidget {
  const CustomProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final AuthProvider auth = context.watch<AuthProvider>();
    final FirestoreProvider firestoreProvider = context.watch<FirestoreProvider>();

    final user = auth.user;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          centerTitle: true,
        ),
        body: FutureBuilder(
        future: firestoreProvider.getUserData( user!.uid ),
        builder: (context, snapshot) {
        
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
      
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
      
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No se encontraron datos del usuario"),
            );
          }
      
          final usuario = snapshot.data!;
      
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 60),
                          ),
                          const SizedBox(height: 20),
                          Text( 'Nombre de usuario: ${usuario.nombre}', ),
                          const SizedBox(height: 20),
                          Text( 'Nombre de usuario: ${usuario.correo}', ),
                          // Text( 'Nombre de usuario: ${usuario.documentoHijo[0]}', )
                        ],
                      ),
                    ),
                  ),
      
                  ElevatedButton(
                    onPressed: () {
                      auth.signOut();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    child: const Text(
                      "Cerrar sesión",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
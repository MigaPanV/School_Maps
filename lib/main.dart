import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/screens/rector/rector_page.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:school_maps/presentation/screens/auth/auth_page.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart' as auth;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider( create: (_) => auth.AuthProvider())
      ],
      child: Consumer<auth.AuthProvider>(
        builder: ( context, authprovider, child ) {

          return MaterialApp(
            
            debugShowCheckedModeBanner: false,
            title: 'School Maps',
            theme: ThemeData(
              primaryColor: const Color(0xFF0D47A1), // azul oscuro personalizado
              scaffoldBackgroundColor: const Color(0xFF102A43), // color de fondo de toda la app
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF102A43),
                foregroundColor: Colors.white, // color del texto en el AppBar
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white
                )
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
              ),
              
    ),            
            home:AuthScreen()
            
          );
        }
      )
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: ( context, snapshot ){
        
        if( snapshot.connectionState == ConnectionState.waiting ){
          return const Center(
            child: CircularProgressIndicator()
          );
        }

        if( snapshot.hasData ){

          return RectorScreen();

        }
        else{

          return const AuthPage();

        }
      }
    );
  }
}

class HomePage extends StatelessWidget {
    const HomePage({super.key});
  
    @override
    Widget build(BuildContext context) {

      final auth.AuthProvider authProvider = context.watch<auth.AuthProvider>();
      return Scaffold(
        
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text( 'Bienvenido' ),
              ElevatedButton(
                onPressed: (){
                  authProvider.signOut();
                },
                child: Text( 'Cerrar sesion' )
              )
            ],

          )
        )
      );
    }
  }
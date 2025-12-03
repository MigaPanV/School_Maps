import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/firestore_provider.dart';
import 'package:school_maps/presentation/provider/rector_provider.dart';
import 'package:school_maps/presentation/screens/rector/rector_page.dart';
import 'package:school_maps/presentation/screens/conductor/conductor_page.dart';
import 'package:school_maps/presentation/screens/padre/padre_page.dart';
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
        ChangeNotifierProvider( create: (_) => auth.AuthProvider()),
        ChangeNotifierProvider( create: (_) => RectorProvider()),
        ChangeNotifierProvider( create: (_) => FirestoreProvider())
      ],
      child: Consumer<auth.AuthProvider>(
        builder: ( context, authprovider, child ) {

          return MaterialApp(
            
            debugShowCheckedModeBanner: false,
            title: 'School Maps',
            theme: ThemeData(
              primaryColor: const Color(0xFF0D47A1),
              scaffoldBackgroundColor: const Color(0xFF102A43),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF102A43),
                foregroundColor: Colors.white,
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
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color?>{
                  WidgetState.selected: Color( 0xFF0D47A1 ),
                })
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white
                )
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
              ),

              menuTheme: MenuThemeData(
                style: MenuStyle(
                  alignment: AlignmentGeometry.center,
                  backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF0D47A1)),
                )
              )
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
        
        if( !snapshot.hasData ){

          return const AuthPage();

        }
        
        final uId = snapshot.data!.uid;

        return FutureBuilder<String?>(
          future: context.read<FirestoreProvider>().getUserRole(uId), 
          builder: (context, roleSnapshot){

            if(!roleSnapshot.hasData){

              return Center(child: CircularProgressIndicator());

            }

            final rol = roleSnapshot.data;

            if( rol == 'Padre') return PadreScreen();
            if( rol == 'Conductor' ) return CondScreen();
            if( rol == 'Rector' ) return RectorScreen();

            return AuthPage();
          }
        );

      }
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:school_maps/screens/authpage.dart';
import 'package:school_maps/presentation/authprovider.dart' as auth;

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
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.black)
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

          return HomePage();

        }
        else{

          return const AuthPage();
        }
      });
  }

}

class HomePage extends StatelessWidget {
    const HomePage({super.key});
  
    @override
    Widget build(BuildContext context) {
      return Placeholder();
    }
  }
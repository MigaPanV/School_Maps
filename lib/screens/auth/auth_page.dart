import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/authprovider.dart';
import 'package:school_maps/screens/auth/loading_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    
    AuthProvider authProvider = Provider.of<AuthProvider>( context );
    LoadingScreen loadingScreen = LoadingScreen( text: authProvider.isLogin ? 'Iniciando sesion' : 'Registrando usuario' );

    Future<void> handleAuth() async {

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if( authProvider.isLoading ){

        loadingScreen;
      }


      if( authProvider.isLogin ){

        await authProvider.singIn(email, password);
        
      } else {

        await authProvider.register(email, password);
        await authProvider.singOut();
        authProvider.toggleisLogin();

      }
    }

    return SafeArea(
      child: Scaffold(
        
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  
                mainAxisAlignment: MainAxisAlignment.center,

                  
                children: [

                  Text( 
                    authProvider.isLogin ? 'Iniciar sesion' : 'Registrarse', 
                    style: TextStyle(
                      fontSize: 30, 
                      fontWeight: FontWeight.w500 
                    ) 
                  ),
                  
                  SizedBox(height: 50),

                  CircleAvatar(
                    backgroundImage: Image.network( 'https://i.pinimg.com/736x/0b/a4/12/0ba4126ee79560250648ebe4d7a43f01.jpg' ).image,
                    radius: 100,
                    
                  ),

                  SizedBox(height: 50),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email' ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Constraseña' ),
                    obscureText: true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: handleAuth,
                    child: Text( authProvider.isLogin ? 'Sign in' : 'Register' ),
                  ),
                  
                  TextButton(
                    onPressed: (){
                      
                      authProvider.toggleisLogin();
                  
                    },
                    child: Text( authProvider.isLogin ? '¿No tienes cuenta? Registrate' : '¿Ya tienes cuenta? Inicia sesion')
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
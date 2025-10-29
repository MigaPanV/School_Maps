import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/authprovider.dart';
import 'package:school_maps/presentation/screens/auth/loading_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    
    AuthProvider authProvider = Provider.of<AuthProvider>( context );

    Future<void> handleAuth() async {

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if( authProvider.isLogin ){

        if( email.isEmpty || password.isEmpty) return;
        await authProvider.singIn(email, password);
        
      } else {

        if( email.isEmpty || password.isEmpty) return;

        await authProvider.register(email, password);
        await authProvider.singOut();
        authProvider.toggleisLogin();

      }
    }

    if( authProvider.isLoading ){
      return LoadingScreen( text: authProvider.isLogin ? 'Iniciando sesion' : 'Registrando usuario' );
    }

    return SafeArea(
      child: Scaffold(
        
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
              ),
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
                      backgroundImage: Image.asset( 'assets/images/login.jpg' ).image,
                      radius: 100,
                      
                    ),
              
                    SizedBox(height: 50),
              
                    TextField(
                      controller: emailController,
              
                      decoration: InputDecoration(
                        
                        hintText: 'Email',
                        labelStyle: TextStyle( 
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide( color: Colors.white ),
                          borderRadius: BorderRadius.circular( 12 ),
                        ),
              
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide( color: Colors.blueAccent ),
                          borderRadius: BorderRadius.circular( 12 )
                        ),
              
                      ),
              
                    ),
                    
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        
                        hintText: 'Contraseña',
                        labelStyle: TextStyle( 
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide( color: Colors.white ),
                          borderRadius: BorderRadius.circular( 12 ),
                        ),
              
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide( color: Colors.blueAccent ),
                          borderRadius: BorderRadius.circular( 12 )
                        ),
              
                      ),
                      obscureText: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ElevatedButton(
                      onPressed: handleAuth,
                      child: Text( authProvider.isLogin ? 'Iniciar sesión' : 'Registrarse' ),
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
      ),
    );
  }
}
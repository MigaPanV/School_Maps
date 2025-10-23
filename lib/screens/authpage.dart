import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/authprovider.dart';

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

        await authProvider.singIn(email, password);
        
      } else {

        await authProvider.register(email, password);

      }
    }

    return Scaffold(
      appBar: AppBar(title: Text( authProvider.isLogin ? 'Iniciar sesion' : 'Registrarse' )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [
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
            )
          ],
        ),
      ),
    );
  }
}
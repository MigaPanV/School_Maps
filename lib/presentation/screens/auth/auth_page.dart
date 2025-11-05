import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_maps/presentation/provider/auth_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    Future<void> handleAuth() async {
      authProvider.email = emailController.text.trim();
      authProvider.password = passwordController.text.trim();

      if (!authProvider.validateTextField()) return;

      if (authProvider.isLogin) {
        await authProvider.signIn();
      } else {
        await authProvider.register(authProvider.email, authProvider.password);
        await authProvider.signOut();
        authProvider.toggleIsLogin();
      }
    }

    // Mantener el correo escrito después de error
    if (authProvider.email.isNotEmpty && emailController.text.isEmpty) {
      emailController.text = authProvider.email;
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          authProvider.isLogin ? 'Iniciar sesión' : 'Registrarse',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 50),
                        CircleAvatar(
                          backgroundImage: Image.asset( 'assets/images/login.jpg' ).image,
                          radius: 100,
                      
                        ),
                        const SizedBox(height: 50),
                        TextField(
                          controller: emailController,
                          onChanged: (value) {
                            authProvider.localValidateEmail(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Correo electrónico',
                            errorText: authProvider.emailError,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          onChanged: (value) {
                            authProvider.localValidatePassword(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            errorText: authProvider.passwordError,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (authProvider.generalError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              authProvider.generalError!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: handleAuth,
                          child: Text(authProvider.isLogin ? 'Iniciar sesión' : 'Registrarse'),
                        ),

                        TextButton(
                          onPressed: authProvider.toggleIsLogin,
                          child: Text(
                            authProvider.isLogin
                                ? '¿No tienes cuenta? Regístrate'
                                : '¿Ya tienes cuenta? Inicia sesión',
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (authProvider.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
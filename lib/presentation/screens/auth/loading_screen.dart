
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          CircularProgressIndicator(),
          Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
        ]),
      ),
    );
  }
}
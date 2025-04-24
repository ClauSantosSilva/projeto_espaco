import 'package:flutter/material.dart';
import 'package:projeto_espaco/splash_screen.dart';
import 'package:projeto_espaco/tela_login.dart';
import 'tela_principal.dart';
import 'theme.dart'; //  importa o tema

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Espaço Beleza',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema, // aplica o tema aqui
      home: SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:projeto_espaco/prefs_usuario.dart';
import 'package:projeto_espaco/tela_cad_usuario.dart';
import 'package:projeto_espaco/tela_principal.dart';
import 'package:projeto_espaco/tela_recuperar_senha.dart';
import 'package:projeto_espaco/usuario.dart';
import 'theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  Usuario? _usuarioLogado;

  void _login() async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    Usuario usuario = Usuario('', email, senha);
    bool sucesso = await usuario.login();

    if (sucesso) {
      _usuarioLogado = usuario;
      await PrefsUsuario.salvarUsuario(
        id: usuario.id!,
        nome: usuario.nome,
        email: usuario.email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaPrincipal()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login. Verifique suas credenciais!')),
      );
    }
  }

  Widget _campoTexto(String label, TextEditingController controller,
      {bool ocultar = false, TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlue[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 180,
                ),
              ),
              SizedBox(height: 30),
              _campoTexto('E-mail', _emailController, tipo: TextInputType.emailAddress),
              SizedBox(height: 12),
              _campoTexto('Senha', _senhaController, ocultar: true),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CadastroScreen()),
                  );
                },
                child: Text('Ainda não tenho uma conta! Cadastre-se'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaRecuperarSenha(idUsuario: 999)),
                  );
                },
                child: Text('Esqueci minha senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

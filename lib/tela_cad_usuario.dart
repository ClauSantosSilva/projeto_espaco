import 'package:flutter/material.dart';
import 'package:projeto_espaco/usuario.dart';
import 'package:projeto_espaco/prefs_usuario.dart';
import 'theme.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _carregando = false;

  void _cadastrar() async {
    setState(() => _carregando = true);

    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos!')),
      );
      setState(() => _carregando = false);
      return;
    }

    Usuario usuario = Usuario(nome, email, senha);
    bool sucesso = await usuario.cadastrarUsuario();

    if (sucesso && usuario.id != null) {
      await PrefsUsuario.salvarUsuario(
        id: usuario.id!,
        nome: usuario.nome,
        email: usuario.email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar. Tente novamente!')),
      );
    }

    setState(() => _carregando = false);
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
        title: Text("Cadastro de Usuário"),
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
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/logo.png', height: 180),
              ),
              SizedBox(height: 30),
              _campoTexto('Nome', _nomeController),
              SizedBox(height: 12),
              _campoTexto('E-mail', _emailController, tipo: TextInputType.emailAddress),
              SizedBox(height: 12),
              _campoTexto('Senha', _senhaController, ocultar: true),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _carregando ? null : _cadastrar,
                child: _carregando
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Cadastrar'),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Já tenho uma conta! Faça login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

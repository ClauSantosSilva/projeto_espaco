import 'package:flutter/material.dart';
import 'package:projeto_espaco/recuperar_senha.dart';
import 'theme.dart';

class TelaRecuperarSenha extends StatefulWidget {
  final int idUsuario;

  TelaRecuperarSenha({required this.idUsuario});

  @override
  _TelaRecuperarSenhaState createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  final RecuperarSenha _recuperarSenha = RecuperarSenha();

  void _salvarNovaSenha() async {
    String novaSenha = _novaSenhaController.text.trim();
    String confirmarSenha = _confirmarSenhaController.text.trim();

    if (novaSenha.isEmpty || confirmarSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    if (novaSenha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não coincidem!')),
      );
      return;
    }

    bool sucesso = await _recuperarSenha.redefinirSenha(widget.idUsuario, novaSenha);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha redefinida com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao redefinir senha')),
      );
    }
  }

  Widget _campoSenha(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redefinir Senha'),
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
              SizedBox(height: 40),
              Icon(Icons.lock_reset, size: 80, color: AppTheme.azulClaro),
              SizedBox(height: 30),
              _campoSenha('Nova Senha', _novaSenhaController),
              SizedBox(height: 20),
              _campoSenha('Confirmar Senha', _confirmarSenhaController),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _salvarNovaSenha,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

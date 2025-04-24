import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Usuario {
  int? id;
  String nome;
  String email;
  String senha;

  Usuario(this.nome, this.email, this.senha);

  final String url = "http://10.87.104.15:3000/usuario";

  static const _usuarioTeste = {
    'id': 999,
    'nome': 'Claudia Teste',
    'email': 'teste@espaco.com',
    'senha': '123456',
  };

  Future<bool> cadastrarUsuario() async {
    try {
      final response = await http.post(
        Uri.parse("$url/cadastrar"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nome,
          'email': email,
          'senha': senha,
          'nome_negocio': '',
          'cpf_cnpj': '',
          'telefone': '',
          'cep': '',
          'numero': '',
          'complemento': '',
          'tipo_acesso': 'usuario'
        }),
      );

      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        id = data['insertId'];
        await salvarLocalmente();
        return true;
      } else {
        print("Erro no cadastro: ${response.body}");
      }
    } catch (e) {
      print("Erro ao cadastrar: $e");
    }
    return false;
  }

  Future<bool> login() async {
    if (email == _usuarioTeste['email'] && senha == _usuarioTeste['senha']) {
      id = _usuarioTeste['id'] as int;
      nome = _usuarioTeste['nome'] as String;
      await salvarLocalmente();
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse("$url/login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        id = data['id'];
        nome = data['nome'];
        await salvarLocalmente();
        return true;
      } else {
        print("Erro login: ${response.body}");
      }
    } catch (e) {
      print("Erro ao fazer login: $e");
    }
    return false;
  }

  Future<void> salvarLocalmente() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usuario_id', id ?? 0);
    await prefs.setString('usuario_nome', nome);
    await prefs.setString('usuario_email', email);
    await prefs.setString('usuario_senha', senha);
  }

  static Future<Usuario?> carregarUsuarioSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('usuario_id');
    String? nome = prefs.getString('usuario_nome');
    String? email = prefs.getString('usuario_email');
    String? senha = prefs.getString('usuario_senha');

    if (id != null && nome != null && email != null && senha != null) {
      Usuario usuario = Usuario(nome, email, senha);
      usuario.id = id;
      return usuario;
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_id');
    await prefs.remove('usuario_nome');
    await prefs.remove('usuario_email');
    await prefs.remove('usuario_senha');
  }
}

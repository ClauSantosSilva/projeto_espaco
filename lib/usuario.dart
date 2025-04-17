import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Usuario {
  int? id;
  String nome;
  String email;
  String senha;

  Usuario(this.nome, this.email, this.senha);

  final String url = "http://localhost:3000/usuario";

  // Usuário fixo para testes
  static const _usuarioTeste = {
    'id': 999,
    'nome': 'Claudia Teste',
    'email': 'teste@espaco.com',
    'senha': '123456',
  };

  // Cadastrar usuário no backend
  Future<bool> cadastrarUsuario() async {
    try {
      final response = await http.post(
        Uri.parse("$url/cadastrar"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nome,
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        id = data['id'];
        await salvarLocalmente();
        return true;
      }
    } catch (e) {
      print("Erro ao cadastrar: $e");
    }
    return false;
  }

  // Login do usuário (primeiro tenta login fixo, depois via backend)
  Future<bool> login() async {
    // Verifica se é o usuário fixo de teste
    if (email == _usuarioTeste['email'] && senha == _usuarioTeste['senha']) {
      id = _usuarioTeste['id'] as int;
      nome = _usuarioTeste['nome'] as String;
      await salvarLocalmente();
      return true;
    }

    // Senão, tenta login no backend
    try {
      final response = await http.post(
        Uri.parse("$url/login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        id = data['id'];
        nome = data['nome'];
        await salvarLocalmente();
        return true;
      }
    } catch (e) {
      print("Erro ao fazer login: $e");
    }
    return false;
  }

  // Salvar dados localmente
  Future<void> salvarLocalmente() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usuario_id', id ?? 0);
    await prefs.setString('usuario_nome', nome);
    await prefs.setString('usuario_email', email);
    await prefs.setString('usuario_senha', senha);
  }

  // Carregar usuário salvo
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

  // Limpar dados (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_id');
    await prefs.remove('usuario_nome');
    await prefs.remove('usuario_email');
    await prefs.remove('usuario_senha');
  }
}

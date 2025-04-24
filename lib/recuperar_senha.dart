import 'dart:convert';
import 'package:http/http.dart' as http;

class RecuperarSenha {
  final String url = "http://10.0.2.2:3000/"; // Ajuste conforme necessário

  // Método para redefinir senha
  Future<bool> redefinirSenha(int idUsuario, String novaSenha) async {
    try {
      final response = await http.put(
        Uri.parse("${url}alterar_senha/$idUsuario"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'senha': novaSenha,
        }),
      );

      if (response.statusCode == 200) {
        print("Senha alterada com sucesso!");
        return true;
      } else {
        print("Erro ao alterar senha: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erro na requisição: $e");
      return false;
    }
  }
}

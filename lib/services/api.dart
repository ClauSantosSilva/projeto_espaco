import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String baseUrl = 'http://192.168.56.1:3000'; // Altere para o IP local da sua API

  static Future<Map<String, dynamic>?> login(String email, String senha) async {
    var response = await http.post(
      Uri.parse('$baseUrl/usuario/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "senha": senha}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> getServicos(int usuarioId) async {
    var response = await http.get(
      Uri.parse('$baseUrl/servicos?usuario_id=$usuarioId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }

  static Future<bool> agendar(int usuarioId, int servicoId) async {
    final now = DateTime.now();
    String data = now.toIso8601String().substring(0, 10);
    String hora = now.toIso8601String().substring(11, 19);

    var response = await http.post(
      Uri.parse('$baseUrl/agendamento'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "data": data,
        "hora": hora,
        "servicos_id": servicoId,
        "usuario_id": usuarioId,
      }),
    );

    return response.statusCode == 200;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class Agenda {
  DateTime data;
  String hora;
  String nomeCliente;
  String nomeServico;
  String telefoneCliente;

  Agenda({
    required this.data,
    required this.hora,
    required this.nomeCliente,
    required this.nomeServico,
    required this.telefoneCliente,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data.toIso8601String(),
      'hora': hora,
      'nome_cliente': nomeCliente,
      'servico': nomeServico,
      'telefone_cliente': telefoneCliente,
    };
  }

  static Agenda fromMap(Map<String, dynamic> map) {
    return Agenda(
      data: DateTime.parse(map['data']),
      hora: map['hora']?.toString() ?? '',
      nomeCliente: map['nome_cliente'] ?? '',
      nomeServico: map['servico'] ?? '',
      telefoneCliente: map['telefone_cliente'] ?? '',
    );
  }

  static const String baseUrl = "http://localhost:3000";

  Future<bool> salvarAgenda() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/agenda"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(toMap()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erro ao salvar agenda: $e");
      return false;
    }
  }

  static Future<List<Agenda>> listarAgendas() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/agendas"));
      if (response.statusCode == 200) {
        final List<dynamic> lista = json.decode(response.body);
        return lista.map((item) => Agenda.fromMap(item)).toList();
      }
    } catch (e) {
      print("Erro ao buscar agendas: $e");
    }
    return [];
  }

  static Future<List<Agenda>> buscarPorData(DateTime dataSelecionada) async {
    try {
      final String dataFormatada = dataSelecionada.toIso8601String();
      final response = await http.get(Uri.parse("$baseUrl/agendas/data?data=$dataFormatada"));
      if (response.statusCode == 200) {
        final List<dynamic> lista = json.decode(response.body);
        return lista.map((item) => Agenda.fromMap(item)).toList();
      }
    } catch (e) {
      print("Erro ao buscar agendamentos por data: $e");
    }
    return [];
  }
}

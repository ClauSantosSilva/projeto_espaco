import 'dart:convert';
import 'package:http/http.dart' as http;

class Servico {
  final String id;
  final String descricao;
  final String valor;

  Servico({required this.id, required this.descricao, required this.valor});

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'].toString(),
      descricao: json['descricao'],
      valor: json['valor'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'valor': valor,
    };
  }

  static String url = "http://10.87.104.15:3000";

  /// Carrega todos os serviços do servidor
  static Future<List<Servico>> carregarServicos() async {
    final response = await http.get(Uri.parse("${url}listar_servicos"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Servico.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar serviços');
    }
  }

  /// Cadastra um novo serviço
  static Future<bool> cadastrarServico(String descricao, String valor) async {
    final valorFormatado = _formatarValor(valor);
    final response = await http.post(
      Uri.parse("${url}cadastrar_servico"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'descricao': descricao, 'valor': valorFormatado}),
    );
    return response.statusCode == 200;
  }

  /// Edita um serviço existente
  static Future<bool> editarServico(String id, String descricao, String valor) async {
    final valorFormatado = _formatarValor(valor);
    final response = await http.put(
      Uri.parse("${url}editar_servico/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'descricao': descricao, 'valor': valorFormatado}),
    );
    return response.statusCode == 200;
  }

  /// Exclui um serviço pelo ID
  static Future<bool> excluirServico(String id) async {
    final response = await http.delete(
      Uri.parse("${url}excluir_servico/$id"),
    );
    return response.statusCode == 200;
  }

  /// Formata o valor aceitando vírgula ou ponto
  static String _formatarValor(String valor) {
    return valor.replaceAll(',', '.');
  }
}

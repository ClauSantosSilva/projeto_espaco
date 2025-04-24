import 'dart:convert';
import 'package:http/http.dart' as http;

class Orcamento {
  final String apiUrl = "http://10.87.104.15:3000";  // Substitua pelo seu URL da API

  // Função para salvar o orçamento
  Future<void> salvarOrcamento(String nome, String telefone, List<Map<String, dynamic>> servicos, double total, String desconto) async {
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'nome': nome,
          'telefone': telefone,
          'servicos': servicos,
          'total': total,
          'desconto': desconto,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Orçamento salvo com sucesso');
      } else {
        print('Erro ao salvar orçamento: ${response.body}');
      }
    } catch (e) {
      print('Erro ao conectar ao servidor: $e');
    }
  }

  // Função para editar o orçamento
  Future<void> editarOrcamento(int id, String nome, String telefone, List<Map<String, dynamic>> servicos, double total, String desconto) async {
    try {
      var response = await http.put(
        Uri.parse('$apiUrl/$id'),
        body: json.encode({
          'nome': nome,
          'telefone': telefone,
          'servicos': servicos,
          'total': total,
          'desconto': desconto,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Orçamento editado com sucesso');
      } else {
        print('Erro ao editar orçamento: ${response.body}');
      }
    } catch (e) {
      print('Erro ao conectar ao servidor: $e');
    }
  }

  // Função para excluir o orçamento
  Future<void> excluirOrcamento(int id) async {
    try {
      var response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Orçamento excluído com sucesso');
      } else {
        print('Erro ao excluir orçamento: ${response.body}');
      }
    } catch (e) {
      print('Erro ao conectar ao servidor: $e');
    }
  }
}

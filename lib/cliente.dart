import 'dart:convert';
import 'package:http/http.dart' as http;

class Cliente {
  int? id;  // Adicionando o campo 'id'
  String? nome;
  String? telefone;
  String? cpf;

  final String url = "http://localhost:3000"; // URL do backend (ajustar conforme necessário)

  // Construtor
  Cliente({this.id, this.nome, this.telefone, this.cpf});

  // Método para cadastrar um novo cliente no banco de dados
  Future<bool> cadastrarCliente() async {
    if (nome == null || telefone == null || cpf == null) {
      // Validação dos campos obrigatórios
      throw Exception('Nome, Telefone e CPF são obrigatórios');
    }

    try {
      final respostaBackend = await http.post(
        Uri.parse("${url}cadastrar_cliente"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'nome': nome,
          'telefone': telefone,
          'cpf': cpf,
        }),
      );

      if (respostaBackend.statusCode == 200) {
        final responseBody = jsonDecode(respostaBackend.body);
        id = responseBody['id']; // Atribuindo o id retornado pelo backend
        return true;  // Cliente cadastrado com sucesso
      } else {
        print('Erro ao cadastrar: ${respostaBackend.statusCode}');
        return false;  // Falha ao cadastrar cliente
      }
    } catch (e) {
      print('Erro ao cadastrar cliente: $e');
      return false;  // Falha ao fazer a requisição
    }
  }

  // Método para editar dados de um cliente
  Future<bool> editarCliente(int id) async {
    if (nome == null || telefone == null || cpf == null) {
      // Validação dos campos obrigatórios
      throw Exception('Nome, Telefone e CPF são obrigatórios');
    }

    try {
      final respostaBackend = await http.put(
        Uri.parse("${url}editar_cliente/$id"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'nome': nome,
          'telefone': telefone,
          'cpf': cpf,
        }),
      );

      if (respostaBackend.statusCode == 200) {
        return true;  // Cliente editado com sucesso
      } else {
        print('Erro ao editar: ${respostaBackend.statusCode}');
        return false;  // Falha ao editar cliente
      }
    } catch (e) {
      print('Erro ao editar cliente: $e');
      return false;  // Falha ao fazer a requisição
    }
  }

  // Método para excluir um cliente
  Future<bool> excluirCliente(int id) async {
    try {
      final respostaBackend = await http.delete(
        Uri.parse("${url}excluir_cliente/$id"),
      );

      if (respostaBackend.statusCode == 200) {
        return true;  // Cliente excluído com sucesso
      } else {
        print('Erro ao excluir: ${respostaBackend.statusCode}');
        return false;  // Falha ao excluir cliente
      }
    } catch (e) {
      print('Erro ao excluir cliente: $e');
      return false;  // Falha ao fazer a requisição
    }
  }
}

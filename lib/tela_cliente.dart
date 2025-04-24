import 'package:flutter/material.dart';
import 'theme.dart';

class TelaCliente extends StatefulWidget {
  @override
  _TelaClienteState createState() => _TelaClienteState();
}

class _TelaClienteState extends State<TelaCliente> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<Map<String, String>> _clientes = [];
  int? _clienteEditandoIndex;

  void _adicionarOuEditarCliente() {
    if (_nomeController.text.isEmpty || _telefoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha nome e telefone")),
      );
      return;
    }

    final novoCliente = {
      'nome': _nomeController.text,
      'telefone': _telefoneController.text,
      'email': _emailController.text,
    };

    setState(() {
      if (_clienteEditandoIndex == null) {
        _clientes.add(novoCliente);
        _mensagem("Cliente adicionado com sucesso!");
      } else {
        _clientes[_clienteEditandoIndex!] = novoCliente;
        _mensagem("Cliente alterado com sucesso!");
      }
      _limparCampos();
    });
  }

  void _editarCliente(int index) {
    setState(() {
      _clienteEditandoIndex = index;
      _nomeController.text = _clientes[index]['nome'] ?? '';
      _telefoneController.text = _clientes[index]['telefone'] ?? '';
      _emailController.text = _clientes[index]['email'] ?? '';
    });
  }

  void _removerCliente(int index) {
    setState(() {
      _clientes.removeAt(index);
      _limparCampos();
    });
  }

  void _limparCampos() {
    _nomeController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _clienteEditandoIndex = null;
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Clientes')),
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
              _campoTexto('Nome', _nomeController),
              SizedBox(height: 12),
              _campoTexto('Telefone', _telefoneController, tipo: TextInputType.phone),
              SizedBox(height: 12),
              _campoTexto('Email (opcional)', _emailController, tipo: TextInputType.emailAddress),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _adicionarOuEditarCliente,
                child: Text(_clienteEditandoIndex == null ? "Salvar Cliente" : "Salvar Alterações"),
              ),
              if (_clienteEditandoIndex != null)
                TextButton(
                  onPressed: _limparCampos,
                  child: Text("Cancelar Edição"),
                ),
              SizedBox(height: 20),
              Divider(),
              Text("Clientes Cadastrados", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 12),
              _clientes.isEmpty
                  ? Text("Nenhum cliente cadastrado.")
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _clientes.length,
                itemBuilder: (context, index) {
                  final cliente = _clientes[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(cliente['nome'] ?? ''),
                      subtitle: Text('Telefone: ${cliente['telefone']}\nEmail: ${cliente['email'] ?? 'Não informado'}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: AppTheme.azulClaro),
                            onPressed: () => _editarCliente(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _removerCliente(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(String label, TextEditingController controller,
      {TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: label),
    );
  }
}

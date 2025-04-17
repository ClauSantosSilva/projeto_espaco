import 'package:flutter/material.dart';
import 'servico.dart'; // ajuste o caminho conforme sua estrutura
import 'theme.dart';  // seu arquivo de tema com AppTheme.azulClaro

class ServicosScreen extends StatefulWidget {
  @override
  _ServicosScreenState createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  String? _servicoId;
  List<Servico> _servicos = [];

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    try {
      final lista = await Servico.carregarServicos();
      setState(() {
        _servicos = lista;
      });
    } catch (e) {
      _mensagem("Erro ao carregar serviços.");
    }
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;

    final descricao = _descricaoController.text.trim();
    final valor = _valorController.text.trim();

    bool sucesso;
    if (_servicoId == null) {
      sucesso = await Servico.cadastrarServico(descricao, valor);
    } else {
      sucesso = await Servico.editarServico(_servicoId!, descricao, valor);
    }

    if (sucesso) {
      _mensagem("Serviço salvo com sucesso!");
      _limparCampos();
      await _carregarServicos();
    } else {
      _mensagem("Erro ao salvar serviço.");
    }
  }

  void _editarServico(Servico servico) {
    setState(() {
      _servicoId = servico.id;
      _descricaoController.text = servico.descricao;
      _valorController.text = servico.valor.replaceAll('.', ',');
    });
  }

  Future<void> _excluirServico(Servico servico) async {
    final sucesso = await Servico.excluirServico(servico.id);
    if (sucesso) {
      _mensagem("Serviço excluído.");
      await _carregarServicos();
    } else {
      _mensagem("Erro ao excluir.");
    }
  }

  void _limparCampos() {
    setState(() {
      _servicoId = null;
      _descricaoController.clear();
      _valorController.clear();
    });
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Serviços")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlue[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // campo oculto de ID (opcionalmente exibido no debug)
              if (_servicoId != null)
                Text("ID: $_servicoId", style: TextStyle(fontSize: 12, color: Colors.grey)),

              TextFormField(
                controller: _descricaoController,
                decoration: _inputStyle("Descrição"),
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe a descrição' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _valorController,
                decoration: _inputStyle("Valor"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  final valor = value.replaceAll(',', '.');
                  final v = double.tryParse(valor);
                  if (v == null || v <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvarServico,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.azulClaro,
                ),
                child: Text(_servicoId == null ? "Cadastrar Serviço" : "Salvar Alterações"),
              ),
              TextButton(
                onPressed: _limparCampos,
                child: Text("Limpar", style: TextStyle(color: Colors.grey[700])),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _servicos.isEmpty
                    ? Center(child: Text("Nenhum serviço cadastrado."))
                    : ListView.builder(
                  itemCount: _servicos.length,
                  itemBuilder: (context, index) {
                    final s = _servicos[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(s.descricao),
                        subtitle: Text("R\$ ${s.valor.replaceAll('.', ',')}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: AppTheme.azulClaro),
                              onPressed: () => _editarServico(s),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _excluirServico(s),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

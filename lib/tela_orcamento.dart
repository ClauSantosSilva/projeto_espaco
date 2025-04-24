// Imports mantidos

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class TelaOrcamento extends StatefulWidget {
  @override
  _TelaOrcamentoState createState() => _TelaOrcamentoState();
}

class _TelaOrcamentoState extends State<TelaOrcamento> {
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final List<String> _servicos = ['Corte de cabelo', 'Manicure', 'Pedicure'];
  String? _servicoSelecionado;
  double? _valorTotal;
  int? _orcamentoEditandoIndex;

  final Map<String, double> _valoresServicos = {
    'Corte de cabelo': 30.0,
    'Manicure': 20.0,
    'Pedicure': 25.0,
  };

  List<String> _servicosSelecionados = [];
  List<Map<String, dynamic>> _orcamentos = [];

  void _adicionarOuEditarOrcamento() {
    if (_clienteController.text.isEmpty ||
        _telefoneController.text.isEmpty ||
        _servicosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos e selecione ao menos um serviço!')),
      );
      return;
    }

    final novoOrcamento = {
      'cliente': _clienteController.text,
      'telefone': _telefoneController.text,
      'servicos': List<String>.from(_servicosSelecionados),
      'valorTotal': _valorTotal ?? 0.0,
    };

    setState(() {
      if (_orcamentoEditandoIndex == null) {
        _orcamentos.add(novoOrcamento);
        _mensagem("Orçamento adicionado com sucesso!");
      } else {
        _orcamentos[_orcamentoEditandoIndex!] = novoOrcamento;
        _mensagem("Orçamento alterado com sucesso!");
      }
      _limparCampos();
    });
  }

  void _editarOrcamento(int index) {
    final orcamento = _orcamentos[index];
    setState(() {
      _orcamentoEditandoIndex = index;
      _clienteController.text = orcamento['cliente'];
      _telefoneController.text = orcamento['telefone'];
      _servicosSelecionados = List<String>.from(orcamento['servicos']);
      _calcularTotal();
    });
  }

  void _removerOrcamento(int index) {
    setState(() {
      _orcamentos.removeAt(index);
      _limparCampos();
    });
  }

  void _limparCampos() {
    _clienteController.clear();
    _telefoneController.clear();
    _servicoSelecionado = null;
    _servicosSelecionados.clear();
    _valorTotal = null;
    _orcamentoEditandoIndex = null;
  }

  void _calcularTotal() {
    _valorTotal = _servicosSelecionados.fold<double>(
      0.0,
          (total, servico) => total + (_valoresServicos[servico] ?? 0.0),
    );
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // _gerarPdfECompartilhar permanece igual...

  Widget _campoTexto(String label, TextEditingController controller, {TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orçamento')),
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
              _campoTexto('Cliente', _clienteController),
              SizedBox(height: 10),
              _campoTexto('Telefone', _telefoneController, tipo: TextInputType.phone),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Selecionar Serviço'),
                value: _servicoSelecionado,
                items: _servicos.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) {
                  setState(() {
                    _servicoSelecionado = value;
                    if (value != null) _adicionarServico(value);
                  });
                },
              ),
              SizedBox(height: 20),
              if (_servicosSelecionados.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Serviços Selecionados:", style: Theme.of(context).textTheme.titleLarge),
                    ..._servicosSelecionados.map((s) => ListTile(
                      title: Text(s),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _removerServico(s),
                      ),
                    )),
                  ],
                ),
              if (_valorTotal != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Valor Total: R\$ ${_valorTotal!.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                ),
              ElevatedButton(
                onPressed: _adicionarOuEditarOrcamento,
                child: Text(_orcamentoEditandoIndex == null ? "Salvar Orçamento" : "Salvar Alterações"),
              ),
              if (_orcamentoEditandoIndex != null)
                TextButton(
                  onPressed: _limparCampos,
                  child: Text("Cancelar Edição"),
                ),
              Divider(height: 32),
              Text("Orçamentos Salvos", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 10),
              if (_orcamentos.isEmpty)
                Text("Nenhum orçamento salvo."),
              ..._orcamentos.asMap().entries.map((entry) {
                final index = entry.key;
                final orcamento = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(orcamento['cliente']),
                    subtitle: Text(
                      'Telefone: ${orcamento['telefone']}\n'
                          'Serviços: ${orcamento['servicos'].join(", ")}\n'
                          'Total: R\$ ${orcamento['valorTotal'].toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _editarOrcamento(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _removerOrcamento(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _adicionarServico(String servico) {
    if (!_servicosSelecionados.contains(servico)) {
      setState(() {
        _servicosSelecionados.add(servico);
        _calcularTotal();
      });
    }
  }

  void _removerServico(String servico) {
    setState(() {
      _servicosSelecionados.remove(servico);
      _calcularTotal();
    });
  }

  Future<void> _gerarPdfECompartilhar() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Orçamento", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Text("Cliente: ${_clienteController.text}"),
            pw.Text("Telefone: ${_telefoneController.text}"),
            pw.SizedBox(height: 8),
            pw.Text("Serviços:"),
            ..._servicosSelecionados.map((s) => pw.Text("- $s (R\$ ${_valoresServicos[s]!.toStringAsFixed(2)})")),
            pw.SizedBox(height: 16),
            pw.Text("Valor Total: R\$ ${_valorTotal?.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/orcamento.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Segue o orçamento!');
  }
}

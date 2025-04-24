import 'package:flutter/material.dart';
import 'agenda.dart';

class TelaEditarAgendamento extends StatefulWidget {
  final Agenda agenda;

  const TelaEditarAgendamento({Key? key, required this.agenda}) : super(key: key);

  @override
  _TelaEditarAgendamentoState createState() => _TelaEditarAgendamentoState();
}

class _TelaEditarAgendamentoState extends State<TelaEditarAgendamento> {
  late TextEditingController _clienteController;
  late TextEditingController _telefoneController;
  late TextEditingController _horaController;

  final List<String> _servicos = ['Corte de cabelo', 'Manicure', 'Pedicure'];
  String? _servicoSelecionado;

  @override
  void initState() {
    super.initState();
    _clienteController = TextEditingController(text: widget.agenda.nomeCliente);
    _telefoneController = TextEditingController(text: widget.agenda.telefoneCliente);
    _horaController = TextEditingController(text: widget.agenda.hora);
    _servicoSelecionado = widget.agenda.nomeServico;
  }

  void _salvar() async {
    if (_clienteController.text.isEmpty ||
        _telefoneController.text.isEmpty ||
        _horaController.text.isEmpty ||
        _servicoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos corretamente!")),
      );
      return;
    }

    widget.agenda.nomeCliente = _clienteController.text;
    widget.agenda.telefoneCliente = _telefoneController.text;
    widget.agenda.hora = _horaController.text;
    widget.agenda.nomeServico = _servicoSelecionado!;

    final sucesso = await widget.agenda.salvarAgenda();

    if (sucesso) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar agendamento.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Agendamento")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _clienteController,
              decoration: InputDecoration(labelText: "Nome do Cliente"),
            ),
            TextField(
              controller: _telefoneController,
              decoration: InputDecoration(labelText: "Telefone"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _horaController,
              decoration: InputDecoration(labelText: "Hora (ex: 14:30)"),
              keyboardType: TextInputType.datetime,
            ),
            DropdownButtonFormField<String>(
              value: _servicoSelecionado,
              items: _servicos.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => _servicoSelecionado = value),
              decoration: InputDecoration(labelText: 'Serviço'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvar,
              child: Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}

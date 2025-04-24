import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'agenda.dart';
import 'tela_lista_agendamentos.dart';
import 'theme.dart'; // Para cores do tema

class TelaAgenda extends StatefulWidget {
  @override
  _TelaAgendaState createState() => _TelaAgendaState();
}

class _TelaAgendaState extends State<TelaAgenda> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay? _selectedTime;
  TextEditingController _clienteController = TextEditingController();
  TextEditingController _telefoneController = TextEditingController();
  TextEditingController _servicoController = TextEditingController();

  List<Agenda> _agendamentosDoDia = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _atualizarAgendamentosDoDia();
  }

  void _salvarAgendamento(String cliente, String servico, String telefone) {
    if (_selectedTime == null || cliente.isEmpty || servico.isEmpty || telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    Agenda agendamento = Agenda(
      data: _selectedDay,
      hora: _selectedTime!.format(context),
      nomeCliente: cliente,
      nomeServico: servico,
      telefoneCliente: telefone,
    );

    setState(() {
      if (_editingIndex == null) {
        _agendamentosDoDia.add(agendamento);
      } else {
        _agendamentosDoDia[_editingIndex!] = agendamento;
      }
      _editingIndex = null;
      _clienteController.clear();
      _telefoneController.clear();
      _servicoController.clear();
      _selectedTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendamento salvo com sucesso!')),
    );

    _atualizarAgendamentosDoDia();
  }

  void _editarAgendamento(int index) {
    setState(() {
      _selectedDay = _agendamentosDoDia[index].data;
      final partes = _agendamentosDoDia[index].hora.split(":");
      _selectedTime = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
      _clienteController.text = _agendamentosDoDia[index].nomeCliente;
      _telefoneController.text = _agendamentosDoDia[index].telefoneCliente;
      _servicoController.text = _agendamentosDoDia[index].nomeServico;
      _editingIndex = index;
    });
  }

  void _excluirAgendamento(int index) {
    setState(() {
      _agendamentosDoDia.removeAt(index);
    });
    _atualizarAgendamentosDoDia();
  }

  void _atualizarAgendamentosDoDia() {
    setState(() {
      _agendamentosDoDia = _agendamentosDoDia
          .where((a) => isSameDay(a.data, _selectedDay))
          .toList();
    });
  }

  Future<void> _selecionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  String _formatarHora(String hora) {
    return hora;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
      ),
      body: Container(
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
              _campoTexto('Serviço', _servicoController),
              SizedBox(height: 10),
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _atualizarAgendamentosDoDia();
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selecionarHora,
                child: Text(_selectedTime == null
                    ? 'Selecionar Hora'
                    : 'Hora: ${_selectedTime!.format(context)}'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _salvarAgendamento(
                    _clienteController.text,
                    _servicoController.text,
                    _telefoneController.text,
                  );
                },
                child: Text('Salvar Agendamento'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaListaAgendamentos(),
                    ),
                  );
                },
                child: Text('Ver Todos os Agendamentos'),
              ),
              SizedBox(height: 20),
              if (_agendamentosDoDia.isEmpty)
                Text("Nenhum agendamento para o dia selecionado."),
              ..._agendamentosDoDia.map((a) => Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(a.nomeCliente),
                  subtitle: Text(
                      '${a.nomeServico}\n${_formatarData(a.data)} - ${_formatarHora(a.hora)}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: AppTheme.azulClaro),
                        onPressed: () => _editarAgendamento(_agendamentosDoDia.indexOf(a)),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _excluirAgendamento(_agendamentosDoDia.indexOf(a)),
                      ),
                    ],
                  ),
                ),
              )),
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

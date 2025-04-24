import 'package:flutter/material.dart';
import 'agenda.dart';
import 'tela_editar_agendamento.dart';

class Agendamentos extends StatefulWidget {
  @override
  _AgendamentosState createState() => _AgendamentosState();
}

class _AgendamentosState extends State<Agendamentos> {
  List<Agenda> _agendamentos = [];

  void _navegarParaEdicao({Agenda? agenda, int? index}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaEditarAgendamento(
          agenda: agenda ??
              Agenda(
                data: DateTime.now(),
                hora: '',
                nomeCliente: '',
                nomeServico: '',
                telefoneCliente: '',
              ),
        ),
      ),
    );

    if (resultado == true) {
      setState(() {}); // você pode atualizar da API aqui também se quiser
    }
  }

  void _removerAgendamento(int index) {
    setState(() {
      _agendamentos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agendamentos")),
      body: _agendamentos.isEmpty
          ? Center(child: Text("Nenhum agendamento salvo."))
          : ListView.builder(
        itemCount: _agendamentos.length,
        itemBuilder: (_, index) {
          final ag = _agendamentos[index];
          return Card(
            child: ListTile(
              title: Text(ag.nomeCliente),
              subtitle: Text(
                'Serviço: ${ag.nomeServico}\n'
                    'Telefone: ${ag.telefoneCliente}\n'
                    'Data: ${ag.data.toLocal().toString().split(" ")[0]} - ${ag.hora}',
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navegarParaEdicao(
                      agenda: ag,
                      index: index,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removerAgendamento(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navegarParaEdicao(),
      ),
    );
  }
}

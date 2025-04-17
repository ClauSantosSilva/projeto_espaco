import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'agenda.dart';
import 'tela_editar_agendamento.dart';

class TelaListaAgendamentos extends StatefulWidget {
  @override
  _TelaListaAgendamentosState createState() => _TelaListaAgendamentosState();
}

class _TelaListaAgendamentosState extends State<TelaListaAgendamentos> {
  List<Agenda> _agendamentos = [];
  bool _carregando = true;
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    _buscarAgendamentos();
  }

  Future<void> _buscarAgendamentos() async {
    setState(() {
      _carregando = true;
    });

    List<Agenda> lista = await Agenda.listarAgendas();
    setState(() {
      _agendamentos = lista;
      _carregando = false;
      _dataSelecionada = null;
    });
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  Future<void> _filtrarPorData() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataSelecionada = dataEscolhida;
        _carregando = true;
      });

      final lista = await Agenda.buscarPorData(dataEscolhida);
      setState(() {
        _agendamentos = lista;
        _carregando = false;
      });
    }
  }

  Future<void> _filtrarPorIntervalo() async {
    final DateTime? inicio = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      helpText: "Selecionar Data Inicial",
    );

    if (inicio == null) return;

    final DateTime? fim = await showDatePicker(
      context: context,
      initialDate: inicio,
      firstDate: inicio,
      lastDate: DateTime(2030),
      helpText: "Selecionar Data Final",
    );

    if (fim == null) return;

    setState(() {
      _carregando = true;
    });

    List<Agenda> todas = await Agenda.listarAgendas();
    List<Agenda> filtradas = todas.where((a) =>
    a.data.isAfter(inicio.subtract(Duration(days: 1))) &&
        a.data.isBefore(fim.add(Duration(days: 1)))).toList();

    setState(() {
      _agendamentos = filtradas;
      _dataSelecionada = null;
      _carregando = false;
    });
  }

  Future<void> _exportarPdf() async {
    final pdf = pw.Document();
    final dataTexto = _dataSelecionada != null
        ? _formatarData(_dataSelecionada!)
        : 'Todos os Agendamentos';

    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    _agendamentos.sort((a, b) {
      final horaA = int.tryParse(a.hora.replaceAll(":", "")) ?? 0;
      final horaB = int.tryParse(b.hora.replaceAll(":", "")) ?? 0;
      return horaA.compareTo(horaB);
    });

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Image(logo, height: 80),
          pw.SizedBox(height: 12),
          pw.Text('Relatório de Agendamentos - $dataTexto',
              style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Cliente', 'Serviço', 'Data', 'Hora', 'Telefone'],
            data: _agendamentos.map((a) {
              return [
                a.nomeCliente,
                a.nomeServico,
                _formatarData(a.data),
                a.hora,
                a.telefoneCliente,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final filePath = "${output.path}/relatorio_agendamentos.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'relatorio_agendamentos.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _dataSelecionada != null
        ? 'Agendamentos'
        : 'Todos os Agendamentos';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(titulo, style: TextStyle(fontSize: 18)),
            if (_dataSelecionada != null)
              Text(
                _formatarData(_dataSelecionada!),
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'unica') _filtrarPorData();
              if (value == 'intervalo') _filtrarPorIntervalo();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'unica', child: Text('Data única')),
              PopupMenuItem(value: 'intervalo', child: Text('Intervalo de datas')),
            ],
            icon: Icon(Icons.calendar_month),
          ),
          if (_dataSelecionada != null)
            IconButton(
              icon: Icon(Icons.clear),
              tooltip: "Limpar filtro",
              onPressed: _buscarAgendamentos,
            ),
          if (_agendamentos.isNotEmpty)
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              tooltip: "Exportar/Compartilhar PDF",
              onPressed: _exportarPdf,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _carregando
            ? Center(child: CircularProgressIndicator())
            : _agendamentos.isEmpty
            ? Center(child: Text('Nenhum agendamento encontrado.'))
            : ListView.builder(
          itemCount: _agendamentos.length,
          itemBuilder: (context, index) {
            final a = _agendamentos[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('${a.nomeCliente} - ${a.nomeServico}'),
                subtitle: Text(
                  'Data: ${_formatarData(a.data)} | Hora: ${a.hora}\nTelefone: ${a.telefoneCliente}',
                ),
                onTap: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TelaEditarAgendamento(agenda: a),
                    ),
                  );
                  if (resultado == true) {
                    _buscarAgendamentos();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

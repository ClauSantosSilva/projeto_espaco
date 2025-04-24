import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TelaRelatorio extends StatefulWidget {
  @override
  _TelaRelatorioState createState() => _TelaRelatorioState();
}

class _TelaRelatorioState extends State<TelaRelatorio> {
  final TextEditingController _numeroController = TextEditingController();
  final List<Map<String, dynamic>> _dadosRelatorio = [
    {'cliente': 'Ana', 'servico': 'Corte de cabelo', 'valor': 30.0, 'data': '14/04/2025'},
    {'cliente': 'Bruno', 'servico': 'Manicure', 'valor': 20.0, 'data': '14/04/2025'},
    {'cliente': 'Carla', 'servico': 'Pedicure', 'valor': 25.0, 'data': '13/04/2025'},
  ];

  Future<void> _gerarECompartilharPDF() async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final DateTime agora = DateTime.now();
    final String dataFormatada = DateFormat('dd/MM/yyyy').format(agora);

    double total = 0;
    _dadosRelatorio.forEach((dado) => total += dado['valor']);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Relatório de Serviços - $dataFormatada',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Cliente', 'Serviço', 'Valor', 'Data'],
                data: _dadosRelatorio
                    .map((dado) => [
                  dado['cliente'],
                  dado['servico'],
                  formatter.format(dado['valor']),
                  dado['data'],
                ])
                    .toList(),
              ),
              pw.SizedBox(height: 15),
              pw.Text('Total: ${formatter.format(total)}',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/relatorio.pdf");
    await file.writeAsBytes(await pdf.save());

    final numero = _numeroController.text.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse("https://wa.me/55$numero?text=Ol%C3%A1%2C%20segue%20o%20relat%C3%B3rio%20em%20PDF.");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await Printing.sharePdf(bytes: await file.readAsBytes(), filename: 'relatorio.pdf');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível abrir o WhatsApp.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relatório')),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _numeroController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Número WhatsApp (com DDD)',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _gerarECompartilharPDF,
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Gerar PDF e Enviar'),
                ),
                SizedBox(height: 30),
                Text('Relatório Visual', style: Theme.of(context).textTheme.titleLarge),
                ..._dadosRelatorio.map((dado) => ListTile(
                  title: Text('${dado['cliente']} - ${dado['servico']}'),
                  subtitle: Text('Data: ${dado['data']}'),
                  trailing: Text('R\$ ${dado['valor'].toStringAsFixed(2)}'),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

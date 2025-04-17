import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_espaco/tela_cliente.dart';
import 'package:projeto_espaco/tela_servico.dart';
import 'package:projeto_espaco/tela_orcamento.dart';
import 'package:projeto_espaco/tela_agenda.dart';
import 'package:projeto_espaco/tela_relatorio.dart';
import 'package:projeto_espaco/tela_lista_agendamentos.dart';
import 'theme.dart';

class TelaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Espaço Beleza',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.lightBlue[100]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                // Imagem elegante e centralizada
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/image2.png', // <- Salve como assets/images/loto.png
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 30),
                _buildButton(context, 'Clientes', TelaCliente()),
                SizedBox(height: 12),
                _buildButton(context, 'Serviços', ServicosScreen()),
                SizedBox(height: 12),
                _buildButton(context, 'Orçamento', TelaOrcamento()),
                SizedBox(height: 12),
                _buildButton(context, 'Agenda', TelaAgenda()),
                SizedBox(height: 12),
                _buildButton(context, 'Relatórios', TelaRelatorio()),
                SizedBox(height: 12),
                _buildButton(context, 'Lista de Agendamentos', TelaListaAgendamentos()),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () => _sair(context),
              icon: Icon(Icons.logout),
              label: Text("Sair"),
              backgroundColor: AppTheme.azulClaro,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget destination) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Text(text),
    );
  }

  void _sair(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sair do aplicativo"),
          content: Text("Tem certeza que deseja sair?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Não"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              child: Text("Sim"),
            ),
          ],
        );
      },
    );
  }
}

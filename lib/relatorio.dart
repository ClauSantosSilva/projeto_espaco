import 'agenda.dart';

class Relatorio {
  final List<Agenda> agendamentos;

  Relatorio(this.agendamentos);

  // Simula valor de cada serviço
  double _valorDoServico(String servico) {
    switch (servico.toLowerCase()) {
      case 'corte de cabelo':
        return 30.0;
      case 'manicure':
        return 20.0;
      case 'pedicure':
        return 25.0;
      default:
        return 0.0;
    }
  }

  // Lista de agendamentos filtrados por período e opcionalmente por serviço
  List<Agenda> filtrarPorPeriodoEServico({
    required DateTime inicio,
    required DateTime fim,
    String? servico, // null = todos os serviços
  }) {
    return agendamentos.where((a) {
      final dentroDoPeriodo = a.data.isAfter(inicio.subtract(Duration(days: 1))) &&
          a.data.isBefore(fim.add(Duration(days: 1)));
      final correspondeServico = servico == null || servico == 'Todos' || a.nomeServico == servico;
      return dentroDoPeriodo && correspondeServico;
    }).toList();
  }

  // Total arrecadado no período (geral ou por serviço)
  double calcularTotalNoPeriodo({
    required DateTime inicio,
    required DateTime fim,
    String? servico, // null ou "Todos" para geral
  }) {
    final filtrados = filtrarPorPeriodoEServico(
      inicio: inicio,
      fim: fim,
      servico: servico,
    );

    double total = 0;
    for (var a in filtrados) {
      total += _valorDoServico(a.nomeServico);
    }
    return total;
  }

  // Detalhamento por serviço (usado para relatórios mais completos)
  Map<String, double> gerarResumoPorServico({
    required DateTime inicio,
    required DateTime fim,
  }) {
    final filtrados = filtrarPorPeriodoEServico(inicio: inicio, fim: fim);
    Map<String, double> resumo = {};

    for (var a in filtrados) {
      final servico = a.nomeServico;
      final valor = _valorDoServico(servico);
      resumo[servico] = (resumo[servico] ?? 0.0) + valor;
    }

    return resumo;
  }
}

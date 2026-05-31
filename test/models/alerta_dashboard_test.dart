import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/models/alerta_dashboard.dart';

void main() {
  test('AlertaDashboardResposta calcula total pendentes', () {
    final resposta = AlertaDashboardResposta.fromJson({
      'alertas': [
        {
          'id': 1,
          'veiculo_id': 10,
          'veiculo_rotulo': 'Moto (ABC1D23)',
          'titulo': 'Trocar óleo',
          'tipo': 'km',
          'valor_alerta': 100,
          'status': 'vencido',
          'km_restante': -50,
        },
      ],
      'total_vencidos': 1,
      'total_proximos': 2,
    });

    expect(resposta.totalPendentes, 3);
    expect(resposta.alertas.first.chaveNotificacao, '1:vencido');
    expect(resposta.alertas.first.rotuloRestante, contains('além'));
  });
}

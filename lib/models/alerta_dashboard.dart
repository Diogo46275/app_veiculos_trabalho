class AlertaDashboardItem {
  const AlertaDashboardItem({
    required this.id,
    required this.veiculoId,
    required this.veiculoRotulo,
    required this.titulo,
    required this.tipo,
    required this.valorAlerta,
    required this.status,
    this.kmLimite,
    this.dataLimite,
    this.kmRestante,
    this.diasRestantes,
  });

  final int id;
  final int veiculoId;
  final String veiculoRotulo;
  final String titulo;
  final String tipo;
  final int valorAlerta;
  final String status;
  final int? kmLimite;
  final String? dataLimite;
  final int? kmRestante;
  final int? diasRestantes;

  String get chaveNotificacao => '$id:$status';

  factory AlertaDashboardItem.fromJson(Map<String, dynamic> json) {
    return AlertaDashboardItem(
      id: json['id'] as int,
      veiculoId: json['veiculo_id'] as int,
      veiculoRotulo: json['veiculo_rotulo'] as String? ?? 'Veículo',
      titulo: json['titulo'] as String? ?? 'Alerta',
      tipo: json['tipo'] as String? ?? 'km',
      valorAlerta: json['valor_alerta'] as int? ?? 0,
      status: json['status'] as String? ?? 'ok',
      kmLimite: json['km_limite'] as int?,
      dataLimite: json['data_limite'] as String?,
      kmRestante: json['km_restante'] as int?,
      diasRestantes: json['dias_restantes'] as int?,
    );
  }

  String get rotuloRestante {
    if (status == 'vencido') {
      if (tipo == 'km' && kmRestante != null && kmRestante! < 0) {
        final kmAlem = -kmRestante!;
        return '${_formatKm(kmAlem)} além do limite';
      }
      if (tipo == 'data' && diasRestantes != null && diasRestantes! < 0) {
        return '${-diasRestantes!} dia(s) além do prazo';
      }
      return 'Prazo ou km ultrapassado';
    }
    if (tipo == 'km' && kmRestante != null) {
      return 'Faltam ${_formatKm(kmRestante!)}';
    }
    if (tipo == 'data' && diasRestantes != null) {
      return 'Faltam ${diasRestantes!} dia(s)';
    }
    return 'Verifique o alerta';
  }

  String get rotuloStatus {
    switch (status) {
      case 'vencido':
        return 'Vencido';
      case 'proximo':
        return 'Próximo';
      default:
        return status;
    }
  }

  static String _formatKm(int km) {
    return '${km.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )} km';
  }
}

class AlertaDashboardResposta {
  const AlertaDashboardResposta({
    required this.alertas,
    required this.totalVencidos,
    required this.totalProximos,
  });

  final List<AlertaDashboardItem> alertas;
  final int totalVencidos;
  final int totalProximos;

  int get totalPendentes => totalVencidos + totalProximos;

  factory AlertaDashboardResposta.fromJson(Map<String, dynamic> json) {
    final lista = json['alertas'];
    return AlertaDashboardResposta(
      alertas: lista is List
          ? lista
              .whereType<Map<String, dynamic>>()
              .map(AlertaDashboardItem.fromJson)
              .toList()
          : const [],
      totalVencidos: json['total_vencidos'] as int? ?? 0,
      totalProximos: json['total_proximos'] as int? ?? 0,
    );
  }

  factory AlertaDashboardResposta.vazio() {
    return const AlertaDashboardResposta(
      alertas: [],
      totalVencidos: 0,
      totalProximos: 0,
    );
  }
}

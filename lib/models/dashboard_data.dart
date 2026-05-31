class DashboardData {
  const DashboardData({
    required this.kmTotal,
    required this.economia,
    required this.proximasManutencoes,
  });

  final int kmTotal;
  final double economia;
  final int proximasManutencoes;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      kmTotal: _readInt(json, ['km_total', 'km_rodado', 'kmTotal']),
      economia: _readDouble(json, [
        'economia_total',
        'economia',
        'lucro',
      ]),
      proximasManutencoes: _readInt(json, [
        'proximas_manutencoes',
        'total_proximos',
        'manutencoes_proximas',
      ]),
    );
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
    }
    return 0;
  }
}

/// Serialização de datas para a API FastAPI (ISO local, sem fuso).
abstract final class IsoDatetime {
  static String data(DateTime valor) {
    return '${_dois(valor.year)}-${_dois(valor.month)}-${_dois(valor.day)}';
  }

  static String dataHora(DateTime valor) {
    return '${data(valor)}T${_dois(valor.hour)}:${_dois(valor.minute)}:00';
  }

  static String _dois(int n) => n.toString().padLeft(2, '0');
}

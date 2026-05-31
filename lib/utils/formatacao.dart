abstract final class Formatacao {
  static String data(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final dataIso = iso.split('T').first;
    final partes = dataIso.split('-');
    if (partes.length >= 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }
    final parsed = DateTime.tryParse(iso);
    if (parsed != null) {
      final local = parsed.toLocal();
      return '${_dois(local.day)}/${_dois(local.month)}/${local.year}';
    }
    return iso;
  }

  static String dataHora(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final parsed = DateTime.tryParse(iso);
    if (parsed != null) {
      final local = parsed.toLocal();
      return '${_dois(local.day)}/${_dois(local.month)}/${local.year} '
          '${_dois(local.hour)}:${_dois(local.minute)}';
    }
    return iso;
  }

  static String moeda(num? valor) {
    if (valor == null) return '—';
    final texto = valor.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $texto';
  }

  static String km(int? valor) {
    if (valor == null) return '—';
    return '${_milhar(valor)} km';
  }

  static String decimal(num? valor, {int casas = 2}) {
    if (valor == null) return '—';
    return valor.toStringAsFixed(casas).replaceAll('.', ',');
  }

  static String _dois(int valor) => valor.toString().padLeft(2, '0');

  static String _milhar(int valor) {
    final texto = valor.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < texto.length; i++) {
      final restante = texto.length - i;
      if (i > 0 && restante % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(texto[i]);
    }
    return buffer.toString();
  }
}

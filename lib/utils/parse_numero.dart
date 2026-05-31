abstract final class ParseNumero {
  static double? decimal(String texto) {
    final limpo = texto.trim().replaceAll(',', '.');
    if (limpo.isEmpty) return null;
    return double.tryParse(limpo);
  }

  static int? inteiro(String texto) {
    final limpo = texto.trim();
    if (limpo.isEmpty) return null;
    return int.tryParse(limpo);
  }
}

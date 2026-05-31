abstract final class AnexoUrl {
  static const _baseSite = 'https://bytes-techus.com.br/veiculos';

  /// Converte caminho relativo ou URL parcial da API em link absoluto.
  static String? absoluta(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$_baseSite$url';
    return '$_baseSite/anexos/$url';
  }
}

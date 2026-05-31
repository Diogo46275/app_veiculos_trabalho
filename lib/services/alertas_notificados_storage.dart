import 'package:shared_preferences/shared_preferences.dart';

/// Evita repetir a mesma notificação para o mesmo alerta + status.
abstract final class AlertasNotificadosStorage {
  static const _chavePrefs = 'alertas_notificados_chaves';

  static Future<Set<String>> lerChaves() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_chavePrefs) ?? []).toSet();
  }

  static Future<void> salvarChaves(Set<String> chaves) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chavePrefs, chaves.toList());
  }

  static Future<void> limparChavesDoAlerta(int alertaId) async {
    final chaves = await lerChaves();
    chaves.removeWhere((chave) => chave.startsWith('$alertaId:'));
    await salvarChaves(chaves);
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chavePrefs);
  }
}

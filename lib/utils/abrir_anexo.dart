import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'anexo_url.dart';

Future<bool> abrirAnexoExterno(String? url) async {
  final absoluta = AnexoUrl.absoluta(url);
  if (absoluta == null) return false;

  final uri = Uri.parse(absoluta);
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> abrirAnexoComFeedback(BuildContext context, String? url) async {
  final abriu = await abrirAnexoExterno(url);
  if (!context.mounted || abriu) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Não foi possível abrir o anexo. Tente novamente.'),
    ),
  );
}

import 'package:flutter/material.dart';

import 'seletor_data_br.dart';

const _localeBr = Locale('pt', 'BR');

/// Seletor de data e hora em português (Brasil).
Future<DateTime?> selecionarDataHoraBr(
  BuildContext context, {
  required DateTime dataInicial,
  required DateTime primeiraData,
  required DateTime ultimaData,
}) async {
  final data = await selecionarDataBr(
    context,
    dataInicial: dataInicial,
    primeiraData: primeiraData,
    ultimaData: ultimaData,
  );
  if (data == null || !context.mounted) return null;

  final horaInicial = TimeOfDay.fromDateTime(dataInicial);
  final hora = await showTimePicker(
    context: context,
    initialTime: horaInicial,
    helpText: 'Selecione a hora',
    cancelText: 'Cancelar',
    confirmText: 'OK',
    builder: (context, child) {
      return Localizations.override(
        context: context,
        locale: _localeBr,
        child: child,
      );
    },
  );
  if (hora == null) return null;

  return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
}

import 'package:flutter/material.dart';

const _localeBr = Locale('pt', 'BR');

/// Date picker com textos e calendário em português (Brasil).
Future<DateTime?> selecionarDataBr(
  BuildContext context, {
  required DateTime dataInicial,
  required DateTime primeiraData,
  required DateTime ultimaData,
}) {
  return showDatePicker(
    context: context,
    locale: _localeBr,
    initialDate: dataInicial,
    firstDate: primeiraData,
    lastDate: ultimaData,
    helpText: 'Selecione a data',
    cancelText: 'Cancelar',
    confirmText: 'OK',
  );
}

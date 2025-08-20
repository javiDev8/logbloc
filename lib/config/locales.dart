import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

mixin Tr {
  static const String settings = 'settings';
  static const String preferences = 'preferences';
  static const String account = 'account';
  static const String logout = 'logout';
  static const String theme = 'theme';
  static const String dark = 'dark';
  static const String light = 'light';
  static const String system = 'system';
  static const String language = 'language';
  static const String tutorial = 'tutorial';
  static const String reportBug = 'report-bug';
  static const String version = 'version';
  static const String help = 'help';
  static const String model = 'model';
  static const String models = 'models';
  static const String noModels = 'no-models';
  static const String newModel = 'new-model';
  static const String newModelNameHint = 'new-model-name-hint';
  static const String save = 'save';
  static const String agenda = 'agenda';
  static const String analysis = 'analysis';
  static const String ftNumberLabel = 'ft-number-label';

  static const Map<String, dynamic> en = {
    model: 'logbook',
    models: 'logbooks',
    noModels: 'no models to show',
    newModel: 'new model',
    newModelNameHint: 'model name',
    save: 'save',
    agenda: 'agenda',
    analysis: 'analysis',
    settings: 'settings',
    account: 'account',
    logout: 'logout',
    theme: 'theme',
    dark: 'dark',
    system: 'system',
    light: 'light',
    language: 'language',
    tutorial: 'tutorial',
    reportBug: 'report bug',
    version: 'version',
    help: 'help',
    preferences: 'preferences',
    ftNumberLabel: 'measure',
  };

  static const Map<String, dynamic> es = {
    model: 'bitácora',
    models: 'bitácoras',
    noModels: 'no hay ningún modelo',
    newModel: 'nuevo modelo',
    newModelNameHint: 'nombre del modelo',
    save: 'guardar',
    agenda: 'agenda',
    analysis: 'análisis',
    settings: 'configuración',
    account: 'cuenta',
    logout: 'salir',
    theme: 'tema',
    dark: 'oscuro',
    system: 'sistema',
    light: 'claro',
    language: 'idioma',
    tutorial: 'tutorial',
    reportBug: 'reportar error',
    version: 'versión',
    help: 'ayuda',
    preferences: 'preferencias',
    ftNumberLabel: 'medida',
  };
}

class TrText extends StatelessWidget {
  final String string;
  const TrText(this.string, {super.key});

  @override
  Widget build(BuildContext context) => Text(string.getString(context));
}

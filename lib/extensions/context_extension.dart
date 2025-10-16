// lib/extensions/context_extensions.dart
import 'package:flutter/widgets.dart';
import 'package:veggie_cart/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

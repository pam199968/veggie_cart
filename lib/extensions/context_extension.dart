// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

// lib/extensions/context_extensions.dart
import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

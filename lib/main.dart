// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'firebase_options_test.dart';
import 'firebase_options_prod.dart';
import 'dependencies.dart';

enum Environment { test, prod }

const _envString = String.fromEnvironment('ENV', defaultValue: 'test');

Environment get currentEnvironment {
  switch (_envString) {
    case 'prod':
      return Environment.prod;
    case 'test':
    default:
      return Environment.test;
  }
}

void assertEnvironment() {
  assert(() {
    debugPrint('🔥 Firebase ENV = $_envString');
    return true;
  }());
}

Future<void> main() async {
  assertEnvironment();
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();

  final firebaseOptions = currentEnvironment == Environment.prod
      ? DefaultFirebaseOptionsProd.currentPlatform
      : DefaultFirebaseOptionsTest.currentPlatform;

  await Firebase.initializeApp(options: firebaseOptions);

  runWithDependencies();
}

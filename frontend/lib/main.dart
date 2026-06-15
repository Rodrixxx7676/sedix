import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/utils/iosevka_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadIosevkaCharonFont();
  runApp(const ProviderScope(child: SedixApp()));
}

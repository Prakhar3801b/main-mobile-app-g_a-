import 'package:flutter/material.dart';

import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  await AppBootstrap.initialize();
  runApp(const SamadhanApp());
}

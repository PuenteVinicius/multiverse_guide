import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/utils/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  runApp(const App());
}

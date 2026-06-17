import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/di/app_bindings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBindings.init();
  runApp(const AquacareApp());
}

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const NewsFeedApp());
}

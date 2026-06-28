import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'firebase_options.dart';
import 'utils/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize service locator (register services & blocs)
  setupServiceLocator();

  // Create the router after Firebase is initialized
  final router = AppRouter.createRouter();

  runApp(NiramayClinicApp(router: router));
}

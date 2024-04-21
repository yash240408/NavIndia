import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'features/authentication/screens/network/dependency_injection.dart';
import 'firebase_options.dart';

import '../app.dart';

void main()async {
  runApp(const App());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   await GetStorage.init();
     await DependencyInjection().init();

}


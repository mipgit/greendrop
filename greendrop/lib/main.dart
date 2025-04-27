import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/firebase_options.dart';
import 'package:greendrop/services/authentication_service.dart';
import 'package:greendrop/services/group_service.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/login/login_view.dart';
import 'package:greendrop/view/navbar/navigation_view.dart';
import 'package:provider/provider.dart';

import 'package:greendrop/view-model/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationService()),
        ChangeNotifierProvider(create: (context) => GardenProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider(context)),
        ChangeNotifierProvider<GroupService>( 
          create: (_) => GroupService(),
        ),
      ],
      child: const GreenDropApp(),
    ),
  );
}

class GreenDropApp extends StatelessWidget {
  const GreenDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenDrop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen.shade600,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            print('${snapshot.data?.uid}');
            return NavigationView();
          } else {
            return const LoginView();
          }
        },
      ),
    );
  }
}
import 'package:bestmlawi/pages/admin_profile_page.dart';
import 'package:bestmlawi/pages/bienvenu.page1.dart';
import 'package:bestmlawi/pages/connexion.page.dart';
import 'package:bestmlawi/pages/gestion_commandes_page.dart';
import 'package:bestmlawi/pages/page_acceuil.dart';
import 'package:bestmlawi/pages/commandes_page.dart';
import 'package:bestmlawi/pages/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'config/translation_config.dart';
import 'firebase_options.dart';

void main() async {
  print('=== APP STARTING ===');
  WidgetsFlutterBinding.ensureInitialized();
  print('=== INITIALIZING FIREBASE ===');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await TranslationConfig.init();

    print('=== FIREBASE AND TRANSLATION INITIALIZED SUCCESSFULLY ===');
  } catch (e) {
    print('=== FIREBASE ERROR: $e ===');
  }

  print('=== RUNNING APP ===');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== BUILDING MyApp ===');
    return MaterialApp(
      title: 'BestMlawi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: GestionCommandesPage(),
      routes: {
        '/home': (context) => PageAcceuil(),
        '/commandes': (context) => CommandesPage(),
        '/profile': (context) => ProfilePage(),
        '/login': (context) => ConnexionPage(),
        '/admin_profile': (context) => const AdminProfilePage(),
        '/gestion_commandes': (context) => const GestionCommandesPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Page non trouvée: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}
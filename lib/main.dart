import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Charger les variables d'environnement
  await dotenv.load(fileName: "assets/.env");

  // 🔹 Initialiser Firebase en évitant le crash si l'app est déjà initialisée
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("🔥 Firebase est déjà initialisé : $e");
  }

  runApp(const Echo24App());
}

class Echo24App extends StatelessWidget {
  const Echo24App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo24 - Réseau Social',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),
        "/complete-profile": (context) => const CompleteProfileScreen(),
      },
    );
  }
}

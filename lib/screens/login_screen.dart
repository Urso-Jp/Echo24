import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'complete_profile_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false; // Pour l'animation de chargement

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 🔹 Rediriger vers HomeScreen après connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connexion réussie ! ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 🔹 Ajouter l'utilisateur dans Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": _emailController.text.trim(),
        "createdAt": Timestamp.now(),
      });

      // 🔹 Rediriger vers la page de création de profil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscription réussie ! Complétez votre profil.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer votre email pour réinitialiser le mot de passe.")),
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Un email de réinitialisation a été envoyé.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Dégradé de couleurs
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔹 Logo
                  const Icon(Icons.chat_bubble, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "Bienvenue sur Echo24",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  // 🔹 Champ Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  // 🔹 Champ Mot de passe
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Bouton Mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Bouton Se connecter
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Se connecter", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 15),

                  // 🔹 Bouton Créer un compte
                  TextButton(
                    onPressed: _isLoading ? null : _register,
                    child: const Text(
                      "Créer un compte",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

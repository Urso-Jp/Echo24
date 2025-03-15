import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';

final List<String> motsInterdits = [
  "con", "connard", "connasse", "idiot", "imbécile", "abruti", "débile",
  "crétin", "stupide", "merde", "putain", "salope", "enculé", "bâtard",
  "bordel", "cul", "niquer", "nique", "foutre", "salaud", "salaope",
  "pd", "pédé", "tapette", "enculer", "chier", "trouduc", "ta gueule",
  "ferme ta gueule", "fdp", "fils de pute", "pute", "prostituée", "branleur",
  "branleuse", "raciste", "xénophobe", "nazisme", "hitler", "facho",
  "fachiste", "dictateur", "tueur", "meurtrier", "terroriste", "viol",
  "violeur", "pédophile", "esclavage", "sanglant", "assassin", "drogue",
  "cocaïne", "héroïne", "crack", "meth", "methamphetamine", "alcoolique",
  "junkie", "overdose", "suicide", "se pendre", "se tuer", "armes",
  "fusillade", "kalash", "explosif", "bombe", "djihad", "djihadiste",
  "daesh", "isis", "taliban", "dictature", "homophobie", "islamophobie",
  "antisémitisme", "haine", "génocide", "extermination", "massacre",
  "torture", "barbare", "barbarie", "inhumain", "nazisme", "kamikaze",
  "violence conjugale", "féminicide", "misogynie", "inceste", "agression",
  "kidnapping", "tueur en série", "charia", "esclave", "prostitution",
  "trafic humain", "corruption", "mafia", "cartel", "gang", "démoniaque",
  "satan", "lucifer", "666", "malédiction", "vaudou", "exorcisme", "enfer",
  "culte", "secte", "désinformation", "fake news", "manipulation",
  "tromperie", "pirate", "hacker", "cyberattaque", "escroc", "arnaque",
  "fraude", "corruption", "blanchiment", "détournement", "crime",
  "assassinat", "vol", "cambriolage", "extorsion", "chantage", "braquage",
  "menace", "harcèlement", "harceleur", "persécution", "insulte",
  "humiliation", "diffamation", "délation", "mensonge", "hypocrisie",
  "trahison", "trahir", "dénoncer", "abus", "pervers", "manipulateur",
  "narcissique", "toxicité", "toxique", "faux ami", "abus de pouvoir",
  "domination", "soumission", "exploitation", "injustice", "cruel",
  "cruauté", "oppression", "dictateur", "censure", "répression",
  "tyrannie", "despotisme", "autocrate", "manipulateur", "menteur",
  "hypocrite", "ingrat", "méprisant", "arrogant", "snob", "narcissique",
  "sadique", "psychopathe", "sociopathe", "pervers", "malsain",
  "dérangé", "instable", "dangereux", "déséquilibré", "paranoïaque",
  "fanatique", "extrémiste", "fasciste", "suprémaciste", "négationniste"
];

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _passionsController = TextEditingController();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false; // Animation de chargement

  bool contientMotsInterdits(String text) {
    for (var mot in motsInterdits) {
      if (text.toLowerCase().contains(mot)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime minAgeDate = DateTime(today.year - 13, today.month, today.day);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: minAgeDate,
      firstDate: DateTime(1900),
      lastDate: minAgeDate,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String uid = _auth.currentUser!.uid;
        String username = _usernameController.text.trim();
        String description = _descriptionController.text.trim();
        String passions = _passionsController.text.trim();

        if (contientMotsInterdits(username) || contientMotsInterdits(description)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Un champ contient un mot interdit ❌")),
          );
          setState(() => _isLoading = false);
          return;
        }

        await _firestore.collection("users").doc(uid).update({
          "username": username,
          "birthdate": _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
          "gender": _selectedGender,
          "description": description.isEmpty ? null : description,
          "passions": passions.isEmpty ? null : passions,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil complété avec succès ! ✅")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.toString()}")),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
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
                  const Icon(Icons.person_add, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "Complétez votre profil",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_usernameController, "Pseudo *", Icons.person, true),
                        const SizedBox(height: 15),

                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: _buildInputDecoration("Date de naissance *", Icons.cake),
                            child: Text(
                              _selectedDate == null
                                  ? "Sélectionnez votre date de naissance"
                                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration("Genre *", Icons.wc),
                          dropdownColor: Colors.grey[800],
                          value: _selectedGender,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                          items: ["Homme", "Femme", "Non spécifié"]
                              .map((value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value, style: const TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          validator: (value) => value == null ? "Sélectionnez votre genre" : null,
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(_descriptionController, "Description (facultatif)", Icons.edit, false),
                        const SizedBox(height: 15),

                        _buildTextField(_passionsController, "Passions (facultatif)", Icons.favorite, false),
                        const SizedBox(height: 30),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.blue)
                              : const Text(
                                  "Valider",
                                  style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
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

  TextFormField _buildTextField(TextEditingController controller, String label, IconData icon, bool isRequired) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, icon),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (isRequired && value!.isEmpty) return "Ce champ est obligatoire";
        if (value != null && value.length > 50) return "Maximum 50 caractères";
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}
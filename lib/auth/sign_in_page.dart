import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pseudoController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _errorMessage = '';

  /// Méthode pour vérifier si le pseudo est déjà utilisé
  Future<bool> _isPseudoAvailable(String pseudo) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('pseudo', isEqualTo: pseudo)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  /// Méthode pour créer un compte avec Firestore pour stocker le pseudo
  Future<void> _createAccount() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String pseudo = _pseudoController.text.trim();

    if (email.isEmpty || password.isEmpty || pseudo.isEmpty) {
      setState(() {
        _errorMessage = "Veuillez remplir tous les champs";
      });
      return;
    }

    try {
      // Vérifie si le pseudo est disponible
      bool isAvailable = await _isPseudoAvailable(pseudo);

      if (!isAvailable) {
        setState(() {
          _errorMessage = "Ce pseudo est déjà utilisé.";
        });
        return;
      }

      // Créer le compte
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user?.uid ?? "";

      // Ajouter le pseudo dans Firestore
      await _firestore.collection("users").doc(userId).set({
        "pseudo": pseudo,
        "email": email,
        "created_at": DateTime.now(),
      });

      setState(() {
        _errorMessage = "Compte créé avec succès !";
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Erreur inconnue";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _pseudoController,
          decoration: const InputDecoration(
            labelText: 'Pseudo',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Mot de passe',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: _createAccount,
          child: const Text('Créer un compte'),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

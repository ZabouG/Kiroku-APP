import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../fonction/pseudo.dart';
import 'user_reviews_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// Récupère les informations de l'utilisateur
  Future<void> _loadUserInfo() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();

      setState(() {
        _pseudoController.text = snapshot['pseudo'] ?? "Invité";
      });
    }
  }

  /// Vérifie le mot de passe
  Future<bool> _verifyPassword(String password) async {
    User? user = _auth.currentUser;
    String email = user?.email ?? "";

    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await user?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      setState(() {
        _errorMessage = "Mot de passe incorrect.";
      });
      return false;
    }
  }

  /// Met à jour le pseudo
  Future<void> _updateProfile() async {
    String pseudo = _pseudoController.text.trim();
    String password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Veuillez saisir votre mot de passe pour valider.";
      });
      return;
    }

    setState(() => _isLoading = true);

    bool isAuthenticated = await _verifyPassword(password);

    if (!isAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String userId = user.uid;

        if (pseudo.isNotEmpty) {
          await _firestore.collection("users").doc(userId).update({
            "pseudo": pseudo,
          });

          setState(() {
            _errorMessage = "Pseudo mis à jour avec succès.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la mise à jour : $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Supprime le compte utilisateur
  Future<void> _deleteAccount() async {
    String password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Veuillez saisir votre mot de passe pour continuer.";
      });
      return;
    }

    setState(() => _isLoading = true);

    bool isAuthenticated = await _verifyPassword(password);

    if (!isAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String userId = user.uid;

        // Mettre à jour le pseudo en "Utilisateur supprimé"
        await _firestore.collection('users').doc(userId).update({
          "pseudo": "Utilisateur supprimé",
        });

        // Supprimer l'utilisateur de Firebase Auth
        await user.delete();

        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la suppression du compte : $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiroku - Profil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pseudoController,
              decoration: const InputDecoration(labelText: 'Pseudo'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
            ),
            const SizedBox(height: 24.0),

            // Bouton Valider
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Valider'),
            ),

            const SizedBox(height: 16.0),

            // Bouton Voir avis
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserReviewsPage()),
                );
              },
              child: const Text('Voir mes avis'),
            ),

            const SizedBox(height: 16.0),

            // Bouton Supprimer le compte
            ElevatedButton(
              onPressed: _isLoading ? null : _deleteAccount,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: _isLoading ? const CircularProgressIndicator() : const Text('Supprimer le compte'),
            ),

            const SizedBox(height: 16.0),

            // Bouton De déconnexion
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                await _auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: _isLoading ? const CircularProgressIndicator() : const Text('Déconnexion'),
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
        ),
      ),
    );
  }
}

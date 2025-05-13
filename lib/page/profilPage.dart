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
  final TextEditingController _emailController = TextEditingController();
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
        _emailController.text = user.email ?? "Email non disponible";
      });
    }
  }

  /// Met à jour le pseudo
  Future<void> _updatePseudo() async {
    String pseudo = _pseudoController.text.trim();
    User? user = _auth.currentUser;

    if (pseudo.isEmpty) {
      setState(() {
        _errorMessage = "Le pseudo ne peut pas être vide";
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (user != null) {
        String userId = user.uid;
        String response = await updatePseudo(userId, pseudo);
        setState(() {
          _errorMessage = response;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la mise à jour : $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Met à jour l'email
  Future<void> _updateEmail() async {
    String email = _emailController.text.trim();
    User? user = _auth.currentUser;

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "L'email ne peut pas être vide";
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (user != null) {
        await user.sendEmailVerification();
        await user.updateEmail(email);
        await _firestore.collection('users').doc(user.uid).update({"email": email});
        setState(() {
          _errorMessage = "Email mis à jour avec succès !";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la mise à jour de l'email : $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Supprime le compte et tous ses avis
  Future<void> _deleteAccount() async {
    User? user = _auth.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String userId = user.uid;

      // Supprime tous les avis de l'utilisateur
      QuerySnapshot avisSnapshot = await _firestore.collection('avis').get();
      for (var doc in avisSnapshot.docs) {
        String mangaId = doc.id;
        QuerySnapshot ratingsSnapshot = await _firestore
            .collection('avis')
            .doc(mangaId)
            .collection('ratings')
            .where('userId', isEqualTo: userId)
            .get();

        for (var ratingDoc in ratingsSnapshot.docs) {
          await ratingDoc.reference.delete();
        }
      }

      // Supprime le document utilisateur
      await _firestore.collection('users').doc(userId).delete();

      // Supprime le compte
      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte supprimé avec succès')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la suppression : $e";
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
            const SizedBox(height: 16.0),
            TextField(
              controller: _pseudoController,
              decoration: const InputDecoration(
                labelText: 'Pseudo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _updatePseudo,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Modifier le pseudo'),
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
            ElevatedButton(
              onPressed: _isLoading ? null : _updateEmail,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Modifier l\'email'),
            ),

            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _isLoading ? null : _deleteAccount,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Supprimer le compte'),
            ),

            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserReviewsPage()),
                );
              },
              child: const Text('Voir mes avis'),
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

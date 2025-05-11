import 'package:flutter/material.dart';
import 'navBar.dart';

/// Page d'authentification - Bascule entre la page de connexion et la page de création de compte
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool wantConnect = true;

  /// Getter pour le texte du bouton
  String get buttonText => wantConnect ? "Créer un compte" : "Se connecter";

  /// Méthode pour basculer entre les deux pages
  void _switchPage() {
    setState(() {
      wantConnect = !wantConnect;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiroku'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _switchPage,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationBarApp(),
    );
  }
}

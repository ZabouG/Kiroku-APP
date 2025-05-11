import 'package:flutter/material.dart';
import 'login_page.dart';
import 'sign_in_page.dart';

/// Page d'authentification - Bascule entre la page de connexion et la page de création de compte
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                wantConnect ? const LoginPage() : const SigninPage(),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _switchPage,
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

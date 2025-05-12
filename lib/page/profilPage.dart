import 'package:flutter/material.dart';

/// Page d'authentification - Bascule entre la page de connexion et la page de création de compte
class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiroku'),
        centerTitle: true,
      ),
      body: Center(
            child: Text(
              'Profil page',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
    );
  }
}

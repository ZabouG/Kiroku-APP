import 'package:flutter/material.dart';

/// Page d'authentification - Bascule entre la page de connexion et la page de création de compte
class AvisPage extends StatefulWidget {
  const AvisPage({Key? key}) : super(key: key);

  @override
  _AvisPageState createState() => _AvisPageState();
}

class _AvisPageState extends State<AvisPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiroku'),
        centerTitle: true,
      ),
      body: Center(
            child: Text(
              'Avis page',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
    );
  }
}

import 'package:flutter/material.dart';

/// Page d'authentification - Bascule entre la page de connexion et la page de création de compte
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiroku- Home Page'),
        centerTitle: true,
      ),
      body: Center(
            child: Text(
              'Home page',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
    );
  }
}

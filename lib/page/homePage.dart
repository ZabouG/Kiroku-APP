import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../fonction/sendData.dart';
import 'listAvisPage.dart';

/// Page d'accueil affichant les informations des mangas et leur moyenne de note
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

/// Fonction pour obtenir le pseudo de l'utilisateur connecté
Future<String?> getPseudo() async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null) {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      return snapshot['pseudo'];
    }
  }

  return null;
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _animeData;

  @override
  void initState() {
    super.initState();
    _animeData = getAnimeWithAverageRating();
  }

  /// Fonction pour rafraîchir les données
  Future<void> _refreshData() async {
    setState(() {
      _animeData = getAnimeWithAverageRating();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: getPseudo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Chargement...');
            } else if (snapshot.hasError) {
              return const Text('Erreur');
            } else if (snapshot.hasData && snapshot.data != null) {
              return Text('Kiroku - ${snapshot.data}');
            } else {
              return const Text('Kiroku - Invité');
            }
          },
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _animeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Erreur : ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Aucun manga trouvé'),
              );
            } else {
              final data = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  String mangaId = data.keys.elementAt(index);
                  Map<String, dynamic> mangaData = data[mangaId];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(mangaData['image']),
                      ),
                      title: Text(mangaData['title'] ?? 'Titre indisponible'),
                      subtitle: Text(
                        'Note Moyenne : ${mangaData['averageRating'].toStringAsFixed(2)}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListAvisPage(mangaId: mangaId),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

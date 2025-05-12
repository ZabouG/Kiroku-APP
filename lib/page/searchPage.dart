import 'package:flutter/material.dart';
import '../fonction/apiRequest.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  int totalReponse = 0;
  String resultat = '';
  List<dynamic> results = [];

  /// Fonction appelée à chaque saisie
  void _onSearchChanged(String value) {
    setState(() {
      query = value;
    });

    if (query.isNotEmpty) {
      requestAPI(query)
          .then((response) {
            setState(() {
              results = response['data'];
              totalReponse = response['pagination']['items']['total'];
              if (totalReponse > 99) {
                resultat = 'Résultats trouvés : +99';
              } else if(totalReponse > 0) {
                resultat = 'Résultats trouvés : $totalReponse';
              } else {
                resultat = 'Aucun résultat trouvé';
              }
            });
          })
          .catchError((error) {
            setState(() {
              resultat = 'Erreur de recherche';
            });
          });
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiroku'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16.0),
            TextField(
                decoration: InputDecoration(
                hintText: 'Rechercher',
                border: const OutlineInputBorder(),
                labelText: resultat,
                ),
                onChanged: _onSearchChanged,
              ),
              //liste des resultats dans resultat
              const SizedBox(height: 16.0),
              Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  var manga = results[index];
                  return ListTile(
                    leading: manga['images'] != null
                        ? Image.network(
                            manga['images']['jpg']['image_url'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(width: 50, height: 50),
                    title: Text(manga['title'] ?? 'Titre indisponible'),
                    subtitle: Text('ID : ${manga['mal_id']}'),
                    
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

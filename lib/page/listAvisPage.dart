import 'package:flutter/material.dart';
import '../fonction/sendData.dart';
import '../fonction/pseudo.dart';

/// Page d'accueil affichant les avis pour un manga spécifique
class ListAvisPage extends StatefulWidget {
  final String mangaId;
  const ListAvisPage({required this.mangaId, Key? key}) : super(key: key);

  @override
  _ListAvisPageState createState() => _ListAvisPageState();
}

class _ListAvisPageState extends State<ListAvisPage> {
  final int maxLinesCollapsed = 3;
  Map<String, bool> isExpandedMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiroku - Avis Page'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getMangaAvis(widget.mangaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucun avis trouvé'),
            );
          } else {
            final data = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: data.length,
              itemBuilder: (context, index) {
                String userId = data.keys.elementAt(index);
                Map<String, dynamic> avisData = data[userId];
                String avis = avisData['avis'];
                double rating = avisData['rating'];

                bool isExpanded = isExpandedMap[userId] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: FutureBuilder<String?>(
                    future: getPseudoById(userId),
                    builder: (context, pseudoSnapshot) {
                      String pseudo = "Utilisateur Inconnu";
                      if (pseudoSnapshot.connectionState == ConnectionState.done &&
                          pseudoSnapshot.hasData) {
                        pseudo = pseudoSnapshot.data!;
                      }

                      return ListTile(
                        title: Text(
                          'Utilisateur : $pseudo',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Note : $rating / 5'),
                            const SizedBox(height: 4),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final textSpan = TextSpan(
                                  text: avis,
                                  style: const TextStyle(color: Colors.black),
                                );

                                final textPainter = TextPainter(
                                  text: textSpan,
                                  maxLines: maxLinesCollapsed,
                                  textDirection: TextDirection.ltr,
                                );

                                textPainter.layout(
                                  maxWidth: constraints.maxWidth,
                                );

                                bool isOverflowing =
                                    textPainter.didExceedMaxLines;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      avis,
                                      maxLines: isExpanded ? null : maxLinesCollapsed,
                                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                    ),
                                    if (isOverflowing)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isExpandedMap[userId] = !isExpanded;
                                            });
                                          },
                                          child: Text(isExpanded ? "Réduire" : "Voir plus"),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
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
    );
  }
}

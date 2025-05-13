import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'avisPage.dart';

class UserReviewsPage extends StatefulWidget {
  const UserReviewsPage({Key? key}) : super(key: key);

  @override
  _UserReviewsPageState createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getUserReviews() async {
    User? user = _auth.currentUser;
    List<Map<String, dynamic>> reviews = [];

    if (user != null) {
      String userId = user.uid;

      QuerySnapshot snapshot = await _firestore.collection('avis').get();

      for (var doc in snapshot.docs) {
        String mangaId = doc.id;
        QuerySnapshot ratingsSnapshot = await _firestore
            .collection('avis')
            .doc(mangaId)
            .collection('ratings')
            .where('userId', isEqualTo: userId)
            .get();

        for (var ratingDoc in ratingsSnapshot.docs) {
          reviews.add({
            "mangaId": mangaId,
            "manga": {
              "mal_id": mangaId,
              "title": doc['title'],
              "images": {
                "jpg": {"image_url": doc['image_url']}
              }
            },
            "rating": ratingDoc['rating'],
            "avis": ratingDoc['avis'],
          });
        }
      }
    }

    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Avis'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUserReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun avis trouvé'));
          } else {
            final reviews = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> review = reviews[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    title: Text(review['manga']['title'] ?? 'Titre inconnu'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Note : ${review['rating']} / 5'),
                        Text('Avis : ${review['avis']}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AvisPage(review['manga']),
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

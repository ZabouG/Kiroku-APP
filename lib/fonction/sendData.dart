import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Fonction pour ajouter ou mettre à jour un avis
Future<String> addRating(String rating, String avis, Map<String, dynamic> manga) async {
  if (rating.isEmpty || avis.isEmpty) {
    return "Veuillez remplir tous les champs";
  }

  String mangaId = manga['mal_id'].toString();
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return "Utilisateur non connecté";
  }

  try {
    DocumentReference mangaRef = FirebaseFirestore.instance.collection("avis").doc(mangaId);

    // Vérifie si le manga existe déjà
    DocumentSnapshot snapshot = await mangaRef.get();

    if (!snapshot.exists) {
      // Si le manga n'existe pas, on ajoute ses informations principales
      await mangaRef.set({
        "title": manga['title'] ?? "Titre indisponible",
        "image_url": manga['images']?['jpg']?['image_url'] ?? "https://via.placeholder.com/100",
        "created_at": DateTime.now(),
      });
    }

    // Référence à la sous-collection `ratings`
    DocumentReference userRatingRef = mangaRef.collection("ratings").doc(userId);

    // Vérifie si l'utilisateur a déjà noté ce manga
    DocumentSnapshot userRatingSnapshot = await userRatingRef.get();

    if (userRatingSnapshot.exists) {
      // Mise à jour de l'avis existant
      await userRatingRef.update({
        "rating": double.tryParse(rating) ?? 0.0,
        "avis": avis,
        "date": DateTime.now(),
      });
      return "Avis mis à jour avec succès !";
    } else {
      // Ajout d'un nouvel avis
      await userRatingRef.set({
        "rating": double.tryParse(rating) ?? 0.0,
        "avis": avis,
        "date": DateTime.now(),
        "userId": userId,
      });
      return "Avis ajouté avec succès !";
    }

  } on FirebaseException catch (e) {
    return e.message ?? "Erreur Firebase";
  } catch (e) {
    return "Erreur inattendue : $e";
  }
}

Future<Map<String, dynamic>> getAnimeWithAverageRating() async {
  Map<String, dynamic> mangaData = {};

  try {
    // Récupère tous les documents de la collection "avis"
    QuerySnapshot avisSnapshot = await FirebaseFirestore.instance.collection('avis').get();

    for (var doc in avisSnapshot.docs) {
      String mangaId = doc.id;
      String mangaTitle = doc['title'] ?? "Titre indisponible";
      String mangaImage = doc['image_url'] ?? 'https://via.placeholder.com/100';

      double totalRating = 0;
      int count = 0;

      // Récupère les sous-collections "ratings" pour chaque manga
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('avis')
          .doc(mangaId)
          .collection('ratings')
          .get();

      for (var userDoc in ratingsSnapshot.docs) {
        // Récupère le rating de chaque utilisateur pour ce manga
        double rating = userDoc['rating']?.toDouble() ?? 0;
        totalRating += rating;
        count++;
      }

      double averageRating = count > 0 ? totalRating / count : 0;

      // Stocke les informations du manga
      mangaData[mangaId] = {
        'title': mangaTitle,
        'image': mangaImage,
        'averageRating': averageRating,
      };
    }

    return mangaData;

  } catch (e) {
    print('Erreur : $e');
    return {};
  }
}

Future<Map<String, dynamic>> getMangaAvis(String mangaId) async {
  Map<String, dynamic> avisData = {};

  try {
    // Référence à la collection `ratings` pour ce manga
    QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
        .collection('avis')
        .doc(mangaId)
        .collection('ratings')
        .get();

    for (var userDoc in ratingsSnapshot.docs) {
      String userId = userDoc.id;
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      avisData[userId] = {
        "avis": data['avis'] ?? "Pas d'avis",
        "rating": data['rating']?.toDouble() ?? 0.0,
      };
    }

    return avisData;
  } catch (e) {
    print('Erreur : $e');
    return {};
  }
}
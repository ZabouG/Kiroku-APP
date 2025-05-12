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

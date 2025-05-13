import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getPseudo() async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null) {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      return snapshot['pseudo'];
    }
  }

  return "Invité";
}

/// Fonction pour obtenir le pseudo à partir de l'ID utilisateur
Future<String> getPseudoById(String userId) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      return snapshot['pseudo'] ?? "Invité";
    }
  } catch (e) {
    print("Erreur lors de la récupération du pseudo : $e");
  }

  return "Invité";
}


/// Fonction pour ajouter ou modifier un pseudo
/// - `userId` : l'identifiant de l'utilisateur
/// - `newPseudo` : le nouveau pseudo à vérifier et à ajouter
Future<String> updatePseudo(String userId, String newPseudo) async {
  if (newPseudo.isEmpty) {
    return "Le pseudo ne peut pas être vide";
  }

  try {
    // Vérifie si le pseudo est déjà utilisé
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('pseudo', isEqualTo: newPseudo)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return "Ce pseudo est déjà utilisé";
    }

    // Si le pseudo est disponible, on le met à jour
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'pseudo': newPseudo,
    }, SetOptions(merge: true));

    return "Pseudo mis à jour avec succès !";

  } on FirebaseException catch (e) {
    return e.message ?? "Erreur Firebase";
  } catch (e) {
    return "Erreur inattendue : $e";
  }
}
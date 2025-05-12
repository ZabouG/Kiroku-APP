import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import '../fonction/sendData.dart';

class AvisPage extends StatefulWidget {
  final Map<String, dynamic> manga;

  const AvisPage(this.manga, {Key? key}) : super(key: key);

  @override
  _AvisPageState createState() => _AvisPageState();
}

class _AvisPageState extends State<AvisPage> {
  final TextEditingController _avisController = TextEditingController();
  double rating = 0.0;
  bool isLoading = false;

  /// Méthode pour envoyer l'avis
  Future<void> _sendReview() async {
    String avis = _avisController.text.trim();
    if (avis.isEmpty || rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et donner une note.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String response = await addRating(
        rating.toString(),
        avis,
        widget.manga,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response)),
      );

      // Réinitialise le formulaire après envoi
      _avisController.clear();
      setState(() {
        rating = 0.0;
      });

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiroku - Avis'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(
                    widget.manga['images']?['jpg']?['image_url'] ??
                        'https://via.placeholder.com/100',
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    widget.manga['title'] ?? 'Titre indisponible',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            const Text(
              'Laissez votre avis :',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            // Champ de notation avec étoiles
            Center(
              child: SmoothStarRating(
                rating: rating,
                size: 40,
                starCount: 5,
                color: Colors.amber,
                borderColor: Colors.grey,
                allowHalfRating: true,
                onRatingChanged: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),

            // Champ de texte pour l'avis
            TextField(
              controller: _avisController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Écrivez votre avis ici...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendReview,
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Envoyer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

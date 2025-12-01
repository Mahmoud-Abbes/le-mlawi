import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/cart_item_card.dart';
import '../config/translation_config.dart';

class PanierPage extends StatefulWidget {
  const PanierPage({Key? key}) : super(key: key);

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  // ==================== Variables d'état ====================
  List<Map<String, dynamic>> cartItems = [];
  double totalProducts = 0.0;
  bool isLoading = true;
  bool isPlacingOrder = false;

  // Variables pour les traductions
  String translatedTonPanier = 'Ton Panier';
  String translatedPanierVide = 'Votre panier est vide';
  String translatedInfoCommande = 'Information sur la commande';
  String translatedTotalProduits = 'Total Produits';
  String translatedLivraison = 'Livraison';
  String translatedGratuit = 'Gratuit';
  String translatedTotal = 'Total';
  String translatedPlacerCommande = 'Placer commande';
  String translatedProduitRetire = 'Produit retiré du panier';
  String translatedCommandeSucces = 'Commande passée avec succès!';
  String translatedErreurCommande = 'Erreur lors de la commande: ';

  // ==================== Initialisation ====================
  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _loadCart();
  }

  // ==================== Chargement des traductions ====================
  Future<void> _loadTranslations() async {
    translatedTonPanier = await translate('Ton Panier');
    translatedPanierVide = await translate('Votre panier est vide');
    translatedInfoCommande = await translate('Information sur la commande');
    translatedTotalProduits = await translate('Total Produits');
    translatedLivraison = await translate('Livraison');
    translatedGratuit = await translate('Gratuit');
    translatedTotal = await translate('Total');
    translatedPlacerCommande = await translate('Placer commande');
    translatedProduitRetire = await translate('Produit retiré du panier');
    translatedCommandeSucces = await translate('Commande passée avec succès!');
    translatedErreurCommande = await translate('Erreur lors de la commande: ');

    if (mounted) {
      setState(() {});
    }
  }

  // ==================== Chargement du panier ====================
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    String? cartString = prefs.getString('cart');

    if (cartString != null) {
      List<dynamic> cart = json.decode(cartString);
      setState(() {
        cartItems = cart.map((item) => Map<String, dynamic>.from(item)).toList();
        _calculateTotal();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ==================== Calcul du total ====================
  void _calculateTotal() {
    totalProducts = 0.0;
    for (var item in cartItems) {
      totalProducts += item['totalPrice'] * item['quantity'];
    }
  }

  // ==================== Mise à jour du panier ====================
  Future<void> _updateCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(cartItems));
    await prefs.setDouble('cartTotal', totalProducts);
  }

  // ==================== Mise à jour de la quantité ====================
  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) {
      _removeItem(index);
      return;
    }

    setState(() {
      cartItems[index]['quantity'] = newQuantity;
      _calculateTotal();
    });
    await _updateCart();
  }

  // ==================== Suppression d'un article ====================
  Future<void> _removeItem(int index) async {
    setState(() {
      cartItems.removeAt(index);
      _calculateTotal();
    });
    await _updateCart();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translatedProduitRetire),
        backgroundColor: const Color(0xFFD48C41),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==================== Génération d'ID unique ====================
  String _generateUniqueId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // ==================== Passer la commande ====================
  Future<void> _placeOrder() async {
    if (cartItems.isEmpty) return;

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // Récupération de l'email utilisateur depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail == null || userEmail.isEmpty) {
        throw Exception('User email not found. Please login again.');
      }

      final commandeId = 'CMD-${_generateUniqueId()}';

      // Récupération du nom du magasin depuis le premier article du panier
      String storeName = cartItems.isNotEmpty
          ? (cartItems[0]['storeName'] ?? 'BestMlawi')
          : 'BestMlawi';

      // Préparation des données des produits
      List<Map<String, dynamic>> products = cartItems.map((item) {
        return {
          'productId': item['productId'] ?? item['id'] ?? 0,
          'name': item['productName'] ?? '',
          'quantity': item['quantity'] ?? 1,
          'price': item['totalPrice'] ?? 0.0,
          'supplements': item['supplements'] ?? [],
        };
      }).toList();

      // Création du document de commande avec l'email utilisateur
      await FirebaseFirestore.instance.collection('commandes').doc(commandeId).set({
        'commandeId': commandeId,
        'userEmail': userEmail,
        'storeName': storeName,
        'products': products,
        'totalPrice': totalProducts,
        'etatCommande': 'En cours de traitement',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Effacement du panier après une commande réussie
      await prefs.remove('cart');
      await prefs.remove('cartTotal');

      setState(() {
        isPlacingOrder = false;
      });

      // Affichage du message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translatedCommandeSucces),
          backgroundColor: const Color(0xFFA2B84E),
        ),
      );

      // Navigation vers la page des commandes
      Navigator.pushReplacementNamed(context, '/commandes');
    } catch (e) {
      setState(() {
        isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$translatedErreurCommande$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== Interface utilisateur ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8EC),
          borderRadius: BorderRadius.circular(27),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          clipBehavior: Clip.none,
          children: [
            // En-tête
            Positioned(
              left: 15,
              top: 30,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: 180 * pi / 180,
                      child: Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F33a3bbb97c5a949d4419852f6eb37cf8e75609ebimage%2021.png?alt=media&token=59944fa8-af4b-4add-b9ad-7da214b6240e',
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 140,
              top: 40,
              child: Text(
                translatedTonPanier,
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xFF3B2E1A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),

            // Liste des articles du panier
            if (cartItems.isEmpty)
              Positioned.fill(
                top: -200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        translatedPanierVide,
                        style: GoogleFonts.getFont(
                          'Inter',
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                left: 0,
                right: 0,
                top: 80,
                bottom: 0,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 27, right: 27, top: 25),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: CartItemCard(
                        item: cartItems[index],
                        onQuantityChanged: (newQuantity) {
                          _updateQuantity(index, newQuantity);
                        },
                        onRemove: () {
                          _removeItem(index);
                        },
                      ),
                    );
                  },
                ),
              ),

            // Section inférieure avec les informations de commande
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 310,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEDC1),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Effet papier déchiré - triangles
                    Positioned(
                      left: 0,
                      right: 0,
                      top: -5,
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 5),
                        painter: RippedPaperPainter(),
                      ),
                    ),

                    // Conteneur principal pour tous les éléments d'information
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 30,
                      child: Container(
                        child: Column(
                          children: [
                            // Informations sur la commande
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  translatedInfoCommande,
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    color: const Color(0xF23B2E1A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Total Produits
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 29),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    translatedTotalProduits,
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${totalProducts.toStringAsFixed(3)} DT',
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Livraison
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 29),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    translatedLivraison,
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    translatedGratuit,
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 26),

                            // Ligne de séparation
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Container(
                                width: double.infinity,
                                height: 1,
                                color: Colors.black26,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Total
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    translatedTotal,
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: const Color(0xF23B2E1A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${totalProducts.toStringAsFixed(3)} DT',
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Bouton Placer commande
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD48C41),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(59),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: (cartItems.isEmpty || isPlacingOrder)
                                    ? null
                                    : _placeOrder,
                                child: isPlacingOrder
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      translatedPlacerCommande,
                                      style: GoogleFonts.getFont(
                                        'Inter',
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Image.network(
                                      'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fda3aedd0572d439bcb16c176ebbdfc9b8e2ccfa0next%201.png?alt=media&token=8cfd38a5-509a-4440-84cc-3aadde3dd3b9',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Peintre personnalisé pour l'effet papier déchiré ====================
class RippedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFEDC1)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Commencer depuis la gauche
    path.moveTo(0, size.height);

    // Créer un motif en zigzag (triangles)
    double triangleWidth = 12;
    double triangleHeight = size.height;

    for (double x = 0; x < size.width; x += triangleWidth) {
      path.lineTo(x + triangleWidth / 2, 0);
      path.lineTo(x + triangleWidth, size.height);
    }

    // Compléter le chemin
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
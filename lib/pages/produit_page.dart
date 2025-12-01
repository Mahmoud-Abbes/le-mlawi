import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/global_params.dart';
import '../config/translation_config.dart';

class ProduitPage extends StatefulWidget {
  final int productId;

  const ProduitPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProduitPageState createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  Set<int> selectedSupplements = {};
  int? selectedDrink;

  // ============================================================================
  // TRADUCTIONS
  // ============================================================================
  Map<String, String> translations = {};
  bool isLoadingTranslations = true;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final product = GlobalParams.getProductById(widget.productId);
    if (product == null) return;

    // Liste des clés à traduire
    final keys = [
      'Produit non trouvé',
      'Suppléments',
      'Boisson',
      'Total',
      'Ajouté au panier',
      'DT',
      'Voulez-vous des suppléments ?',
      'Quelque chose à boire ?',
      'Ajouter au Panier',
      product['name'], // Nom du produit
      product['description'], // Description du produit
      product['deliveryFee'], // Frais de livraison
      product['deliveryTime'], // Temps de livraison
    ];

    // Ajouter les noms des suppléments
    if (product['supplements'] != null) {
      for (var supplement in product['supplements']) {
        keys.add(supplement['name']);
      }
    }

    // Ajouter les noms des boissons
    if (product['drinks'] != null) {
      for (var drink in product['drinks']) {
        keys.add(drink['name']);
      }
    }

    // Ajouter les noms des boissons globales
    for (var beverage in GlobalParams.beverages) {
      keys.add(beverage['name']);
    }

    // Traduire toutes les clés
    for (var key in keys) {
      translations[key] = await translate(key);
    }

    if (mounted) {
      setState(() {
        isLoadingTranslations = false;
      });
    }
  }

  // ============================================================================
  // AJOUT AU PANIER
  // ============================================================================
  Future<void> _addToCart() async {
    final product = GlobalParams.getProductById(widget.productId);
    if (product == null) return;

    // Calculer le prix total
    double totalPrice = product['price'];

    // Préparer la liste des suppléments avec prix
    List<Map<String, dynamic>> supplementsList = [];
    if (product['supplements'] != null) {
      for (int index in selectedSupplements) {
        var supplement = product['supplements'][index];
        supplementsList.add({
          'name': supplement['name'],
          'price': supplement['price'],
        });
        totalPrice += supplement['price'];
      }
    }

    // Ajouter la boisson si sélectionnée
    Map<String, dynamic>? selectedBeverageData;
    if (selectedDrink != null) {
      selectedBeverageData = {
        'name': GlobalParams.beverages[selectedDrink!]['name'],
        'price': product['drinks'][0]['price'],
      };
      totalPrice += product['drinks'][0]['price'];
    }

    // Créer l'objet article du panier
    Map<String, dynamic> cartItem = {
      'productId': widget.productId,
      'productName': product['name'],
      'productPrice': product['price'],
      'supplements': supplementsList,
      'beverage': selectedBeverageData,
      'quantity': 1,
      'totalPrice': totalPrice,
    };

    // Obtenir l'instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Obtenir le panier existant ou créer un nouveau
    String? cartString = prefs.getString('cart');
    List<dynamic> cart = [];

    if (cartString != null) {
      cart = json.decode(cartString);
    }

    // Ajouter le nouvel article au panier
    cart.add(cartItem);

    // Sauvegarder le panier mis à jour
    await prefs.setString('cart', json.encode(cart));

    // Calculer et sauvegarder le total du panier
    double cartTotal = 0;
    for (var item in cart) {
      cartTotal += item['totalPrice'] * item['quantity'];
    }
    await prefs.setDouble('cartTotal', cartTotal);

    // Afficher le message de succès
    if (mounted) {
      String supplementsInfo = '';
      if (supplementsList.isNotEmpty) {
        List supplementNames = supplementsList.map((s) => s['name']).toList();
        supplementsInfo = '\n${translations['Suppléments']}: ${supplementNames.join(", ")}';
      }

      String drinkInfo = '';
      if (selectedBeverageData != null) {
        drinkInfo = '\n${translations['Boisson']}: ${selectedBeverageData['name']}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${translations['Ajouté au panier']}$supplementsInfo$drinkInfo\n${translations['Total']}: ${totalPrice.toStringAsFixed(3)} ${translations['DT']}',
          ),
          backgroundColor: const Color(0xFFA2B84E),
          duration: const Duration(seconds: 2),
        ),
      );

      // Naviguer vers la page panier après un court délai
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushNamed(context, '/panier');
    }
  }

  // ============================================================================
  // INTERFACE UTILISATEUR
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    final product = GlobalParams.getProductById(widget.productId);

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Text(translations['Produit non trouvé'] ?? 'Produit non trouvé'),
        ),
      );
    }

    // Calculer le prix total
    double totalPrice = product['price'];

    // Ajouter les prix des suppléments
    if (product['supplements'] != null) {
      for (int index in selectedSupplements) {
        totalPrice += product['supplements'][index]['price'];
      }
    }

    // Ajouter le prix de la boisson
    if (selectedDrink != null && product['drinks'] != null) {
      totalPrice += product['drinks'][0]['price'];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: Stack(
        children: [
          // Contenu principal
          SingleChildScrollView(
            child: Column(
              children: [
                // En-tête avec image du produit
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Image du produit
                    Image.network(
                      product['image'],
                      width: double.infinity,
                      height: 380,
                      fit: BoxFit.cover,
                    ),

                    // Bouton retour
                    Positioned(
                      left: 11,
                      top: 50,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 37,
                          height: 37,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Center(
                            child: Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F7ef02a63cef736f908d632c7c7f9ce21af39351fimage%2018.png?alt=media&token=7afc748a-5068-4663-9a20-a2a6dc3f43e1',
                              width: 16,
                              height: 16,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Badge nom du produit
                    Positioned(
                      left: 11,
                      top: 237,
                      child: Container(
                        height: 37,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD48C41), Color(0xFFFFCC97)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            translations[product['name']] ?? product['name'],
                            style: GoogleFonts.getFont(
                              'Inter',
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Conteneur blanc qui chevauche l'image
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 297,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(47),
                            topRight: Radius.circular(47),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Note
                            Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F3889c445363a2e27f3fcec92b6bff0902f1c308bstar%201.png?alt=media&token=c95dd053-8e8d-4ecf-8752-9d80acad6205',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product['rating'].toString(),
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xFFED9D49),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 25),
                            // Frais de livraison
                            Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fa6943a88fa2656b3ab80b60e5dcb2e67acdf33c2motorcycle%20(1)%201.png?alt=media&token=e629c188-48f5-46bd-9bf0-8b59251bca4c',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              translations[product['deliveryFee']] ?? product['deliveryFee'],
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xFFED9D49),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 25),
                            // Temps de livraison
                            Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fbf30ecae59637b455384798e5ada459fbaf3dac3clock%201.png?alt=media&token=c08616cf-6bdd-4dcc-83b3-dacb8e725402',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              translations[product['deliveryTime']] ?? product['deliveryTime'],
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xFFED9D49),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Conteneur blanc continue
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section détails du produit
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nom du produit
                            Text(
                              translations[product['name']] ?? product['name'],
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xFF3B2E1A),
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Prix
                            Text(
                              '${product['price'].toStringAsFixed(3)} ${translations['DT']}',
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              translations[product['description']] ?? product['description'],
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xCC3B2E1A),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Section suppléments
                            if (product['supplements'] != null) ...[
                              Text(
                                translations['Voulez-vous des suppléments ?'] ?? 'Voulez-vous des suppléments ?',
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: const Color(0xFF3B2E1A),
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...List.generate(
                                product['supplements'].length,
                                    (index) => _buildCheckboxOption(
                                  translations[product['supplements'][index]['name']] ?? product['supplements'][index]['name'],
                                  '+${product['supplements'][index]['price'].toStringAsFixed(3)} ${translations['DT']}',
                                  selectedSupplements.contains(index),
                                      () {
                                    setState(() {
                                      if (selectedSupplements.contains(index)) {
                                        selectedSupplements.remove(index);
                                      } else {
                                        selectedSupplements.add(index);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 30),

                            // Section boissons
                            if (product['drinks'] != null) ...[
                              Text(
                                translations['Quelque chose à boire ?'] ?? 'Quelque chose à boire ?',
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: const Color(0xFF3B2E1A),
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                translations[product['drinks'][0]['name']] ?? product['drinks'][0]['name'],
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: const Color(0xCC3B2E1A),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Options de boissons
                              SizedBox(
                                height: 200,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    GlobalParams.beverages.length,
                                        (index) => _buildBeverageOption(
                                      translations[GlobalParams.beverages[index]['name']] ?? GlobalParams.beverages[index]['name'],
                                      GlobalParams.beverages[index]['image'],
                                      index,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton ajouter au panier (fixé en bas)
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD48C41),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(59),
                  ),
                ),
                onPressed: _addToCart,
                child: Text(
                  translations['Ajouter au Panier'] ?? 'Ajouter au Panier',
                  style: GoogleFonts.getFont(
                    'Inter',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGETS PERSONNALISÉS
  // ============================================================================

  // Widget option avec case à cocher
  Widget _buildCheckboxOption(
      String label,
      String price,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD48C41) : Colors.transparent,
                border: Border.all(
                  width: 1.4,
                  color: const Color(0xFF3B2E1A),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xCC3B2E1A),
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              price,
              style: GoogleFonts.getFont(
                'Inter',
                color: const Color(0xCC3B2E1A),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget option de boisson
  Widget _buildBeverageOption(String name, String imageUrl, int index) {
    bool isSelected = selectedDrink == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          SizedBox(
            width: 90,
            height: 170,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Conteneur arrière-plan positionné en bas
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0x35D48C41),
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
                // Image commençant au centre du conteneur et débordant vers le haut
                Positioned(
                  bottom: 35,
                  child: Image.network(
                    imageUrl,
                    width: 110,
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                ),
                // Bouton Plus/Check en bas au centre - moitié dedans, moitié dehors
                Positioned(
                  bottom: 5,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDrink = isSelected ? null : index;
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD48C41) : Colors.white,
                        border: Border.all(
                          width: 1.5,
                          color: isSelected ? const Color(0xFFD48C41) : const Color(0x38000000),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Icon(
                          isSelected ? Icons.check : Icons.add,
                          size: 20,
                          color: isSelected ? Colors.white : const Color(0xFF3B2E1A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          // Nom de la boisson
          Text(
            name,
            style: GoogleFonts.getFont(
              'Inter',
              color: const Color(0xCC3B2E1A),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
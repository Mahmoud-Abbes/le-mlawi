import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/global_params.dart';
import '../config/translation_config.dart'; // Ajout pour la traduction

class ConsulterProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ConsulterProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _ConsulterProductCardState createState() => _ConsulterProductCardState();
}

class _ConsulterProductCardState extends State<ConsulterProductCard> {
  // ============================================================================
  // SYSTÈME DE TRADUCTION
  // ============================================================================
  Map<String, String> translations = {};
  bool isLoadingTranslations = true;

  String productName = '';
  String supplementsText = '';

  @override
  void initState() {
    super.initState();
    _loadTranslationsAndData();
  }

  // Charge les traductions et traduit le produit + suppléments
  Future<void> _loadTranslationsAndData() async {
    // Traduire les textes fixes
    final keys = [
      'Quantité',
      'Produit',
      '+', // pour les suppléments
    ];
    for (var key in keys) {
      translations[key] = await translate(key);
    }

    // Traduire le nom du produit
    Map<String, dynamic>? productData = _getProductData();
    if (widget.product['name'] != null) {
      productName = await translate(widget.product['name']);
    } else if (productData?['name'] != null) {
      productName = await translate(productData!['name']);
    } else {
      productName = translations['Produit']!;
    }

    // Traduire les suppléments
    supplementsText = await _getSupplementsText();

    if (mounted) {
      setState(() {
        isLoadingTranslations = false;
      });
    }
  }

  // ============================================================================
  // RÉCUPÉRATION DES SUPPLÉMENTS TRADUITS
  // ============================================================================
  Future<String> _getSupplementsText() async {
    if (widget.product['supplements'] != null &&
        (widget.product['supplements'] as List).isNotEmpty) {
      List<String> suppNames = [];
      for (var supp in widget.product['supplements']) {
        final name = supp['name'] ?? '';
        if (name.isNotEmpty) {
          suppNames.add(await translate(name));
        }
      }
      return '${translations['+']}${suppNames.join(', ')}';
    }
    return '';
  }

  // ============================================================================
  // RÉCUPÉRATION DES DONNÉES PRODUIT COMPLÈTES
  // ============================================================================
  Map<String, dynamic>? _getProductData() {
    int? productId = widget.product['productId'];
    if (productId != null) {
      return GlobalParams.getProductById(productId);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingTranslations) {
      return const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    int quantity = widget.product['quantity'] ?? 1;
    double price = (widget.product['price'] ?? 0.0).toDouble();

    Map<String, dynamic>? productData = _getProductData();
    String? productImage = productData?['image'];

    return Container(
      width: 349,
      height: 109,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 2,
          color: const Color(0x0C000000),
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 0,
            offset: Offset(-4, 9),
            blurRadius: 7,
          )
        ],
      ),
      child: Row(
        children: [
          // IMAGE DU PRODUIT
          Padding(
            padding: const EdgeInsets.all(7),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: productImage != null
                  ? Image.network(
                productImage,
                width: 92,
                height: 94,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _fallbackImage();
                },
              )
                  : _fallbackImage(),
            ),
          ),

          // INFORMATIONS PRODUIT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Nom du produit traduit
                  Text(
                    productName,
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0xFF3B2E1A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Suppléments traduits
                  if (supplementsText.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      supplementsText,
                      style: GoogleFonts.getFont(
                        'Inter',
                        color: const Color(0xAD3B2E1A),
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const Spacer(),

                  // Quantité
                  if (quantity > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        '${translations['Quantité']}: $quantity',
                        style: GoogleFonts.getFont(
                          'Inter',
                          color: const Color(0xAD3B2E1A),
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // PRIX DU PRODUIT
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                '${price.toStringAsFixed(3)} DT',
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xF2D48C41),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // IMAGE DE SECOURS SI L'IMAGE PRODUIT NE CHARGE PAS
  Widget _fallbackImage() {
    return Container(
      width: 92,
      height: 94,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD48C41), Color(0xFFFFC282)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.fastfood,
          size: 40,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/global_params.dart';
import '../config/translation_config.dart';

class CartItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  // ==================== Variables pour les traductions ====================
  String translatedProductName = '';
  Map<String, String> translatedSupplements = {};
  String translatedBeverageName = '';

  // ==================== Initialisation ====================
  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  // ==================== Mise à jour lors du changement de widget ====================
  @override
  void didUpdateWidget(CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _loadTranslations();
    }
  }

  // ==================== Chargement des traductions ====================
  Future<void> _loadTranslations() async {
    // Traduire le nom du produit
    translatedProductName = await translate(widget.item['productName'] ?? '');

    // Traduire les suppléments
    if (widget.item['supplements'] != null && (widget.item['supplements'] as List).isNotEmpty) {
      for (var supp in (widget.item['supplements'] as List)) {
        String suppName = supp['name'].toString();
        translatedSupplements[suppName] = await translate(suppName);
      }
    }

    // Traduire la boisson
    if (widget.item['beverage'] != null) {
      String beverageName = widget.item['beverage']['name'];
      translatedBeverageName = await translate(beverageName);
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ==================== Construction du texte des suppléments ====================
  String _buildSupplementsText() {
    String supplementsText = '';

    // Ajouter les suppléments
    if (widget.item['supplements'] != null && (widget.item['supplements'] as List).isNotEmpty) {
      List<String> supplementNames = (widget.item['supplements'] as List)
          .map((supp) {
        String originalName = supp['name'].toString();
        return translatedSupplements[originalName] ?? originalName;
      })
          .toList();
      supplementsText = '+${supplementNames.join(', ')}';
    }

    // Ajouter la boisson si elle existe
    if (widget.item['beverage'] != null) {
      if (supplementsText.isNotEmpty) {
        supplementsText += ', ';
      } else {
        supplementsText = '+';
      }
      supplementsText += translatedBeverageName.isNotEmpty
          ? translatedBeverageName
          : widget.item['beverage']['name'];
    }

    return supplementsText;
  }

  // ==================== Interface utilisateur ====================
  @override
  Widget build(BuildContext context) {
    final product = GlobalParams.getProductById(widget.item['productId']);
    final quantity = widget.item['quantity'] ?? 1;
    final totalPrice = widget.item['totalPrice'] * quantity;

    // Construire le texte des suppléments traduit
    String supplementsText = _buildSupplementsText();

    return Container(
      height: 109,
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
      child: Stack(
        children: [
          // Image du produit
          Positioned(
            left: 7,
            top: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product?['image'] ?? '',
                width: 92,
                height: 94,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 92,
                    height: 94,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  );
                },
              ),
            ),
          ),

          // Nom du produit
          Positioned(
            left: 112,
            top: 14,
            right: 50,
            child: Text(
              translatedProductName.isNotEmpty ? translatedProductName : widget.item['productName'],
              style: GoogleFonts.getFont(
                'Inter',
                color: const Color(0xFF3B2E1A),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Informations suppléments/boisson
          if (supplementsText.isNotEmpty)
            Positioned(
              left: 112,
              top: 34,
              right: 50,
              child: Text(
                supplementsText,
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xAD3B2E1A),
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Prix
          Positioned(
            left: 112,
            bottom: 14,
            child: Text(
              '${totalPrice.toStringAsFixed(3)} DT',
              style: GoogleFonts.getFont(
                'Inter',
                color: const Color(0xF23B2E1A),
                fontSize: 11,
              ),
            ),
          ),

          // Bouton de suppression (X)
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F3e7228c90c3c8d54a4ea423873cb5ff315849962close%201.png?alt=media&token=3998d988-e04f-4b4c-be7b-e9ba09926791',
                  width: 19,
                  height: 19,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Contrôles de quantité
          Positioned(
            right: 7,
            bottom: 14,
            child: Container(
              width: 69,
              height: 27,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton moins
                  GestureDetector(
                    onTap: () {
                      if (quantity > 1) {
                        widget.onQuantityChanged(quantity - 1);
                      } else {
                        widget.onRemove();
                      }
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fe920ce69068d67a356efc05b430b7d7a72ad6044minus-sign%20(1)%203.png?alt=media&token=f9ddab17-55c5-46b7-9ded-c21013576b0d',
                          width: 10,
                          height: 10,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Texte de quantité
                  Text(
                    quantity.toString(),
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0xF23B2E1A),
                      fontSize: 13,
                    ),
                  ),

                  // Bouton plus
                  GestureDetector(
                    onTap: () {
                      widget.onQuantityChanged(quantity + 1);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA2B84E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Ffb605069011fb4c90f1b1dcc7f3606bea8c2d32aplus%203.png?alt=media&token=50bc7861-7dae-4773-a7d9-c9f5cd559bef',
                          width: 11,
                          height: 11,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
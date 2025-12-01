import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/global_params.dart';

class ConsulterProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ConsulterProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  String _getSupplementsText() {
    String supplementsText = '';

    if (product['supplements'] != null &&
        (product['supplements'] as List).isNotEmpty) {
      List<String> suppNames = [];
      for (var supp in product['supplements']) {
        suppNames.add(supp['name'] ?? '');
      }
      supplementsText = '+${suppNames.join(', ')}';
    }

    return supplementsText;
  }

  Map<String, dynamic>? _getProductData() {
    // Get product data from GlobalParams using productId
    int? productId = product['productId'];
    if (productId != null) {
      return GlobalParams.getProductById(productId);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    int quantity = product['quantity'] ?? 1;
    double price = (product['price'] ?? 0.0).toDouble();
    String supplementsText = _getSupplementsText();

    // Get full product data from GlobalParams
    Map<String, dynamic>? productData = _getProductData();
    String? productImage = productData?['image'];
    String productName = product['name'] ?? productData?['name'] ?? 'Produit';

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
          // Product Image
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
                },
              )
                  : Container(
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
              ),
            ),
          ),

          // Product Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    productName,
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0xFF3B2E1A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  if (quantity > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Quantité: $quantity',
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

          // Price
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
}
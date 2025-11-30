import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/global_params.dart';

class CartItemCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final product = GlobalParams.getProductById(item['productId']);
    final quantity = item['quantity'] ?? 1;
    final totalPrice = item['totalPrice'] * quantity;

    // Build supplements text
    String supplementsText = '';
    if (item['supplements'] != null && (item['supplements'] as List).isNotEmpty) {
      List<String> supplementNames = (item['supplements'] as List)
          .map((supp) => supp['name'].toString())
          .toList();
      supplementsText = '+${supplementNames.join(', ')}';
    }

    // Add beverage if exists
    if (item['beverage'] != null) {
      if (supplementsText.isNotEmpty) {
        supplementsText += ', ';
      } else {
        supplementsText = '+';
      }
      supplementsText += item['beverage']['name'];
    }

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
          // Product image
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

          // Product name
          Positioned(
            left: 112,
            top: 14,
            right: 50,
            child: Text(
              item['productName'],
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

          // Supplements/Beverage info
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

          // Price
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

          // Remove button (X)
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: onRemove,
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

          // Quantity controls
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
                  // Minus button
                  GestureDetector(
                    onTap: () {
                      if (quantity > 1) {
                        onQuantityChanged(quantity - 1);
                      } else {
                        onRemove();
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

                  // Quantity text
                  Text(
                    quantity.toString(),
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0xF23B2E1A),
                      fontSize: 13,
                    ),
                  ),

                  // Plus button
                  GestureDetector(
                    onTap: () {
                      onQuantityChanged(quantity + 1);
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
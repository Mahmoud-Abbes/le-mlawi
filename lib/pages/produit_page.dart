import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/global_params.dart';

class ProduitPage extends StatefulWidget {
  final int productId;

  const ProduitPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProduitPageState createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  Set<int> selectedSupplements = {};
  int? selectedDrink;

  Future<void> _addToCart() async {
    final product = GlobalParams.getProductById(widget.productId);
    if (product == null) return;

    // Calculate total price
    double totalPrice = product['price'];

    // Prepare supplements list with prices
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

    // Add drink if selected
    Map<String, dynamic>? selectedBeverageData;
    if (selectedDrink != null) {
      selectedBeverageData = {
        'name': GlobalParams.beverages[selectedDrink!]['name'],
        'price': product['drinks'][0]['price'],
      };
      totalPrice += product['drinks'][0]['price'];
    }

    // Create cart item object
    Map<String, dynamic> cartItem = {
      'productId': widget.productId,
      'productName': product['name'],
      'productPrice': product['price'],
      'supplements': supplementsList,
      'beverage': selectedBeverageData,
      'quantity': 1,
      'totalPrice': totalPrice,
    };

    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Get existing cart or create new one
    String? cartString = prefs.getString('cart');
    List<dynamic> cart = [];

    if (cartString != null) {
      cart = json.decode(cartString);
    }

    // Add new item to cart
    cart.add(cartItem);

    // Save updated cart
    await prefs.setString('cart', json.encode(cart));

    // Calculate and save cart total
    double cartTotal = 0;
    for (var item in cart) {
      cartTotal += item['totalPrice'] * item['quantity'];
    }
    await prefs.setDouble('cartTotal', cartTotal);

    // Show success message
    if (mounted) {
      String supplementsInfo = '';
      if (supplementsList.isNotEmpty) {
        List supplementNames = supplementsList.map((s) => s['name']).toList();
        supplementsInfo = '\nSuppléments: ${supplementNames.join(", ")}';
      }

      String drinkInfo = '';
      if (selectedBeverageData != null) {
        drinkInfo = '\nBoisson: ${selectedBeverageData['name']}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ajouté au panier$supplementsInfo$drinkInfo\nTotal: ${totalPrice.toStringAsFixed(3)} DT',
          ),
          backgroundColor: const Color(0xFFA2B84E),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to cart page after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushNamed(context, '/panier');
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = GlobalParams.getProductById(widget.productId);

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Text('Produit non trouvé'),
        ),
      );
    }

    double totalPrice = product['price'];

    // Add supplement prices
    if (product['supplements'] != null) {
      for (int index in selectedSupplements) {
        totalPrice += product['supplements'][index]['price'];
      }
    }

    // Add drink price
    if (selectedDrink != null && product['drinks'] != null) {
      totalPrice += product['drinks'][0]['price'];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Product image header
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.network(
                      product['image'],
                      width: double.infinity,
                      height: 380,
                      fit: BoxFit.cover,
                    ),

                    // Back button
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

                    // Product name badge
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
                            product['name'],
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

                    // White content container overlaying image
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
                            Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fa6943a88fa2656b3ab80b60e5dcb2e67acdf33c2motorcycle%20(1)%201.png?alt=media&token=e629c188-48f5-46bd-9bf0-8b59251bca4c',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product['deliveryFee'],
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xFFED9D49),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 25),
                            Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fbf30ecae59637b455384798e5ada459fbaf3dac3clock%201.png?alt=media&token=c08616cf-6bdd-4dcc-83b3-dacb8e725402',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product['deliveryTime'],
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

                // White content container continues
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product details section
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product name
                            Text(
                              product['name'],
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xFF3B2E1A),
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Price
                            Text(
                              '${product['price'].toStringAsFixed(3)} DT',
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
                              product['description'],
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xCC3B2E1A),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Supplements section
                            if (product['supplements'] != null) ...[
                              Text(
                                'Voulez-vous des suppléments ?',
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
                                  product['supplements'][index]['name'],
                                  '+${product['supplements'][index]['price'].toStringAsFixed(3)} DT',
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

                            // Drinks section
                            if (product['drinks'] != null) ...[
                              Text(
                                'Quelque chose à boire ?',
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: const Color(0xFF3B2E1A),
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                product['drinks'][0]['name'],
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: const Color(0xCC3B2E1A),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Beverage options
                              SizedBox(
                                height: 200,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    GlobalParams.beverages.length,
                                        (index) => _buildBeverageOption(
                                      GlobalParams.beverages[index]['name'],
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

          // Add to cart button (fixed at bottom)
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
                  'Ajouter au Panier',
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
                // Container background positioned at bottom
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
                // Image starting from center of container and overflowing upward
                Positioned(
                  bottom: 35,
                  child: Image.network(
                    imageUrl,
                    width: 110,
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                ),
                // Plus/Check button at bottom center - half inside, half outside
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
          // Beverage name
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
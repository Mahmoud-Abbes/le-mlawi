import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/cart_item_card.dart';

class PanierPage extends StatefulWidget {
  const PanierPage({Key? key}) : super(key: key);

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  List<Map<String, dynamic>> cartItems = [];
  double totalProducts = 0.0;
  bool isLoading = true;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

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

  void _calculateTotal() {
    totalProducts = 0.0;
    for (var item in cartItems) {
      totalProducts += item['totalPrice'] * item['quantity'];
    }
  }

  Future<void> _updateCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(cartItems));
    await prefs.setDouble('cartTotal', totalProducts);
  }

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

  Future<void> _removeItem(int index) async {
    setState(() {
      cartItems.removeAt(index);
      _calculateTotal();
    });
    await _updateCart();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produit retiré du panier'),
        backgroundColor: const Color(0xFFD48C41),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _generateUniqueId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _placeOrder() async {
    if (cartItems.isEmpty) return;

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // Get user email from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail == null || userEmail.isEmpty) {
        throw Exception('User email not found. Please login again.');
      }

      final commandeId = 'CMD-${_generateUniqueId()}';

      // Get store name from first cart item
      String storeName = cartItems.isNotEmpty
          ? (cartItems[0]['storeName'] ?? 'BestMlawi')
          : 'BestMlawi';

      // Prepare products data using the exact cart item structure
      List<Map<String, dynamic>> products = cartItems.map((item) {
        return {
          'productId': item['productId'] ?? item['id'] ?? 0,
          'name': item['productName'] ?? '',
          'quantity': item['quantity'] ?? 1,
          'price': item['totalPrice'] ?? 0.0,
          'supplements': item['supplements'] ?? [],
        };
      }).toList();

      // Create order document with userEmail
      await FirebaseFirestore.instance.collection('commandes').doc(commandeId).set({
        'commandeId': commandeId,
        'userEmail': userEmail,  // Store user email
        'storeName': storeName,
        'products': products,
        'totalPrice': totalProducts,
        'etatCommande': 'En cours de traitement',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear cart after successful order
      await prefs.remove('cart');
      await prefs.remove('cartTotal');

      setState(() {
        isPlacingOrder = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Commande passée avec succès!'),
          backgroundColor: const Color(0xFFA2B84E),
        ),
      );

      // Navigate to commandes page
      Navigator.pushReplacementNamed(context, '/commandes');
    } catch (e) {
      setState(() {
        isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la commande: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
            // Header
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
                'Ton Panier',
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xFF3B2E1A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),

            // Cart Items List
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
                        'Votre panier est vide',
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

            // Bottom section with order info
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
                    // Ripped paper effect - triangles
                    Positioned(
                      left: 0,
                      right: 0,
                      top: -5,
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 5),
                        painter: RippedPaperPainter(),
                      ),
                    ),

                    // Main container for all information elements
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 30,
                      child: Container(
                        child: Column(
                          children: [
                            // Order information
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Information sur la commande',
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

                            // Total Products
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 29),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Produits',
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

                            // Delivery
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 29),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Livraison',
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Gratuit',
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

                            // Divider line
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
                                    'Total',
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

                            // Place Order Button
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
                                      'Placer commande',
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

// Custom painter for ripped paper effect
class RippedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFEDC1)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from left
    path.moveTo(0, size.height);

    // Create zigzag pattern (triangles)
    double triangleWidth = 12;
    double triangleHeight = size.height;

    for (double x = 0; x < size.width; x += triangleWidth) {
      path.lineTo(x + triangleWidth / 2, 0);
      path.lineTo(x + triangleWidth, size.height);
    }

    // Complete the path
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
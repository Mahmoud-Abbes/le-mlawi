import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/consulter_product_card.dart';
import 'dart:math';

class EtatCommandePage extends StatefulWidget {
  final String orderId;

  const EtatCommandePage({Key? key, required this.orderId}) : super(key: key);

  @override
  _EtatCommandePageState createState() => _EtatCommandePageState();
}

class _EtatCommandePageState extends State<EtatCommandePage> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('commandes')
          .where('commandeId', isEqualTo: widget.orderId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          orderData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          orderData!['docId'] = querySnapshot.docs.first.id;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading order: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    try {
      String docId = orderData!['docId'];
      await FirebaseFirestore.instance
          .collection('commandes')
          .doc(docId)
          .update({
        'etatCommande': 'Annulée',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        orderData!['etatCommande'] = 'Annulée';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande annulée avec succès'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error cancelling order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _getStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'en cours de traitement':
      case 'en cours':
      case 'confirmée':
        return 0;
      case 'en préparation':
        return 1;
      case 'prête':
      case 'prête pour livraison':
        return 2;
      case 'en livraison':
      case 'en cours de livraison':
        return 3;
      case 'livré':
      case 'livrée':
      case 'livrée avec succès':
        return 4;
      default:
        return 0;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return 'En cours de traitement';
      case 'en préparation':
        return 'En préparation';
      case 'prête':
        return 'Prête pour livraison';
      case 'en livraison':
        return 'En cours de livraison';
      case 'livrée':
        return 'Livrée avec succès';
      case 'annulée':
        return 'Annulée';
      default:
        return status;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      try {
        date = DateTime.parse(timestamp);
      } catch (e) {
        return timestamp;
      }
    } else {
      return '';
    }

    return '${date.month}/${date.day}/${date.year}';
  }

  bool _canCancelOrder(String status) {
    String lowerStatus = status.toLowerCase();
    return lowerStatus.contains('en cours') ||
        lowerStatus.contains('en préparation') ||
        lowerStatus.contains('prête');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8EC),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFD48C41),
          ),
        ),
      );
    }

    if (orderData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8EC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Commande introuvable',
                style: GoogleFonts.getFont(
                  'Inter',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    String status = orderData!['etatCommande'] ?? 'En cours';
    int currentStep = _getStatusStep(status);
    List<dynamic> products = orderData!['products'] ?? [];
    bool isCancelled = status.toLowerCase() == 'annulé' || status.toLowerCase() == 'annulée';
    bool isDelivered = status.toLowerCase().contains('livré');
    bool canCancel = _canCancelOrder(status);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: 402,
        height: 874,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 402,
                  height: 874,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8EC),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Back button
                      Positioned(
                        left: 15,
                        top: 31,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 26,
                        top: 42,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Transform.rotate(
                            angle: 180 * pi / 180,
                            child: Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F33a3bbb97c5a949d4419852f6eb37cf8e75609ebimage%2021.png?alt=media&token=8c9d9dd4-0a40-407f-8eb9-f031b954ba6e',
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Title
                      Positioned(
                        left: 24,
                        top: 89,
                        child: Text(
                          'Statut de livraison',
                          style: GoogleFonts.getFont(
                            'Inter',
                            color: const Color(0xFF3B2E1A),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Status labels
                      if (!isCancelled) ...[
                        Positioned(
                          left: 19,
                          top: 174,
                          child: SizedBox(
                            width: 59,
                            height: 19,
                            child: Text(
                              'En cours',
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: currentStep >= 0 ? Colors.black : const Color(0xFF878787),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 132,
                          top: 174,
                          child: SizedBox(
                            width: 37,
                            height: 19,
                            child: Text(
                              'Prête',
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: currentStep >= 2 ? Colors.black : const Color(0xFF878787),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 214,
                          top: 174,
                          child: SizedBox(
                            width: 77,
                            height: 19,
                            child: Text(
                              'En livraison',
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: currentStep >= 3 ? Colors.black : const Color(0xFF878787),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 346,
                          top: 174,
                          child: SizedBox(
                            width: 35,
                            height: 19,
                            child: Text(
                              'Livré',
                              style: GoogleFonts.getFont(
                                'Inter',
                                color: currentStep >= 4 ? Colors.black : const Color(0xFF878787),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        // Progress bar container
                        Positioned(
                          left: 26,
                          top: 204,
                          child: Container(
                            width: 354,
                            height: 33,
                            child: Stack(
                              children: [
                                // Progress lines
                                // Line 1: From Step 0 to Step 2
                                Positioned(
                                  left: 33, // Start after first circle (33px width)
                                  top: 16, // Center vertically
                                  child: Container(
                                    width: 74, // Adjusted width to maintain spacing
                                    height: 4,
                                    color: currentStep > 0 ? const Color(0xFFE3B664) : const Color(0xFFE4E4E4),
                                  ),
                                ),
                                // Line 2: From Step 2 to Step 3
                                Positioned(
                                  left: 140, // Start after second circle + spacing
                                  top: 16,
                                  child: Container(
                                    width: 74, // Adjusted width
                                    height: 4,
                                    color: currentStep > 2 ? const Color(0xFFE3B664) : const Color(0xFFE4E4E4),
                                  ),
                                ),
                                // Line 3: From Step 3 to Step 4
                                Positioned(
                                  left: 247, // Start after third circle + spacing
                                  top: 16,
                                  child: Container(
                                    width: 74, // Adjusted width
                                    height: 4,
                                    color: currentStep > 3 ? const Color(0xFFE3B664) : const Color(0xFFE4E4E4),
                                  ),
                                ),

                                // Step 0 - En cours
                                if (currentStep == 0)
                                // Current step - small orange circle
                                  Positioned(
                                    left: 6.5, // Center in the 33px container (33-20)/2 = 6.5
                                    top: 6.5,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3B664),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                else if (currentStep > 0)
                                // Done step - big orange circle with checkmark
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: 33,
                                      height: 33,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3B664),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: Center(
                                        child: Image.network(
                                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2F070fd70f-f69f-4a9d-ba62-8f638a445402.png',
                                          width: 16,
                                          height: 11,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                // Undone step - big gray circle
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: 33,
                                      height: 33,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                          width: 3,
                                          color: const Color(0xFFE4E4E4),
                                        ),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                    ),
                                  ),

                                // Step 2 - Prête
                                if (currentStep == 2)
                                // Current step - small orange circle
                                  Positioned(
                                    left: 113.5, // 107 + 6.5
                                    top: 6.5,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3B664),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                else if (currentStep > 2)
                                // Done step - big orange circle with checkmark
                                  Positioned(
                                    left: 107,
                                    top: 0,
                                    child: Container(
                                      width: 33,
                                      height: 33,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3B664),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: Center(
                                        child: Image.network(
                                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2Ff88e2924-d76f-4530-a4f8-31a03e6c6936.png',
                                          width: 16,
                                          height: 11,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                // Undone step - big gray circle
                                  Positioned(
                                    left: 107,
                                    top: 0,
                                    child: Container(
                                      width: 33,
                                      height: 33,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                          width: 3,
                                          color: const Color(0xFFE4E4E4),
                                        ),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                    ),
                                  ),

                                // Step 3 - En livraison
                                if (currentStep == 3)
                                // Current step - small orange circle
                                  Positioned(
                                    left: 220.5, // 214 + 6.5 (corrected alignment)
                                    top: 6.5, // Centered vertically
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3B664),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                else if (currentStep > 3)
                                // Done step - big orange circle with checkmark
                                  Positioned(
                                    left: 214, // Corrected alignment
                                    top: 0,
                                    child: Container(
                                      width: 33,
                                      height: 33,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3B664),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: Center(
                                        child: Image.network(
                                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2Ff88e2924-d76f-4530-a4f8-31a03e6c6936.png',
                                          width: 16,
                                          height: 11,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                // Undone step - big gray circle
                                  Positioned(
                                    left: 214, // Corrected alignment
                                    top: 0,
                                    child: Container(
                                      width: 33,
                                      height: 33,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                          width: 3,
                                          color: const Color(0xFFE4E4E4),
                                        ),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                    ),
                                  ),

                                // Step 4 - Livré
                                if (currentStep == 4 && !isDelivered)
                                // Current step - small orange circle (only if not delivered)
                                  Positioned(
                                    left: 327.5, // 321 + 6.5
                                    top: 6.5,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3B664),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                else if (isDelivered || currentStep > 4)
                                // Done step - big orange circle with checkmark (when delivered)
                                  Positioned(
                                    left: 321,
                                    top: 0,
                                    child: Container(
                                      width: 33,
                                      height: 33,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3B664),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: Center(
                                        child: Image.network(
                                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2Ff88e2924-d76f-4530-a4f8-31a03e6c6936.png',
                                          width: 16,
                                          height: 11,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                // Undone step - big gray circle
                                  Positioned(
                                    left: 321,
                                    top: 0,
                                    child: Container(
                                      width: 33,
                                      height: 33,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                          width: 3,
                                          color: const Color(0xFFE4E4E4),
                                        ),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Cancelled message
                      if (isCancelled)
                        Positioned(
                          left: 26,
                          top: 174,
                          child: Container(
                            width: 349,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.red.shade200, width: 2),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red, size: 40),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Cette commande a été annulée',
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: Colors.red.shade700,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Status text and date
                      Positioned(
                        left: 19,
                        top: 286,
                        child: Text(
                          _getStatusText(status),
                          style: GoogleFonts.getFont(
                            'Inter',
                            color: isCancelled ? Colors.red : const Color(0xFF959595),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 299,
                        top: 286,
                        child: Text(
                          _formatDate(orderData!['createdAt']),
                          style: GoogleFonts.getFont(
                            'Inter',
                            color: const Color(0xFF959595),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Divider
                      Positioned(
                        left: 15,
                        top: 329,
                        child: Container(
                          width: 372,
                          height: 2,
                          color: const Color(0xFFE4E4E4),
                        ),
                      ),

                      // Products header
                      Positioned(
                        left: 31,
                        top: 359,
                        child: Text(
                          'Produits',
                          style: GoogleFonts.getFont(
                            'Inter',
                            color: const Color(0xFF3B2E1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 289,
                        top: 361,
                        child: Text(
                          widget.orderId,
                          style: GoogleFonts.getFont(
                            'Inter',
                            color: const Color(0xFF3B2E1A),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Products list
                      Positioned(
                        left: 26,
                        top: 399,
                        child: SizedBox(
                          height: 380,
                          width: 349,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: index < products.length - 1 ? 8 : 0),
                                child: ConsulterProductCard(
                                  product: products[index],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Cancel button - show for all states but with different appearance
                      Positioned(
                        left: 45,
                        top: 720,
                        child: Container(
                          width: 312,
                          height: 54,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              width: 3,
                              color: canCancel ? const Color(0xFFE3B664) : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: canCancel
                                  ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Annuler la commande',
                                      style: GoogleFonts.getFont('Inter'),
                                    ),
                                    content: Text(
                                      'Êtes-vous sûr de vouloir annuler cette commande?',
                                      style: GoogleFonts.getFont('Inter'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Non',
                                          style: GoogleFonts.getFont('Inter'),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _cancelOrder();
                                        },
                                        child: Text(
                                          'Oui',
                                          style: GoogleFonts.getFont(
                                            'Inter',
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                                  : null,
                              child: Text(
                                'Annuler commande',
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: canCancel ? const Color(0xFFE3B664) : Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
        ),
      ),
    );
  }
}
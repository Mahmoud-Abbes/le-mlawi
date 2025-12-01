import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/consulter_product_card.dart';
import '../config/translation_config.dart';
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

  // ============================================================================
  // TRADUCTIONS
  // ============================================================================
  Map<String, String> translations = {};
  bool isLoadingTranslations = true;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _loadOrderData();
  }

  Future<void> _loadTranslations() async {
    final keys = [
      'Commande annulée avec succès',
      'Erreur',
      'Commande introuvable',
      'Statut de livraison',
      'En cours',
      'Prête',
      'En livraison',
      'Livré',
      'Cette commande a été annulée',
      'En cours de traitement',
      'En préparation',
      'Prête pour livraison',
      'En cours de livraison',
      'Livrée avec succès',
      'Annulée',
      'Produits',
      'Annuler commande',
      'Annuler la commande',
      'Êtes-vous sûr de vouloir annuler cette commande?',
      'Non',
      'Oui',
    ];

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
  // CHARGEMENT DES DONNÉES
  // ============================================================================
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

  // ============================================================================
  // ANNULATION DE COMMANDE
  // ============================================================================
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
          SnackBar(
            content: Text(translations['Commande annulée avec succès'] ??
                'Commande annulée avec succès'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error cancelling order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${translations['Erreur'] ?? 'Erreur'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ============================================================================
  // UTILITAIRES DE STATUT
  // ============================================================================
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
        return translations['En cours de traitement'] ?? 'En cours de traitement';
      case 'en préparation':
        return translations['En préparation'] ?? 'En préparation';
      case 'prête':
        return translations['Prête pour livraison'] ?? 'Prête pour livraison';
      case 'en livraison':
        return translations['En cours de livraison'] ?? 'En cours de livraison';
      case 'livrée':
        return translations['Livrée avec succès'] ?? 'Livrée avec succès';
      case 'annulée':
        return translations['Annulée'] ?? 'Annulée';
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

  // ============================================================================
  // INTERFACE UTILISATEUR
  // ============================================================================
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
                translations['Commande introuvable'] ??
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
    bool isCancelled =
        status.toLowerCase() == 'annulé' || status.toLowerCase() == 'annulée';
    bool canCancel = _canCancelOrder(status);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: 874,
        child: Stack(
          children: [
            Container(
              width: 402,
              height: 874,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EC),
                borderRadius: BorderRadius.circular(27),
              ),
            ),

            // Retour
            Positioned(
              left: 15,
              top: 31,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
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
                  ),
                ),
              ),
            ),

            // Titre
            Positioned(
              left: 24,
              top: 89,
              child: Text(
                translations['Statut de livraison'] ??
                    'Statut de livraison',
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xFF3B2E1A),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // If not cancelled, show steps
            if (!isCancelled) ...[
              // Labels
              Positioned(
                left: 19,
                top: 174,
                child: Text(
                  translations['En cours'] ?? 'En cours',
                  style: GoogleFonts.getFont(
                    'Inter',
                    color: currentStep >= 0
                        ? Colors.black
                        : const Color(0xFF878787),
                    fontSize: 13,
                  ),
                ),
              ),

              Positioned(
                left: 132,
                top: 174,
                child: Text(
                  translations['Prête'] ?? 'Prête',
                  style: GoogleFonts.getFont(
                    'Inter',
                    color: currentStep >= 2
                        ? Colors.black
                        : const Color(0xFF878787),
                    fontSize: 13,
                  ),
                ),
              ),

              Positioned(
                left: 214,
                top: 174,
                child: Text(
                  translations['En livraison'] ?? 'En livraison',
                  style: GoogleFonts.getFont(
                    'Inter',
                    color: currentStep >= 3
                        ? Colors.black
                        : const Color(0xFF878787),
                    fontSize: 13,
                  ),
                ),
              ),

              Positioned(
                left: 346,
                top: 174,
                child: Text(
                  translations['Livré'] ?? 'Livré',
                  style: GoogleFonts.getFont(
                    'Inter',
                    color: currentStep >= 4
                        ? Colors.black
                        : const Color(0xFF878787),
                    fontSize: 13,
                  ),
                ),
              ),

              // Progress bar
              Positioned(
                left: 26,
                top: 204,
                child: SizedBox(
                  width: 354,
                  height: 33,
                  child: Stack(
                    children: [
                      // Lines
                      Positioned(
                        left: 33,
                        top: 16,
                        child: Container(
                          width: 74,
                          height: 4,
                          color: currentStep > 0
                              ? const Color(0xFFE3B664)
                              : const Color(0xFFE4E4E4),
                        ),
                      ),
                      Positioned(
                        left: 140,
                        top: 16,
                        child: Container(
                          width: 74,
                          height: 4,
                          color: currentStep > 2
                              ? const Color(0xFFE3B664)
                              : const Color(0xFFE4E4E4),
                        ),
                      ),
                      Positioned(
                        left: 247,
                        top: 16,
                        child: Container(
                          width: 74,
                          height: 4,
                          color: currentStep > 3
                              ? const Color(0xFFE3B664)
                              : const Color(0xFFE4E4E4),
                        ),
                      ),

                      // Step 0
                      if (currentStep == 0)
                        Positioned(
                          left: 6.5,
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
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 33,
                            height: 33,
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
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
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
                        Positioned(
                          left: 113.5,
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
                        Positioned(
                          left: 107,
                          top: 0,
                          child: Container(
                            width: 33,
                            height: 33,
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
                        Positioned(
                          left: 107,
                          top: 0,
                          child: Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
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
                        Positioned(
                          left: 220.5,
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
                      else if (currentStep > 3)
                        Positioned(
                          left: 214,
                          top: 0,
                          child: Container(
                            width: 33,
                            height: 33,
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
                        Positioned(
                          left: 214,
                          top: 0,
                          child: Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3,
                                color: const Color(0xFFE4E4E4),
                              ),
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),

                      // Étape 4 - Livré
                      if (currentStep == 4)
                        Positioned(
                          left: 314,
                          top: 0,
                          child: Container(
                            width: 33,
                            height: 33,
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
                        Positioned(
                          left: 317,
                          top: 0,
                          child: Container(
                            width: 33,
                            height: 33,
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

            // Cancelled warning
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
                          translations['Cette commande a été annulée'] ??
                              'Cette commande a été annulée',
                          style: GoogleFonts.inter(
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

            // Status text + date
            Positioned(
              left: 19,
              top: 286,
              child: Text(
                _getStatusText(status),
                style: GoogleFonts.inter(
                  color: isCancelled
                      ? Colors.red
                      : const Color(0xFF959595),
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
                style: GoogleFonts.inter(
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

            // Products title
            Positioned(
              left: 31,
              top: 359,
              child: Text(
                translations['Produits'] ?? 'Produits',
                style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
                  color: const Color(0xFF3B2E1A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Product list
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
                      padding: EdgeInsets.only(
                          bottom: index < products.length - 1 ? 8 : 0),
                      child: ConsulterProductCard(product: products[index]),
                    );
                  },
                ),
              ),
            ),

            // Cancel order button
            if (!isCancelled)
              Positioned(
                left: 45,
                top: 720,
                child: Container(
                  width: 312,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      width: 3,
                      color: canCancel
                          ? const Color(0xFFE3B664)
                          : Colors.grey,
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
                                translations['Annuler la commande'] ??
                                    'Annuler la commande',
                                style: GoogleFonts.inter()),
                            content: Text(
                                translations['Êtes-vous sûr de vouloir annuler cette commande?'] ??
                                    'Êtes-vous sûr de vouloir annuler cette commande?',
                                style: GoogleFonts.inter()),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                child: Text(
                                    translations['Non'] ?? 'Non',
                                    style: GoogleFonts.inter()),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _cancelOrder();
                                },
                                child: Text(
                                  translations['Oui'] ?? 'Oui',
                                  style: GoogleFonts.inter(
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                          : null,
                      child: Text(
                        translations['Annuler commande'] ??
                            'Annuler commande',
                        style: GoogleFonts.inter(
                          color: canCancel
                              ? const Color(0xFFE3B664)
                              : Colors.grey,
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
    );
  }
}

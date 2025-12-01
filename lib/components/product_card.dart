import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/translation_config.dart';

class ProductCard extends StatefulWidget {
  final String name;
  final double price;
  final String description;
  final String image;
  final double rating;
  final String deliveryTime;
  final String deliveryFee;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;

  const ProductCard({
    Key? key,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    this.onTap,
    this.onFavoritePressed,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // ==================== Variables pour les traductions ====================
  String translatedName = '';
  String translatedDescription = '';
  String translatedDeliveryFee = '';
  String translatedDeliveryTime = '';

  // ==================== Initialisation ====================
  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  // ==================== Mise à jour lors du changement de widget ====================
  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name ||
        oldWidget.description != widget.description ||
        oldWidget.deliveryFee != widget.deliveryFee ||
        oldWidget.deliveryTime != widget.deliveryTime) {
      _loadTranslations();
    }
  }

  // ==================== Chargement des traductions ====================
  Future<void> _loadTranslations() async {
    translatedName = await translate(widget.name);
    translatedDescription = await translate(widget.description);
    translatedDeliveryFee = await translate(widget.deliveryFee);
    translatedDeliveryTime = await translate(widget.deliveryTime);

    if (mounted) {
      setState(() {});
    }
  }

  // ==================== Interface utilisateur ====================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 339,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec bouton favori
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Image.network(
                    widget.image,
                    width: 339,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 7,
                  top: 90,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFCFFFFFF),
                      border: Border.all(
                        width: 1.1,
                        color: const Color(0x38000000),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F37fa2cae0be365c7e074af510059b07d0f2c42cfimage%2017.png?alt=media&token=75017c73-6c3e-4841-8d5c-c7c929c31055',
                        width: 14,
                        height: 14,
                        fit: BoxFit.cover,
                      ),
                      onPressed: widget.onFavoritePressed,
                    ),
                  ),
                ),
              ],
            ),

            // Détails du produit
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et prix du produit
                  Text(
                    '${translatedName.isNotEmpty ? translatedName : widget.name} - ${widget.price.toStringAsFixed(3)} DT',
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    translatedDescription.isNotEmpty ? translatedDescription : widget.description,
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0x5B000000),
                      fontSize: 11,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Note, informations de livraison
                  Row(
                    children: [
                      // Note
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F3889c445363a2e27f3fcec92b6bff0902f1c308bstar%201.png?alt=media&token=56d4e070-50c9-45ab-b8b9-9c0acfb31bb1',
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.rating.toString(),
                        style: GoogleFonts.getFont(
                          'Inter',
                          color: const Color(0xFFED9D49),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 28),

                      // Icône de livraison et frais
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fa6943a88fa2656b3ab80b60e5dcb2e67acdf33c2motorcycle%20(1)%201.png?alt=media&token=ce38f61d-9f38-4c8a-b0d1-7ac60b9ad9a4',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        translatedDeliveryFee.isNotEmpty ? translatedDeliveryFee : widget.deliveryFee,
                        style: GoogleFonts.getFont(
                          'Inter',
                          color: const Color(0xFFED9D49),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 28),

                      // Icône d'horloge et temps de livraison
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fbf30ecae59637b455384798e5ada459fbaf3dac3clock%201.png?alt=media&token=55f21aba-57c9-4572-86be-23fcbd35df08',
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        translatedDeliveryTime.isNotEmpty ? translatedDeliveryTime : widget.deliveryTime,
                        style: GoogleFonts.getFont(
                          'Inter',
                          color: const Color(0xFFED9D49),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
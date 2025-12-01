import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/translation_config.dart';

class PanierCard extends StatefulWidget {
  final String storeName;
  final String deliveryInfo;
  final String totalPrice;
  final int itemCount;
  final VoidCallback onTap;

  const PanierCard({
    Key? key,
    required this.storeName,
    required this.deliveryInfo,
    required this.totalPrice,
    required this.itemCount,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PanierCard> createState() => _PanierCardState();
}

class _PanierCardState extends State<PanierCard> {
  // ==================== Variables pour les traductions ====================
  String translatedDeliveryInfo = '';
  String translatedArticle = 'article';
  String translatedArticles = 'articles';

  // ==================== Initialisation ====================
  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  // ==================== Chargement des traductions ====================
  Future<void> _loadTranslations() async {
    translatedDeliveryInfo = await translate(widget.deliveryInfo);
    translatedArticle = await translate('article');
    translatedArticles = await translate('articles');

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
        child: Stack(
          children: [
            // Logo/icône du magasin
            Positioned(
              left: 10,
              top: 12,
              child: Container(
                width: 85,
                height: 85,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD48C41), Color(0xFFFFC282)],
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.storeName.isNotEmpty ? widget.storeName[0].toUpperCase() : 'B',
                    style: GoogleFonts.getFont(
                      'Lobster',
                      color: Colors.white,
                      fontSize: 42,
                    ),
                  ),
                ),
              ),
            ),
            // Nom du magasin
            Positioned(
              left: 112,
              top: 14,
              child: Text(
                widget.storeName,
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xFF3B2E1A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Informations de livraison avec icône
            Positioned(
              left: 112,
              top: 38,
              child: Row(
                children: [
                  Image.network(
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2Fe433d5fb-4915-4a11-96f1-352c2190d58d.png',
                    width: 18,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    translatedDeliveryInfo.isNotEmpty ? translatedDeliveryInfo : widget.deliveryInfo,
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0xFF6C6C6C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.totalPrice,
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0xFF6C6C6C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Nombre d'articles
            Positioned(
              left: 112,
              top: 70,
              child: Text(
                '${widget.itemCount} ${widget.itemCount > 1 ? translatedArticles : translatedArticle}',
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xFFA1A1A1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Icône flèche
            Positioned(
              right: 17,
              top: 38,
              child: Image.network(
                'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2F0389bd65-dfeb-4547-9fb4-8bc250b5bf4a.png',
                width: 17,
                height: 33,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
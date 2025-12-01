import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/translation_config.dart';

class CommandeEnCoursCard extends StatefulWidget {
  final String commandeId;
  final String storeName;
  final String status;
  final VoidCallback onTap;

  const CommandeEnCoursCard({
    Key? key,
    required this.commandeId,
    required this.storeName,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CommandeEnCoursCard> createState() => _CommandeEnCoursCardState();
}

class _CommandeEnCoursCardState extends State<CommandeEnCoursCard> {
  // ==================== Variables pour les traductions ====================
  String translatedVoirProcessus = 'Voir processus du commande →';
  String translatedStatus = '';

  // ==================== Initialisation ====================
  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  // ==================== Chargement des traductions ====================
  Future<void> _loadTranslations() async {
    translatedVoirProcessus = await translate('Voir processus du commande →');
    translatedStatus = await translate(widget.status);

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
              left: 12,
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
            // Informations de la commande
            Positioned(
              left: 112,
              top: 16,
              child: Text(
                '${widget.commandeId} - ${widget.storeName}',
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xFF3B2E1A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Statut de la commande
            Positioned(
              left: 112,
              top: 36,
              child: Text(
                translatedStatus.isNotEmpty ? translatedStatus : widget.status,
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xAD3B2E1A),
                  fontSize: 12,
                ),
              ),
            ),
            // Lien vers le processus
            Positioned(
              left: 112,
              top: 72,
              child: Text(
                translatedVoirProcessus,
                style: GoogleFonts.getFont(
                  'Inter',
                  color: const Color(0xFFBF8020),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
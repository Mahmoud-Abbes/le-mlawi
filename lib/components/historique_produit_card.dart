import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/translation_config.dart';

class HistoriqueProduitCard extends StatefulWidget {
  final String commandeId;
  final String storeName;
  final String status;
  final Timestamp? createdAt;
  final VoidCallback onTap;

  const HistoriqueProduitCard({
    Key? key,
    required this.commandeId,
    required this.storeName,
    required this.status,
    this.createdAt,
    required this.onTap,
  }) : super(key: key);

  @override
  State<HistoriqueProduitCard> createState() => _HistoriqueProduitCardState();
}

class _HistoriqueProduitCardState extends State<HistoriqueProduitCard> {
  // ==================== Variables pour les traductions ====================
  String translatedStatus = '';
  String translatedDateInconnue = 'Date inconnue';
  String translatedAujourdhui = 'Aujourd\'hui';
  String translatedHier = 'Hier';
  String translatedA = 'à';

  // ==================== Initialisation ====================
  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  // ==================== Chargement des traductions ====================
  Future<void> _loadTranslations() async {
    translatedStatus = await translate(widget.status);
    translatedDateInconnue = await translate('Date inconnue');
    translatedAujourdhui = await translate('Aujourd\'hui');
    translatedHier = await translate('Hier');
    translatedA = await translate('à');

    if (mounted) {
      setState(() {});
    }
  }

  // ==================== Formatage de la date ====================
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return translatedDateInconnue;

    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (orderDate == today) {
      return '$translatedAujourdhui $translatedA $timeStr';
    } else if (orderDate == today.subtract(const Duration(days: 1))) {
      return '$translatedHier $translatedA $timeStr';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} $translatedA $timeStr';
    }
  }

  // ==================== Obtention de la couleur du statut ====================
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'livrée':
      case 'livré':
        return const Color(0xFFA2B84E); // Vert
      case 'annulée':
      case 'annulé':
        return Colors.red; // Rouge
      case 'en cours de livraison':
      case 'en livraison':
        return const Color(0xFFE3B664); // Orange
      case 'prête':
      case 'en préparation':
        return const Color(0xFFD48C41); // Orange foncé
      default:
        return const Color(0xFF959595); // Gris
    }
  }

  // ==================== Interface utilisateur ====================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
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
                'CMD: ${widget.commandeId}',
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  translatedStatus.isNotEmpty ? translatedStatus : widget.status,
                  style: GoogleFonts.getFont(
                    'Inter',
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Date de la commande
            Positioned(
              left: 112,
              top: 72,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: const Color(0xFF3B2E1A).withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(widget.createdAt),
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0xAD3B2E1A),
                      fontSize: 11,
                    ),
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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommandeCard extends StatelessWidget {
  final String orderId;
  final String items;
  final String status;
  final String time;
  final Function(String) onStatusChanged;

  const CommandeCard({
    Key? key,
    required this.orderId,
    required this.items,
    required this.status,
    required this.time,
    required this.onStatusChanged,
  }) : super(key: key);

  Map<String, Color> getStatusColor(String status) {
    switch (status) {
      case 'En cours':
        return {
          'bg': const Color(0xFFE3F2FD),
          'text': const Color(0xFF1976D2),
        };
      case 'Prête':
        return {
          'bg': const Color(0xFFFFF9C4),
          'text': const Color(0xFFF57F17),
        };
      case 'En livraison':
        return {
          'bg': const Color(0xFFE1BEE7),
          'text': const Color(0xFF7B1FA2),
        };
      case 'Livrée':
        return {
          'bg': const Color(0xFFE8F5E9),
          'text': const Color(0xFF2E7D32),
        };
      case 'Annulée':
        return {
          'bg': const Color(0xFFEEEEEE),
          'text': const Color(0xFF757575),
        };
      default:
        return {
          'bg': const Color(0xFFE0E0E0),
          'text': const Color(0xFF616161),
        };
    }
  }

  bool isStatusLocked(String status) {
    return status == 'Livrée' || status == 'Annulée';
  }

  IconData getStatusIcon(String status) {
    if (status == 'Livrée') {
      return Icons.check_circle;
    } else if (status == 'Annulée') {
      return Icons.cancel;
    }
    return Icons.lock;
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = getStatusColor(status);
    final isLocked = isStatusLocked(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Text(
            orderId,
            style: GoogleFonts.getFont(
              'Poppins',
              color: const Color(0xFF3B2E1A),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Items
          Text(
            items,
            style: GoogleFonts.getFont(
              'Poppins',
              color: const Color(0xFF757575),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Statut:',
                style: GoogleFonts.getFont(
                  'Poppins',
                  color: const Color(0xFF3B2E1A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              isLocked
                  ? Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColors['bg'],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColors['text']!.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getStatusIcon(status),
                      color: statusColors['text'],
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: statusColors['text'],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
                  : Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: statusColors['bg'],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColors['text']!.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: status,
                    isDense: true,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: statusColors['text'],
                        size: 18,
                      ),
                    ),
                    style: GoogleFonts.getFont(
                      'Poppins',
                      color: statusColors['text'],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    dropdownColor: Colors.white,
                    items: ['En cours', 'Prête', 'En livraison', 'Livrée', 'Annulée']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onStatusChanged(newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time
          Text(
            time,
            style: GoogleFonts.getFont(
              'Poppins',
              color: const Color(0xFF9E9E9E),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
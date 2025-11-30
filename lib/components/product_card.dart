import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            // Image with favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Image.network(
                    image,
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
                      onPressed: onFavoritePressed,
                    ),
                  ),
                ),
              ],
            ),

            // Product details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and price
                  Text(
                    '$name - ${price.toStringAsFixed(3)} DT',
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    style: GoogleFonts.getFont(
                      'Inter',
                      color: const Color(0x5B000000),
                      fontSize: 11,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating, delivery info
                  Row(
                    children: [
                      // Rating
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F3889c445363a2e27f3fcec92b6bff0902f1c308bstar%201.png?alt=media&token=56d4e070-50c9-45ab-b8b9-9c0acfb31bb1',
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rating.toString(),
                        style: GoogleFonts.getFont(
                          'Inter',
                          color: const Color(0xFFED9D49),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 28),

                      // Delivery icon and fee
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fa6943a88fa2656b3ab80b60e5dcb2e67acdf33c2motorcycle%20(1)%201.png?alt=media&token=ce38f61d-9f38-4c8a-b0d1-7ac60b9ad9a4',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        deliveryFee,
                        style: GoogleFonts.getFont(
                          'Inter',
                          color: const Color(0xFFED9D49),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 28),

                      // Time icon and delivery time
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fbf30ecae59637b455384798e5ada459fbaf3dac3clock%201.png?alt=media&token=55f21aba-57c9-4572-86be-23fcbd35df08',
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        deliveryTime,
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
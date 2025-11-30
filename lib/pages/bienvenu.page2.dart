import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'connexion.page.dart';

class BienvenuePage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: Stack(
        children: [
          Positioned(
            left: 24,
            top: 30,
            child: Text(
              'BestMlawi',
              style: GoogleFonts.getFont(
                'Lobster',
                color: Colors.black,
                fontSize: 27,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 64,
            child: Text(
              'Meilleur mlawi en tunisie',
              style: GoogleFonts.getFont(
                'Poppins',
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: -8,
            top: 53,
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fb6b4fab1f2afc8bffddc3053bb5c64a70108e120delivery-guy-illustration_765582-86%201.png?alt=media&token=64d66968-6135-41d3-acd0-ad16b2edf594',
              width: 477,
              height: 434,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 88,
            top: 446,
            child: Text(
              'Livraison rapide \ndans toute la Tunisie',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                'Montserrat',
                color: const Color(0xDB32343E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 93,
            top: 515,
            child: Text(
              'Commandez, détendez-vous, \net laissez-nous vous livrer chaud',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                'Montserrat',
                color: const Color(0xDB32343E),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 181,
            top: 615,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3B664),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
          Positioned(
            left: 207,
            top: 615,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFFD48C41),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Positioned(
            left: 39,
            top: 674,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConnexionPage(),
                  ),
                );
              },
              child: Container(
                width: 323,
                height: 57,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3B664),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    'Démarrer',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont(
                      'Montserrat',
                      color: const Color(0xFFFFF6E8),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
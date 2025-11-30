import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bienvenu.page2.dart';

class BienvenuePage1 extends StatelessWidget {
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
            left: 52,
            top: 278,
            child: Container(
              width: 298,
              height: 102,
              decoration: const BoxDecoration(
                color: Color(0xFFD48C41),
                borderRadius: BorderRadius.all(Radius.elliptical(149, 51)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    spreadRadius: 0,
                    offset: Offset(-1.1, 27.3),
                    blurRadius: 20,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 52,
            top: 150,
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F70be02673fdeb70fef225a6594662f6b55c73ed8image%203.png?alt=media&token=8558831d-4669-4631-9626-e244cdc0a0a8',
              width: 291,
              height: 214,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 99,
            top: 420,
            child: Text(
              'Découvrez le goût \nauthentique \ndu Mlawi tunisien',
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
            left: 75,
            top: 520,
            child: Text(
              'De la pâte dorée aux saveurs uniques \nvivez l\'expérience BestMlawi',
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
            top: 607,
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
            left: 207,
            top: 607,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFFE3B664),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Positioned(
            left: 39,
            top: 666,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BienvenuePage2(),
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
                    'Continuer',
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
          Positioned(
            left: 179,
            top: 736,
            child: Text(
              'Passer',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                'Montserrat',
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
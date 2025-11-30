import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/bottom_nav_bar.dart';

class CommandesPage extends StatefulWidget {
  const CommandesPage({Key? key}) : super(key: key);

  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> {
  bool hasActiveCommands = false;
  bool hasPanierItems = false;
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _checkPanier();
    await _checkActiveCommands();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _checkPanier() async {
    final prefs = await SharedPreferences.getInstance();
    String? cartString = prefs.getString('cart');

    if (cartString != null) {
      List<dynamic> cart = json.decode(cartString);
      hasPanierItems = cart.isNotEmpty;
    } else {
      hasPanierItems = false;
    }
  }

  Future<void> _checkActiveCommands() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId == null) {
      hasActiveCommands = false;
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('commandes')
          .where('userId', isEqualTo: userId)
          .get();

      // Check if there are any commands that are not "Annulé" or "Livré"
      hasActiveCommands = snapshot.docs.any((doc) {
        final etat = doc.data()['etatCommande'] ?? '';
        return etat != 'Annulé' && etat != 'Livré';
      });
    } catch (e) {
      hasActiveCommands = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EC),
                borderRadius: BorderRadius.circular(27),
              ),
              child: Stack(
                children: [
                  // Background decorative element
                  Positioned(
                    left: -58,
                    top: 612,
                    child: Transform.rotate(
                      angle: 180 * pi / 180,
                      child: Image.network(
                        'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2F4c3443a2-bf08-4868-a4a0-53b8b573a1bb.png',
                        width: 92,
                        height: 14,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Main content
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with back button
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: 180 * pi / 180,
                                      child: Image.network(
                                        'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F33a3bbb97c5a949d4419852f6eb37cf8e75609ebimage%2021.png?alt=media&token=862b62b2-7fa3-4b15-949e-f961a8397d1e',
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Commandes',
                                    style: GoogleFonts.getFont(
                                      'Inter',
                                      color: const Color(0xFF3B2E1A),
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 40), // Balance the back button
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Suivez vos commandes section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26.0),
                          child: Text(
                            'Suivez vos commandes',
                            style: GoogleFonts.getFont(
                              'Inter',
                              color: const Color(0xFF3B2E1A),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Commandes en cours container
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22.0),
                          child: Container(
                            width: double.infinity,
                            height: 222,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                width: 3,
                                color: Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(31),
                            ),
                            child: !hasActiveCommands
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2Ff730911c-99e2-4d12-8702-6315521f3398.png',
                                  width: 61,
                                  height: 61,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Commandes en cours',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Vos commandes en cours seront affichées ici',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            )
                                : Center(child: Text('Active commands here')),
                          ),
                        ),

                        SizedBox(height: 50),

                        // Poursuivez votre commande section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26.0),
                          child: Text(
                            'Poursuivez votre commande',
                            style: GoogleFonts.getFont(
                              'Inter',
                              color: const Color(0xFF3B2E1A),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Panier container
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22.0),
                          child: Container(
                            width: double.infinity,
                            height: 222,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                width: 3,
                                color: Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(31),
                            ),
                            child: !hasPanierItems
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2F5ecb087f-7aea-4dd1-9fbf-abb3c8f14075.png',
                                  width: 61,
                                  height: 61,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Aucun panier pour le moment',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Ajoutez des articles pour créer un nouveau panier',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                                : Center(child: Text('Cart items here')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Use the BottomNavBar component
          BottomNavBar(
            selectedIndex: 1, // Commandes is at index 1
            onItemTapped: (index) {
              // Handle navigation if needed
            },
          ),
        ],
      ),
    );
  }
}
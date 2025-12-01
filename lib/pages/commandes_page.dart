import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/bottom_nav_bar.dart';
import '../components/commande_en_cours_card.dart';
import '../components/panier_card.dart';
import '../components/historique_produit_card.dart';
import '../pages/etat_commande_page.dart';
import '../config/translation_config.dart';

class CommandesPage extends StatefulWidget {
  const CommandesPage({Key? key}) : super(key: key);

  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> {
  // ==================== Variables d'état ====================
  List<Map<String, dynamic>> activeCommands = [];
  List<Map<String, dynamic>> historiqueCommands = [];
  Map<String, dynamic>? panierData;
  bool isLoading = true;
  String? userEmail;

  // Variables pour les traductions
  String translatedCommandes = 'Commandes';
  String translatedSuivezCommandes = 'Suivez vos commandes';
  String translatedCommandesEnCours = 'Commandes en cours';
  String translatedCommandesEnCoursMessage = 'Vos commandes en cours seront affichées ici';
  String translatedPoursuivezCommande = 'Poursuivez votre commande';
  String translatedAucunPanier = 'Aucun panier pour le moment';
  String translatedAjoutezArticles = 'Ajoutez des articles pour créer un nouveau panier';
  String translatedHistoriqueCommandes = 'Historique des commandes';
  String translatedCommandesTerminees = 'Vos commandes terminées apparaîtront ici';
  String translatedGratuit = 'Gratuit';

  // ==================== Initialisation ====================
  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _loadData();
  }

  // ==================== Chargement des traductions ====================
  Future<void> _loadTranslations() async {
    translatedCommandes = await translate('Commandes');
    translatedSuivezCommandes = await translate('Suivez vos commandes');
    translatedCommandesEnCours = await translate('Commandes en cours');
    translatedCommandesEnCoursMessage = await translate('Vos commandes en cours seront affichées ici');
    translatedPoursuivezCommande = await translate('Poursuivez votre commande');
    translatedAucunPanier = await translate('Aucun panier pour le moment');
    translatedAjoutezArticles = await translate('Ajoutez des articles pour créer un nouveau panier');
    translatedHistoriqueCommandes = await translate('Historique des commandes');
    translatedCommandesTerminees = await translate('Vos commandes terminées apparaîtront ici');
    translatedGratuit = await translate('Gratuit');

    if (mounted) {
      setState(() {});
    }
  }

  // ==================== Chargement des données ====================
  Future<void> _loadData() async {
    await _checkPanier();
    await _checkCommands();
    setState(() {
      isLoading = false;
    });
  }

  // ==================== Vérification du panier ====================
  Future<void> _checkPanier() async {
    final prefs = await SharedPreferences.getInstance();
    String? cartString = prefs.getString('cart');

    if (cartString != null) {
      List<dynamic> cart = json.decode(cartString);
      if (cart.isNotEmpty) {
        // Calcul du prix total et du nombre d'articles
        double totalPrice = 0;
        int itemCount = 0;
        String? storeName;

        for (var item in cart) {
          totalPrice += (item['totalPrice'] ?? 0) * (item['quantity'] ?? 1);
          itemCount += (item['quantity'] ?? 1) as int;
          if (storeName == null && item['storeName'] != null) {
            storeName = item['storeName'];
          }
        }

        panierData = {
          'storeName': storeName ?? 'BestMlawi',
          'totalPrice': totalPrice.toStringAsFixed(2),
          'itemCount': itemCount,
        };
      }
    }
  }

  // ==================== Vérification des commandes ====================
  Future<void> _checkCommands() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email');

    if (userEmail == null || userEmail!.isEmpty) {
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('commandes')
          .where('userEmail', isEqualTo: userEmail)
          .get();

      // Séparation des commandes actives et historiques
      activeCommands = [];
      historiqueCommands = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final etat = data['etatCommande'] ?? '';
        final normalizedEtat = etat.toString().trim().toLowerCase();

        final commandData = {
          'id': doc.id,
          'commandeId': data['commandeId'] ?? 'CMD-000000',
          'storeName': data['storeName'] ?? 'BestMlawi',
          'etatCommande': data['etatCommande'] ?? 'En cours de traitement',
          'createdAt': data['createdAt'],
        };

        // Vérification si la commande est Livrée ou Annulée
        if (normalizedEtat == 'annulée' ||
            normalizedEtat == 'livrée' ||
            normalizedEtat == 'annulee' ||
            normalizedEtat == 'livree') {
          historiqueCommands.add(commandData);
        } else {
          activeCommands.add(commandData);
        }
      }
    } catch (e) {
      print('Error fetching commands: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD48C41),
          ),
        ),
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
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec bouton retour
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
                                  child: Image.network(
                                    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F33a3bbb97c5a949d4419852f6eb37cf8e75609ebimage%2021.png?alt=media&token=3e303e55-1ea0-4108-b6bd-af87b8829beb',
                                    width: 18,
                                    height: 18,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  translatedCommandes,
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    color: const Color(0xFF3B2E1A),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 40), // Équilibre le bouton retour
                          ],
                        ),
                      ),

                      SizedBox(height: 40),

                      // Section Suivez vos commandes
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36.0),
                        child: Text(
                          translatedSuivezCommandes,
                          style: GoogleFonts.getFont(
                            'Inter',
                            color: const Color(0xFF3B2E1A),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Commandes en cours
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26.0),
                        child: activeCommands.isEmpty
                            ? Container(
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
                          child: Column(
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
                                translatedCommandesEnCours,
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                translatedCommandesEnCoursMessage,
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Column(
                          children: activeCommands.map((command) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: CommandeEnCoursCard(
                                commandeId: command['commandeId'],
                                storeName: command['storeName'],
                                status: command['etatCommande'],
                                onTap: () {
                                  // Navigation vers la page de détails de la commande
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EtatCommandePage(
                                        orderId: command['commandeId'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 70),

                      // Section Poursuivez votre commande
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          translatedPoursuivezCommande,
                          style: GoogleFonts.getFont(
                            'Inter',
                            color: const Color(0xFF3B2E1A),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Panier
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 31.0),
                        child: panierData == null
                            ? Container(
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
                          child: Column(
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
                                translatedAucunPanier,
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                translatedAjoutezArticles,
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                            : PanierCard(
                          storeName: panierData!['storeName'],
                          deliveryInfo: translatedGratuit,
                          totalPrice: '${panierData!['totalPrice']}DT',
                          itemCount: panierData!['itemCount'],
                          onTap: () {
                            // Navigation vers la page panier
                            Navigator.pushNamed(context, '/panier');
                          },
                        ),
                      ),

                      SizedBox(height: 70),

                      // Section Historique des commandes
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          translatedHistoriqueCommandes,
                          style: GoogleFonts.getFont(
                            'Inter',
                            color: const Color(0xFF3B2E1A),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Historique des commandes
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26.0),
                        child: historiqueCommands.isEmpty
                            ? Container(
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 61,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 15),
                              Text(
                                translatedHistoriqueCommandes,
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                translatedCommandesTerminees,
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Column(
                          children: historiqueCommands.map((command) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: HistoriqueProduitCard(
                                commandeId: command['commandeId'],
                                storeName: command['storeName'],
                                status: command['etatCommande'],
                                createdAt: command['createdAt'],
                                onTap: () {
                                  // Navigation vers la page de détails de la commande
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EtatCommandePage(
                                        orderId: command['commandeId'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Barre de navigation inférieure
          BottomNavBar(
            selectedIndex: 1, // Commandes est à l'index 1
            onItemTapped: (index) {
              // La navigation est gérée dans BottomNavBar
            },
          ),
        ],
      ),
    );
  }
}
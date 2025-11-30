import 'package:bestmlawi/pages/produit_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/bottom_nav_bar.dart';
import '../components/product_card.dart';
import '../config/global_params.dart';
import '../config/translation_config.dart';

class PageAcceuil extends StatefulWidget {
  @override
  _PageAcceuilState createState() => _PageAcceuilState();
}

class _PageAcceuilState extends State<PageAcceuil> {
  Set<String> selectedCategories = {};
  int selectedNavIndex = 0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  // User data from SharedPreferences and Firebase
  String userName = '';
  String? userProfileImage;
  bool isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Try to get data from Firestore first
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            userName = data['nom'] ?? 'Utilisateur';
            userProfileImage = data['profileImageUrl'];
            isLoadingUserData = false;
          });

          // Update SharedPreferences
          await prefs.setString('nom', userName);
          if (userProfileImage != null) {
            await prefs.setString('profileImageUrl', userProfileImage!);
          }
        } else {
          // Fallback to SharedPreferences
          setState(() {
            userName = prefs.getString('nom') ?? 'Utilisateur';
            userProfileImage = prefs.getString('profileImageUrl');
            isLoadingUserData = false;
          });
        }
      } else {
        // User not logged in, use SharedPreferences
        setState(() {
          userName = prefs.getString('nom') ?? 'Utilisateur';
          userProfileImage = prefs.getString('profileImageUrl');
          isLoadingUserData = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoadingUserData = false;
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        print('Navigate to Home');
        break;
      case 1:
        print('Navigate to Commandes');
        break;
      case 2:
        print('Navigate to Profile');
        break;
    }
  }

  List<Map<String, dynamic>> getFilteredProducts() {
    List<Map<String, dynamic>> products = GlobalParams.products;

    if (selectedCategories.isNotEmpty) {
      products = products
          .where((product) => selectedCategories.contains(product['category']))
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      products = products.where((product) {
        String productName = product['name'].toString().toLowerCase();
        String productDesc = product['description'].toString().toLowerCase();
        String query = searchQuery.toLowerCase();
        return productName.contains(query) || productDesc.contains(query);
      }).toList();
    }

    return products;
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 20, 0),
              child: Row(
                children: [
                  // Profile image - Dynamic from Firebase/SharedPreferences
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: isLoadingUserData
                        ? Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD48C41).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD48C41),
                          ),
                        ),
                      ),
                    )
                        : userProfileImage != null && userProfileImage!.isNotEmpty
                        ? Image.network(
                      userProfileImage!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD48C41),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    )
                        : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD48C41),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Welcome text - Translated directly
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: translate('Bienvenu à niveau'),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Bienvenu à niveau',
                              style: GoogleFonts.getFont(
                                'Poppins',
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        Text(
                          userName, // Dynamic user name from Firebase
                          style: GoogleFonts.getFont(
                            'Poppins',
                            color: const Color(0xFFACACAC),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notification button
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          spreadRadius: 0,
                          offset: Offset(0, 4.5),
                          blurRadius: 14,
                        )
                      ],
                    ),
                    child: Center(
                      child: Image.network(
                        GlobalParams.notificationIcon,
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search bar - Translated placeholder directly
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FB),
                  border: Border.all(
                    width: 2,
                    color: const Color(0xFFF0F0F0),
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: FutureBuilder<String>(
                        future: translate('Chercher un produit...'),
                        builder: (context, snapshot) {
                          return TextField(
                            controller: searchController,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: snapshot.data ?? 'Chercher un produit...',
                              hintStyle: GoogleFonts.getFont(
                                'Inter',
                                color: const Color(0xFFA2A2A2),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Image.network(
                        GlobalParams.searchIcon,
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Category filter section - Translated directly
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: translate('Filtrer par catégorie'),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Filtrer par catégorie',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          color: const Color(0xFF3B2E1A),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  // Category buttons
                  SizedBox(
                    height: 93,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: GlobalParams.categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 7),
                          child: _buildCategoryButton(
                            category['name'],
                            category['image'],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Products section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: translate('Produits populaires'),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Produits populaires',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              color: const Color(0xFF3B2E1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),

                      // Product cards or empty state
                      Builder(
                        builder: (context) {
                          final filteredProducts = getFilteredProducts();

                          if (filteredProducts.isEmpty) {
                            // Empty state - Translated directly
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 80),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F7FB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.search_off,
                                        size: 60,
                                        color: const Color(0xFFACACAC),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    FutureBuilder<String>(
                                      future: translate('Aucun produit trouvé'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? 'Aucun produit trouvé',
                                          style: GoogleFonts.getFont(
                                            'Poppins',
                                            color: const Color(0xFF3B2E1A),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    FutureBuilder<String>(
                                      future: translate('Essayez de modifier votre recherche\nou vos filtres'),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? 'Essayez de modifier votre recherche\nou vos filtres',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.getFont(
                                            'Poppins',
                                            color: const Color(0xFFACACAC),
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Show product cards
                          return Column(
                            children: filteredProducts.map((product) {
                              return ProductCard(
                                name: product['name'],
                                price: product['price'],
                                description: product['description'],
                                image: product['image'],
                                rating: product['rating'],
                                deliveryTime: product['deliveryTime'],
                                deliveryFee: product['deliveryFee'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProduitPage(
                                        productId: product['id'],
                                      ),
                                    ),
                                  );
                                },
                                onFavoritePressed: () {
                                  print('Favorite ${product['name']}');
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedNavIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }

  Widget _buildCategoryButton(String name, String imageUrl) {
    bool isSelected = selectedCategories.contains(name);

    return GestureDetector(
      onTap: () => _toggleCategory(name),
      child: Container(
        width: 106,
        height: 93,
        decoration: BoxDecoration(
          border: Border.all(
            width: isSelected ? 3 : 2,
            color: isSelected
                ? const Color(0xFFD48C41)
                : const Color(0xBC000000),
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),

              // Orange overlay when selected
              if (isSelected)
                Container(
                  color: const Color(0xFFD48C41).withOpacity(0.6),
                ),

              // White checkmark when selected
              if (isSelected)
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFFD48C41),
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
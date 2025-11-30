import 'package:bestmlawi/pages/produit_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/bottom_nav_bar.dart';
import '../components/product_card.dart';
import '../config/global_params.dart';

class PageAcceuil extends StatefulWidget {
  @override
  _PageAcceuilState createState() => _PageAcceuilState();
}

class _PageAcceuilState extends State<PageAcceuil> {
  Set<String> selectedCategories = {};
  int selectedNavIndex = 0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      selectedNavIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0:
        print('Navigate to Home');
        break;
      case 1:
        print('Navigate to Commandes');
        // Navigator.pushNamed(context, '/commandes');
        break;
      case 2:
        print('Navigate to Profile');
        // Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  List<Map<String, dynamic>> getFilteredProducts() {
    List<Map<String, dynamic>> products = GlobalParams.products;

    // Filter by categories if any selected
    if (selectedCategories.isNotEmpty) {
      products = products
          .where((product) => selectedCategories.contains(product['category']))
          .toList();
    }

    // Filter by search query
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
                  // Profile image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      GlobalParams.userProfileImage,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Welcome text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenu à niveau',
                          style: GoogleFonts.getFont(
                            'Poppins',
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Mahmoud abbes',
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

            // Search bar
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
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Chercher un produit...',
                          hintStyle: GoogleFonts.getFont(
                            'Inter',
                            color: const Color(0xFFA2A2A2),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
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

            // Category filter section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrer par catégorie',
                    style: GoogleFonts.getFont(
                      'Poppins',
                      color: const Color(0xFF3B2E1A),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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
                      Text(
                        'Produits populaires',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          color: const Color(0xFF3B2E1A),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Product cards or empty state
                      Builder(
                        builder: (context) {
                          final filteredProducts = getFilteredProducts();

                          if (filteredProducts.isEmpty) {
                            // Empty state when no products found
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
                                    Text(
                                      'Aucun produit trouvé',
                                      style: GoogleFonts.getFont(
                                        'Poppins',
                                        color: const Color(0xFF3B2E1A),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Essayez de modifier votre recherche\nou vos filtres',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(
                                        'Poppins',
                                        color: const Color(0xFFACACAC),
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
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
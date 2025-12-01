import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/bottom_nav_bar_admin.dart';
import '../components/commande_admin_card.dart';

class GestionCommandesPage extends StatefulWidget {
  const GestionCommandesPage({Key? key}) : super(key: key);

  @override
  _GestionCommandesPageState createState() => _GestionCommandesPageState();
}

class _GestionCommandesPageState extends State<GestionCommandesPage> {
  String selectedStatus = 'Tous';
  String userName = '';
  String? userProfileImage;
  bool isLoadingUserData = true;

  // Status mapping between Firebase and display values
  final Map<String, String> statusMapping = {
    'En cours de traitement': 'En cours',
    'Prête': 'Prête',
    'En livraison': 'En livraison',
    'Livrée': 'Livrée',
    'Annulée': 'Annulée',
  };

  final Map<String, String> reverseStatusMapping = {
    'En cours': 'En cours de traitement',
    'Prête': 'Prête',
    'En livraison': 'En livraison',
    'Livrée': 'Livrée',
    'Annulée': 'Annulée',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            userName = data['nom'] ?? 'Administrateur';
            userProfileImage = data['profileImageUrl'];
            isLoadingUserData = false;
          });

          await prefs.setString('nom', userName);
          if (userProfileImage != null) {
            await prefs.setString('profileImageUrl', userProfileImage!);
          }
        } else {
          setState(() {
            userName = prefs.getString('nom') ?? 'Administrateur';
            userProfileImage = prefs.getString('profileImageUrl');
            isLoadingUserData = false;
          });
        }
      } else {
        setState(() {
          userName = prefs.getString('nom') ?? 'Administrateur';
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Date inconnue';

    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (orderDate == today) {
      return 'Aujourd\'hui à $timeStr';
    } else if (orderDate == today.subtract(const Duration(days: 1))) {
      return 'Hier à $timeStr';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} à $timeStr';
    }
  }

  String _formatOrderItems(List<dynamic> products) {
    if (products.isEmpty) return 'Aucun produit';

    int totalItems = 0;
    for (var product in products) {
      totalItems += (product['quantity'] ?? 1) as int;
    }

    String itemsText = '$totalItems item${totalItems > 1 ? 's' : ''}';

    if (products.isNotEmpty) {
      String firstItem = '${products[0]['quantity']}x ${products[0]['name']}';
      itemsText += ' • $firstItem';

      if (products.length > 1) {
        String secondItem = '${products[1]['quantity']}x ${products[1]['name']}';
        itemsText += ' • $secondItem';
      }

      if (products.length > 2) {
        itemsText += ' • +${products.length - 2} autres';
      }
    }

    return itemsText;
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Convert display status to Firebase status
      String firebaseStatus = reverseStatusMapping[newStatus] ?? newStatus;

      await FirebaseFirestore.instance
          .collection('commandes')
          .doc(orderId)
          .update({
        'etatCommande': firebaseStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut de la commande mis à jour'),
          backgroundColor: const Color(0xFFA2B84E),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating order status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du statut'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with profile and orange divider
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFD48C41),
                    width: 4,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    // Profile row
                    Row(
                      children: [
                        // Profile image
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
                        const SizedBox(width: 12),
                        // Welcome text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Administration',
                                style: GoogleFonts.getFont(
                                  'Poppins',
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                userName,
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
                        // Refresh button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _loadUserData();
                            });
                          },
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FB),
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFF3B2E1A),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Status filter
                    Row(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedStatus,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF616161),
                                  size: 20,
                                ),
                                style: GoogleFonts.getFont(
                                  'Poppins',
                                  color: const Color(0xFF3B2E1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: ['Tous', 'En cours', 'Prête', 'En livraison', 'Livrée', 'Annulée']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedStatus = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Orders list from Firebase
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('commandes')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur de chargement',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD48C41),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F7FB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              size: 50,
                              color: Color(0xFFACACAC),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Aucune commande',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              color: const Color(0xFF3B2E1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Les commandes apparaîtront ici',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              color: const Color(0xFFACACAC),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter orders based on selected status
                  var allOrders = snapshot.data!.docs;
                  var filteredOrders = selectedStatus == 'Tous'
                      ? allOrders
                      : allOrders.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String firebaseStatus = data['etatCommande'] ?? '';
                    String displayStatus = statusMapping[firebaseStatus] ?? firebaseStatus;
                    return displayStatus == selectedStatus;
                  }).toList();

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F7FB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off,
                              size: 50,
                              color: Color(0xFFACACAC),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Aucune commande trouvée',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              color: const Color(0xFF3B2E1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Essayez de modifier votre filtre',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              color: const Color(0xFFACACAC),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      var orderDoc = filteredOrders[index];
                      var orderData = orderDoc.data() as Map<String, dynamic>;

                      String orderId = orderData['commandeId'] ?? orderDoc.id;
                      List<dynamic> products = orderData['products'] ?? [];
                      String firebaseStatus = orderData['etatCommande'] ?? 'En cours de traitement';
                      String displayStatus = statusMapping[firebaseStatus] ?? firebaseStatus;
                      Timestamp? createdAt = orderData['createdAt'];

                      return CommandeCard(
                        orderId: orderId,
                        items: _formatOrderItems(products),
                        status: displayStatus,
                        time: _formatTimestamp(createdAt),
                        onStatusChanged: (newStatus) {
                          _updateOrderStatus(orderDoc.id, newStatus);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBarAdmin(
        selectedIndex: 0,
        onItemTapped: (int index) {
          // Handle navigation
          if (index == 1) {
            // Navigate to profile
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
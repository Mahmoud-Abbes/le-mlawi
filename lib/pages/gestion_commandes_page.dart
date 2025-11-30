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

  final List<Map<String, dynamic>> orders = [
    {
      'id': 'CMD #78548865',
      'items': '3 items • 1x mlawi rosbif • 1x mlawi thon • +1 others',
      'status': 'En cours',
      'time': 'Aujourd\'hui à 14:22'
    },
    {
      'id': 'CMD #78548866',
      'items': '3 items • 1x mlawi rosbif • 1x mlawi thon • +1 others',
      'status': 'Prête',
      'time': 'Aujourd\'hui à 14:22'
    },
    {
      'id': 'CMD #78548867',
      'items': '3 items • 1x mlawi rosbif • 1x mlawi thon • +1 others',
      'status': 'En livraison',
      'time': 'Aujourd\'hui à 14:22'
    },
    {
      'id': 'CMD #78548868',
      'items': '2 items • 1x mlawi rosbif • 1x mlawi thon',
      'status': 'Livrée',
      'time': 'Aujourd\'hui à 13:15'
    },
    {
      'id': 'CMD #78548869',
      'items': '4 items • 2x mlawi rosbif • 1x mlawi thon • +1 others',
      'status': 'En cours',
      'time': 'Aujourd\'hui à 12:45'
    },
    {
      'id': 'CMD #78548870',
      'items': '1 items • 1x mlawi rosbif',
      'status': 'Annulée',
      'time': 'Aujourd\'hui à 11:30'
    }
  ];

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

  List<Map<String, dynamic>> getFilteredOrders() {
    if (selectedStatus == 'Tous') {
      return orders;
    }
    return orders.where((order) => order['status'] == selectedStatus).toList();
  }

  void _updateOrderStatus(int index, String newStatus) {
    setState(() {
      orders[index]['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = getFilteredOrders();

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

            // Orders list
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
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
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final originalIndex = orders.indexOf(order);

                  return CommandeCard(
                    orderId: order['id'],
                    items: order['items'],
                    status: order['status'],
                    time: order['time'],
                    onStatusChanged: (newStatus) {
                      _updateOrderStatus(originalIndex, newStatus);
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
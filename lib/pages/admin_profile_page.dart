import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/bottom_nav_bar_admin.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String selectedLanguage = 'Français';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = true;
  String? profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  static const String IMGBB_API_KEY = '73a767be01531640fe4a5a7c25bb547e';

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
            nameController.text = data['nom'] ?? '';
            emailController.text = data['email'] ?? user.email ?? '';
            phoneController.text = data['telephone'] ?? '';
            profileImageUrl = data['profileImageUrl'];
            selectedLanguage = data['selectedLanguage'] ?? 'Français';
          });

          await prefs.setString('nom', nameController.text);
          await prefs.setString('email', emailController.text);
          await prefs.setString('telephone', phoneController.text);
          await prefs.setString('profileImageUrl', profileImageUrl ?? '');
          await prefs.setString('selectedLanguage', selectedLanguage);
        } else {
          setState(() {
            nameController.text = prefs.getString('nom') ?? '';
            emailController.text = prefs.getString('email') ?? user.email ?? '';
            phoneController.text = prefs.getString('telephone') ?? '';
            profileImageUrl = prefs.getString('profileImageUrl');
            selectedLanguage = prefs.getString('selectedLanguage') ?? 'Français';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> _uploadImageToImgBB(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['key'] = IMGBB_API_KEY;
      request.fields['image'] = base64Image;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'];
        } else {
          throw Exception('Upload failed: ${jsonResponse['error']['message']}');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      rethrow;
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        isUploading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final File imageFile = File(image.path);
      final String? imageUrl = await _uploadImageToImgBB(imageFile);

      if (imageUrl == null) {
        throw Exception('Failed to get image URL');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'profileImageUrl': imageUrl,
      }, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', imageUrl);

      setState(() {
        profileImageUrl = imageUrl;
        isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour avec succès'),
            backgroundColor: Color(0xFFD48C41),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error uploading image: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'nom': nameController.text.trim(),
        'email': emailController.text.trim(),
        'telephone': phoneController.text.trim(),
        'selectedLanguage': selectedLanguage,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nom', nameController.text.trim());
      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('telephone', phoneController.text.trim());
      await prefs.setString('selectedLanguage', selectedLanguage);

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations modifiées avec succès'),
            backgroundColor: Color(0xFFD48C41),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error saving user data: $e');
    }
  }

  Future<void> _changeLanguage(String language) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        selectedLanguage = language;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'selectedLanguage': language,
      }, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLanguage', language);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Langue changée en $language'),
            backgroundColor: const Color(0xFFD48C41),
          ),
        );
      }
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8EC),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD48C41),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 326,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5C98F),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.elliptical(176, 138),
                          bottomRight: Radius.elliptical(176, 138),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 25,
                      top: 36,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF3B2E1A),
                          size: 24,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 31,
                      child: Center(
                        child: Text(
                          'Profile Administrateur',
                          style: GoogleFonts.getFont(
                            'Roboto',
                            color: const Color(0xFF3B2E1A),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 108,
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 99,
                              height: 99,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(50),
                                image: profileImageUrl != null && profileImageUrl!.isNotEmpty
                                    ? DecorationImage(
                                  image: NetworkImage(profileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: profileImageUrl == null || profileImageUrl!.isEmpty
                                  ? Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey.shade400,
                              )
                                  : null,
                            ),
                            if (isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: isUploading ? null : _pickAndUploadImage,
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.5),
                                    border: Border.all(
                                      color: const Color(0xFFD48C41),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isUploading ? Icons.hourglass_empty : Icons.add,
                                      size: 16,
                                      color: const Color(0xFFD48C41),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 220,
                      child: Column(
                        children: [
                          Text(
                            nameController.text.isNotEmpty
                                ? nameController.text
                                : 'Nom',
                            style: GoogleFonts.getFont(
                              'Roboto',
                              color: const Color(0xFF3B2E1A),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            emailController.text.isNotEmpty
                                ? emailController.text
                                : 'Email',
                            style: GoogleFonts.getFont(
                              'Roboto',
                              color: const Color(0xFF83735C),
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisir langue de l\'application',
                        style: GoogleFonts.getFont(
                          'Roboto',
                          color: const Color(0xFF3B2E1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLanguageOption('Français'),
                      const SizedBox(height: 10),
                      _buildLanguageOption('English'),
                      const SizedBox(height: 10),
                      _buildLanguageOption('العربية'),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modifier vos informations',
                        style: GoogleFonts.getFont(
                          'Roboto',
                          color: const Color(0xFF3B2E1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoField(nameController, 'Nom'),
                      const SizedBox(height: 12),
                      _buildInfoField(emailController, 'Email'),
                      const SizedBox(height: 12),
                      _buildInfoField(phoneController, 'Téléphone'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 104),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD48C41),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(59),
                      ),
                      minimumSize: const Size(194, 43),
                    ),
                    onPressed: _saveUserData,
                    child: Text(
                      'Modifier',
                      style: GoogleFonts.getFont(
                        'Inter',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 104),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(59),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFD48C41),
                        width: 2,
                      ),
                      minimumSize: const Size(194, 43),
                    ),
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFFD48C41),
                      size: 20,
                    ),
                    label: Text(
                      'Déconnexion',
                      style: GoogleFonts.getFont(
                        'Inter',
                        color: const Color(0xFFD48C41),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBarAdmin(
              selectedIndex: 1,
              onItemTapped: (int index) {
                if (index == 0) {
                  // Navigate to orders management
                  Navigator.pushNamed(context, '/gestion_commandes');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    bool isSelected = selectedLanguage == language;

    return GestureDetector(
      onTap: () => _changeLanguage(language),
      child: Row(
        children: [
          Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                width: 1.1,
                color: const Color(0xFF877C6B),
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: isSelected
                  ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2E1A),
                  borderRadius: BorderRadius.circular(5),
                ),
              )
                  : null,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            language,
            style: GoogleFonts.getFont(
              'Roboto',
              color: const Color(0xFF3B2E1A),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(TextEditingController controller, String hint) {
    return Container(
      width: double.infinity,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        border: Border.all(
          width: 1.7,
          color: const Color(0xFFCCC5C5),
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          style: GoogleFonts.getFont(
            'Poppins',
            color: const Color(0xFF393939),
            fontSize: 13,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            isDense: true,
            hintText: hint,
            hintStyle: GoogleFonts.getFont(
              'Poppins',
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
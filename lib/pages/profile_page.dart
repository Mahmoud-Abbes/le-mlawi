import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/bottom_nav_bar.dart';
import '../config/translation_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ==================== Variables d'état ====================
  String selectedLanguage = 'Français';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = true;
  String? profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  static const String IMGBB_API_KEY = '73a767be01531640fe4a5a7c25bb547e';

  // Variables pour les traductions
  String translatedProfile = 'Profile';
  String translatedNom = 'Nom';
  String translatedEmail = 'Email';
  String translatedChoisirLangue = 'Choisir langue de l\'application';
  String translatedModifierInfo = 'Modifier vos informations';
  String translatedTelephone = 'Téléphone';
  String translatedModifier = 'Modifier';
  String translatedDeconnexion = 'Déconnexion';
  String translatedErreurChargement = 'Erreur de chargement: ';
  String translatedPhotoMiseAJour = 'Photo de profil mise à jour avec succès';
  String translatedErreurTelechargement = 'Erreur lors du téléchargement: ';
  String translatedUtilisateurNonConnecte = 'Utilisateur non connecté';
  String translatedInfoModifiees = 'Informations modifiées avec succès';
  String translatedErreurMiseAJour = 'Erreur lors de la mise à jour: ';
  String translatedLangueChangee = 'Langue changée en ';
  String translatedErreurDeconnexion = 'Erreur lors de la déconnexion: ';

  // ==================== Initialisation ====================
  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _loadUserData();
  }

  // ==================== Chargement des traductions ====================
  Future<void> _loadTranslations() async {
    translatedProfile = await translate('Profile');
    translatedNom = await translate('Nom');
    translatedEmail = await translate('Email');
    translatedChoisirLangue = await translate('Choisir langue de l\'application');
    translatedModifierInfo = await translate('Modifier vos informations');
    translatedTelephone = await translate('Téléphone');
    translatedModifier = await translate('Modifier');
    translatedDeconnexion = await translate('Déconnexion');
    translatedErreurChargement = await translate('Erreur de chargement: ');
    translatedPhotoMiseAJour = await translate('Photo de profil mise à jour avec succès');
    translatedErreurTelechargement = await translate('Erreur lors du téléchargement: ');
    translatedUtilisateurNonConnecte = await translate('Utilisateur non connecté');
    translatedInfoModifiees = await translate('Informations modifiées avec succès');
    translatedErreurMiseAJour = await translate('Erreur lors de la mise à jour: ');
    translatedLangueChangee = await translate('Langue changée en ');
    translatedErreurDeconnexion = await translate('Erreur lors de la déconnexion: ');

    if (mounted) {
      setState(() {});
    }
  }

  // ==================== Chargement des données utilisateur ====================
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
          content: Text('$translatedErreurChargement$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ==================== Upload d'image vers ImgBB ====================
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

  // ==================== Sélection et upload de l'image de profil ====================
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
        throw Exception(translatedUtilisateurNonConnecte);
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
          SnackBar(
            content: Text(translatedPhotoMiseAJour),
            backgroundColor: Color(0xFFA2B84E),
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
            content: Text('$translatedErreurTelechargement$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error uploading image: $e');
    }
  }

  // ==================== Sauvegarde des données utilisateur ====================
  Future<void> _saveUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(translatedUtilisateurNonConnecte);
      }

      setState(() {
        isLoading = true;
      });

      // Mise à jour dans Firestore avec la langue
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

      // Mise à jour dans SharedPreferences avec la langue
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
          SnackBar(
            content: Text(translatedInfoModifiees),
            backgroundColor: Color(0xFFA2B84E),
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
            content: Text('$translatedErreurMiseAJour$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error saving user data: $e');
    }
  }

  // ==================== Changement de langue ====================
  Future<void> _changeLanguage(String language) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        selectedLanguage = language;
      });

      // Mise à jour dans Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'selectedLanguage': language,
      }, SetOptions(merge: true));

      // Mise à jour dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLanguage', language);

      // Recharger les traductions
      await _loadTranslations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$translatedLangueChangee$language'),
            backgroundColor: const Color(0xFFA2B84E),
          ),
        );
      }
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  // ==================== Déconnexion ====================
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
            content: Text('$translatedErreurDeconnexion$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== Nettoyage ====================
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ==================== Interface utilisateur ====================
  @override
  Widget build(BuildContext context) {
    // Écran de chargement
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8EC),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD19C64),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: Stack(
        children: [
          // Contenu principal avec défilement
          SingleChildScrollView(
            child: Column(
              children: [
                // En-tête avec photo de profil
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Arrière-plan arrondi
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
                    // Bouton retour
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
                    // Titre de la page
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 31,
                      child: Center(
                        child: Text(
                          translatedProfile,
                          style: GoogleFonts.getFont(
                            'Roboto',
                            color: const Color(0xFF3B2E1A),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Photo de profil avec bouton d'ajout
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 108,
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Avatar
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
                            // Indicateur de chargement
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
                            // Bouton d'ajout de photo
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
                                      color: const Color(0xFFD19C64),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isUploading ? Icons.hourglass_empty : Icons.add,
                                      size: 16,
                                      color: const Color(0xFFD19C64),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Nom et email de l'utilisateur
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 220,
                      child: Column(
                        children: [
                          Text(
                            nameController.text.isNotEmpty
                                ? nameController.text
                                : translatedNom,
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
                                : translatedEmail,
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
                // Section de sélection de langue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translatedChoisirLangue,
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
                // Section de modification des informations
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translatedModifierInfo,
                        style: GoogleFonts.getFont(
                          'Roboto',
                          color: const Color(0xFF3B2E1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoField(nameController, translatedNom),
                      const SizedBox(height: 12),
                      _buildInfoField(emailController, translatedEmail),
                      const SizedBox(height: 12),
                      _buildInfoField(phoneController, translatedTelephone),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Bouton Modifier
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 104),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD19C64),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(59),
                      ),
                      minimumSize: const Size(194, 43),
                    ),
                    onPressed: _saveUserData,
                    child: Text(
                      translatedModifier,
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
                // Bouton Déconnexion
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 104),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(59),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFD19C64),
                        width: 2,
                      ),
                      minimumSize: const Size(194, 43),
                    ),
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFFD19C64),
                      size: 20,
                    ),
                    label: Text(
                      translatedDeconnexion,
                      style: GoogleFonts.getFont(
                        'Inter',
                        color: const Color(0xFFD19C64),
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
          // Barre de navigation inférieure
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              selectedIndex: 2,
              onItemTapped: (int index) {},
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Widget option de langue ====================
  Widget _buildLanguageOption(String language) {
    bool isSelected = selectedLanguage == language;

    return GestureDetector(
      onTap: () => _changeLanguage(language),
      child: Row(
        children: [
          // Bouton radio personnalisé
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
          // Nom de la langue
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

  // ==================== Widget champ d'information ====================
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
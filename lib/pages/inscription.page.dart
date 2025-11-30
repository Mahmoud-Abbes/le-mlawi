import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/google_auth_service.dart';

class InscriptionPage extends StatefulWidget {
  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  TextEditingController txt_nom = TextEditingController();
  TextEditingController txt_telephone = TextEditingController();
  TextEditingController txt_email = TextEditingController();
  TextEditingController txt_password = TextEditingController();
  TextEditingController txt_password_confirm = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _togglePasswordConfirmVisibility() {
    setState(() {
      _obscurePasswordConfirm = !_obscurePasswordConfirm;
    });
  }

  Future<void> _saveUserData(String nom, String telephone, String email, String uid) async {
    try {
      // Save to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nom', nom);
      await prefs.setString('telephone', telephone);
      await prefs.setString('email', email);
      await prefs.setString('uid', uid);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nom': nom,
        'telephone': telephone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<void> _onInscription(BuildContext context) async {
    String nom = txt_nom.text;
    String telephone = txt_telephone.text;
    String email = txt_email.text;
    String password = txt_password.text;
    String passwordConfirm = txt_password_confirm.text;

    if (nom.isEmpty || telephone.isEmpty || email.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
      const snackBar = SnackBar(
        content: Text("Veuillez remplir tous les champs"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (password != passwordConfirm) {
      const snackBar = SnackBar(
        content: Text("Les mots de passe ne correspondent pas"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD48C41),
              ),
            );
          },
        );

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        // Update display name
        await userCredential.user?.updateDisplayName(nom);

        // Save user data
        await _saveUserData(nom, telephone, email, userCredential.user!.uid);

        Navigator.pop(context); // Remove loading
        Navigator.pop(context); // Pop inscription page
        Navigator.pushNamed(context, '/home');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie'),
            backgroundColor: Color(0xFFA2B84E),
          ),
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context); // Remove loading

        SnackBar snackBar = SnackBar(content: Text(""));
        if (e.code == 'weak-password') {
          snackBar = SnackBar(
            content: Text('Mot de passe faible'),
          );
        } else if (e.code == 'email-already-in-use') {
          snackBar = SnackBar(
            content: Text("Email déjà existant"),
          );
        } else if (e.code == 'invalid-email') {
          snackBar = SnackBar(
            content: Text("Email invalide"),
          );
        } else {
          snackBar = SnackBar(
            content: Text("Erreur: ${e.message}"),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> _onGoogleLogin(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD48C41),
            ),
          );
        },
      );

      final GoogleAuthService authService = GoogleAuthService();
      final userCredential = await authService.signInWithGoogle();

      Navigator.pop(context); // Remove loading

      if (userCredential != null) {
        // Get user data from Google
        String nom = userCredential.user?.displayName ?? '';
        String email = userCredential.user?.email ?? '';
        String telephone = userCredential.user?.phoneNumber ?? '';

        // Save user data
        await _saveUserData(nom, telephone, email, userCredential.user!.uid);

        Navigator.pop(context); // Pop inscription page
        Navigator.pushNamed(context, '/home');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie avec Google'),
            backgroundColor: Color(0xFFA2B84E),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion annulée'),
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onFacebookLogin(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD48C41),
            ),
          );
        },
      );

      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

        // Sign in to Firebase
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

        // Get Facebook user data
        final userData = await FacebookAuth.instance.getUserData();
        String nom = userData['name'] ?? userCredential.user?.displayName ?? '';
        String email = userData['email'] ?? userCredential.user?.email ?? '';
        String telephone = userCredential.user?.phoneNumber ?? '';

        // Save user data
        await _saveUserData(nom, telephone, email, userCredential.user!.uid);

        Navigator.pop(context); // Remove loading
        Navigator.pop(context); // Pop inscription page
        Navigator.pushNamed(context, '/home');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie avec Facebook'),
            backgroundColor: Color(0xFFA2B84E),
          ),
        );
      } else {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connexion Facebook annulée: ${loginResult.message}'),
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur Facebook: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: SingleChildScrollView(
        child: Stack(
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
            Column(
              children: [
                const SizedBox(height: 90),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.getFont(
                          'Poppins',
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        children: const [
                          TextSpan(text: 'Créer un compte\n'),
                          TextSpan(
                            text: 'BestMlawi',
                            style: TextStyle(
                              color: Color(0xFFD48C41),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: TextFormField(
                    controller: txt_nom,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      labelStyle: GoogleFonts.getFont(
                        'Poppins',
                        color: const Color(0x7C000000),
                        fontSize: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFCCC5C5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFD48C41),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFF8EC),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: TextFormField(
                    controller: txt_telephone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      labelStyle: GoogleFonts.getFont(
                        'Poppins',
                        color: const Color(0x7C000000),
                        fontSize: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFCCC5C5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFD48C41),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFF8EC),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: TextFormField(
                    controller: txt_email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      labelStyle: GoogleFonts.getFont(
                        'Poppins',
                        color: const Color(0x7C000000),
                        fontSize: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFCCC5C5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFD48C41),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFF8EC),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: TextFormField(
                    controller: txt_password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: GoogleFonts.getFont(
                        'Poppins',
                        color: const Color(0x7C000000),
                        fontSize: 15,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0x7C000000),
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFCCC5C5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFD48C41),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFF8EC),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: TextFormField(
                    controller: txt_password_confirm,
                    obscureText: _obscurePasswordConfirm,
                    decoration: InputDecoration(
                      labelText: 'Répéter le mot de passe',
                      labelStyle: GoogleFonts.getFont(
                        'Poppins',
                        color: const Color(0x7C000000),
                        fontSize: 15,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: IconButton(
                          icon: Icon(
                            _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0x7C000000),
                          ),
                          onPressed: _togglePasswordConfirmVisibility,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFCCC5C5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color(0xFFD48C41),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFF8EC),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA2B84E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: () => _onInscription(context),
                      child: Text(
                        "S'inscrire",
                        style: GoogleFonts.getFont(
                          'PT Sans Caption',
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 33),
                        child: Divider(
                          color: Color(0xFFCCC5C5),
                          thickness: 1,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'ou avec',
                        style: TextStyle(
                          color: Color(0x84000000),
                          fontSize: 18,
                          fontFamily: 'AGA Arabesque Desktop',
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 33),
                        child: Divider(
                          color: Color(0xFFCCC5C5),
                          thickness: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8EC),
                            border: Border.all(
                              width: 2,
                              color: const Color(0xFFCCC5C5),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () => _onGoogleLogin(context),
                            child: Center(
                              child: Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F02ed273ff1e345ea23c44975182ac8d5d3eb3e8aimage%206.png?alt=media&token=bfe3c35b-2ff0-482f-b9c6-6abc7f51e401',
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8EC),
                            border: Border.all(
                              width: 2,
                              color: const Color(0xFFCCC5C5),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () => _onFacebookLogin(context),
                            child: Center(
                              child: Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fde6d6e3c1654216f90e733869293850fdd2a46f9image%209.png?alt=media&token=7e3be51e-f617-428c-8ac7-318c8ed85ef8',
                                width: 37,
                                height: 37,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 31),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.getFont(
                          'Roboto',
                          color: const Color(0x93000000),
                          fontSize: 16,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Vous avez déjà un compte ? '),
                          TextSpan(
                            text: 'Connectez-vous',
                            style: GoogleFonts.getFont(
                              'Roboto',
                              color: const Color(0xFFD48C41),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Text(
                    'En continuant, vous acceptez nos Conditions et\n notrePolitique de confidentialité.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont(
                      'PT Sans Caption',
                      color: const Color(0x75000000),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
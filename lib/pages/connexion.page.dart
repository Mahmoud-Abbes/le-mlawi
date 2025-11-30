import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../services/google_auth_service.dart';
import 'inscription.page.dart';

class ConnexionPage extends StatefulWidget {
  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  TextEditingController txt_email = TextEditingController();
  TextEditingController txt_password = TextEditingController();
  bool _motDePasseAffiche = true;

  void _togglePasswordVisibility() {
    setState(() {
      _motDePasseAffiche = !_motDePasseAffiche;
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      // Try to get data from Firestore first
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Save to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('nom', userData['nom'] ?? '');
        await prefs.setString('telephone', userData['telephone'] ?? '');
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setString('uid', uid);
      } else {
        // If no Firestore data, use Firebase Auth data
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('nom', user.displayName ?? '');
          await prefs.setString('telephone', user.phoneNumber ?? '');
          await prefs.setString('email', user.email ?? '');
          await prefs.setString('uid', uid);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _onConnexion(BuildContext context) async {
    String email = txt_email.text;
    String password = txt_password.text;

    if (email.isEmpty || password.isEmpty) {
      const snackBar = SnackBar(
        content: Text("Email ou mot de passe vide"),
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

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        // Load user data
        await _loadUserData(userCredential.user!.uid);

        Navigator.pop(context); // Remove loading
        Navigator.pushNamed(context, '/home');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie'),
            backgroundColor: Color(0xFFA2B84E),
          ),
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context); // Remove loading

        SnackBar snackBar;
        if (e.code == 'user-not-found') {
          snackBar = const SnackBar(
            content: Text('Aucun utilisateur trouvé avec cet email'),
          );
        } else if (e.code == 'wrong-password') {
          snackBar = const SnackBar(
            content: Text('Mot de passe incorrect'),
          );
        } else if (e.code == 'invalid-email') {
          snackBar = const SnackBar(
            content: Text('Email invalide'),
          );
        } else {
          snackBar = SnackBar(
            content: Text('Erreur: ${e.message}'),
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
        // Load user data
        await _loadUserData(userCredential.user!.uid);

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

        // Load user data
        await _loadUserData(userCredential.user!.uid);

        Navigator.pop(context); // Remove loading
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

  void _onSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InscriptionPage()),
    );
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
                const SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bienvenu  👋',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        color: const Color(0xFF3B2E1A),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bon retour, connectez-vous à votre compte.',
                      style: TextStyle(
                        color: Color(0x96000000),
                        fontSize: 16,
                        height: 1.5,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 31),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: TextFormField(
                    controller: txt_email,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: TextFormField(
                    controller: txt_password,
                    obscureText: _motDePasseAffiche,
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
                            _motDePasseAffiche ? Icons.visibility_off : Icons.visibility,
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
                  padding: const EdgeInsets.symmetric(horizontal: 38),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password page
                      },
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          color: Color(0xDDC4813B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 31),
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
                      onPressed: () => _onConnexion(context),
                      child: Text(
                        "Se connecter",
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 29),
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
                        padding: EdgeInsets.only(right: 29),
                        child: Divider(
                          color: Color(0xFFCCC5C5),
                          thickness: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF8EC),
                        side: const BorderSide(
                          width: 2.2,
                          color: Color(0xFFCCC5C5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      onPressed: () => _onGoogleLogin(context),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F02ed273ff1e345ea23c44975182ac8d5d3eb3e8aimage%206.png?alt=media&token=6a6f40c4-910b-45cb-b573-d15037c48521',
                                width: 25,
                                height: 25,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Google',
                              style: GoogleFonts.getFont(
                                'Poppins',
                                color: const Color(0xAA000000),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF8EC),
                        side: const BorderSide(
                          width: 2.2,
                          color: Color(0xFFCCC5C5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      onPressed: () => _onFacebookLogin(context),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Fde6d6e3c1654216f90e733869293850fdd2a46f9image%209.png?alt=media&token=d5d2ed79-9806-41bc-9038-65f666b2a4f1',
                                width: 25,
                                height: 25,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Facebook',
                              style: GoogleFonts.getFont(
                                'Poppins',
                                color: const Color(0xAA000000),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 31),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38),
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
                        const TextSpan(text: 'Vous n\'avez pas de compte ? '),
                        TextSpan(
                          text: 'Inscrivez-vous',
                          style: GoogleFonts.getFont(
                            'Roboto',
                            color: const Color(0xFFD48C41),
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _onSignUp(context),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 58),
                  child: Text(
                    'En continuant, vous acceptez nos Conditions\n et notre Politique de confidentialité.',
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
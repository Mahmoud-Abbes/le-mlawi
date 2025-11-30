import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/translation_config.dart';

class BottomNavBarAdmin extends StatefulWidget {
  final int selectedIndex;
  final void Function(int index) onItemTapped;

  const BottomNavBarAdmin({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<BottomNavBarAdmin> createState() => _BottomNavBarAdminState();
}

class _BottomNavBarAdminState extends State<BottomNavBarAdmin> {
  static const List<Map<String, String>> navItems = [
    {
      'label': 'Commandes',
      'icon': 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2F88b0657e-e276-4d5e-9c30-aa453c918908.png',
      'route': '/gestion_commandes'
    },
    {
      'label': 'Profile',
      'icon': 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2Fe15ac8f3-0c37-4cd3-968f-c87b20b72ee3.png',
      'route': '/admin_profile'
    },
  ];

  // Store translated labels
  Map<String, String> translatedLabels = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    // Translate all labels
    for (var item in navItems) {
      final label = item['label']!;
      final translated = await translate(label);
      translatedLabels[label] = translated;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 89,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border.all(
          width: 3,
          color: const Color(0xFFD3D3D3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
              (index) => _buildNavItem(
            context,
            navItems[index]['label']!,
            navItems[index]['icon']!,
            navItems[index]['route']!,
            index,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      String label,
      String iconUrl,
      String route,
      int index,
      ) {
    bool isSelected = widget.selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          splashColor: const Color(0xFF967217).withOpacity(0.2),
          highlightColor: const Color(0xFF967217).withOpacity(0.1),
          child: Container(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  iconUrl,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  color: isSelected
                      ? const Color(0xFF967217)
                      : const Color(0xFF636363),
                ),
                const SizedBox(height: 5),
                // Display translated label
                Text(
                  translatedLabels[label] ?? label,
                  style: GoogleFonts.getFont(
                    'Inter',
                    color: isSelected
                        ? const Color(0xFF967217)
                        : const Color(0xFF636363),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
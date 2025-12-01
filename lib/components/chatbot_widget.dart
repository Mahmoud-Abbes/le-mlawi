import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/global_params.dart';
import 'dart:math';

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

class ChatbotWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;

  const ChatbotWidget({
    Key? key,
    required this.isVisible,
    required this.onClose,
  }) : super(key: key);

  @override
  _ChatbotWidgetState createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  List<ChatMessage> chatMessages = [];
  TextEditingController chatController = TextEditingController();
  ScrollController _chatScrollController = ScrollController();
  bool isTyping = false;

  final List<Map<String, String>> predefinedQuestions = [
    {'question': '📦 Voir mes commandes', 'action': 'mes_commandes'},
    {'question': '🎲 Suggérer un produit', 'action': 'suggestion'},
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    if (chatMessages.isEmpty) {
      setState(() {
        chatMessages.add(ChatMessage(
          text: 'Bonjour! 👋 Je peux vous aider à consulter vos commandes ou vous suggérer des produits!',
          isBot: true,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<String> _handleUserQuery(String query) async {
    String lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('commande') || lowerQuery.contains('mes commandes')) {
      return await _getMyOrders();
    } else if (lowerQuery.contains('suggér') || lowerQuery.contains('produit') ||
        lowerQuery.contains('recommande') || lowerQuery.contains('suggestion')) {
      return _suggestRandomProduct();
    } else {
      return _handleUnknownQuery();
    }
  }

  String _handleUnknownQuery() {
    return '🤔 Désolé, je n\'ai pas compris votre question.\n\n'
        '✨ Voici ce que je peux faire:\n\n'
        '📦 Consulter vos commandes\n'
        '🎲 Suggérer un produit aléatoire\n\n'
        'Utilisez les boutons ci-dessous ou tapez votre question!';
  }

  Future<String> _getMyOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return '🔒 Vous devez être connecté pour voir vos commandes.';
      }

      // Try without orderBy first to avoid index issues
      final querySnapshot = await FirebaseFirestore.instance
          .collection('commandes')
          .where('userEmail', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return '📦 Vous n\'avez aucune commande pour le moment.\n\nCommencez vos achats!';
      }

      // Sort manually and take first 5
      var sortedDocs = querySnapshot.docs.toList();
      sortedDocs.sort((a, b) {
        Timestamp? aTime = a.data()['createdAt'] as Timestamp?;
        Timestamp? bTime = b.data()['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      String response = '📦 Vos commandes récentes:\n\n';
      int count = 0;

      for (var doc in sortedDocs.take(5)) {
        count++;
        final data = doc.data();
        String orderId = data['commandeId'] ?? doc.id;
        String status = data['etatCommande'] ?? 'En cours';
        dynamic totalPriceData = data['totalPrice'];

        double total = 0.0;
        if (totalPriceData is num) {
          total = totalPriceData.toDouble();
        } else if (totalPriceData is String) {
          total = double.tryParse(totalPriceData) ?? 0.0;
        }

        Timestamp? createdAt = data['createdAt'] as Timestamp?;

        String date = 'Date inconnue';
        if (createdAt != null) {
          final dateTime = createdAt.toDate();
          date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
        }

        response += '${count}. Commande #${orderId.substring(0, min(8, orderId.length))}\n';
        response += '   📍 Statut: $status\n';
        response += '   📅 Date: $date\n';
        response += '   💰 Total: ${total.toStringAsFixed(3)} DT\n\n';
      }

      return response + 'Voulez-vous une suggestion de produit? 🎲';
    } catch (e) {
      print('Error getting orders: $e');
      return '❌ Erreur: ${e.toString()}\n\nVérifiez vos données.';
    }
  }

  String _suggestRandomProduct() {
    try {
      if (GlobalParams.products.isEmpty) {
        return '🛍️ Aucun produit disponible pour le moment.\n\nRevenez plus tard!';
      }

      // Get random product
      final random = Random();
      final randomProduct = GlobalParams.products[random.nextInt(GlobalParams.products.length)];

      String name = randomProduct['name'] ?? 'Produit sans nom';
      dynamic priceData = randomProduct['price'];

      double price = 0.0;
      if (priceData is num) {
        price = priceData.toDouble();
      } else if (priceData is String) {
        price = double.tryParse(priceData) ?? 0.0;
      }

      String category = randomProduct['category'] ?? 'Général';
      String description = randomProduct['description'] ?? 'Pas de description disponible';

      String response = '🎲 Suggestion du jour:\n\n';
      response += '✨ $name\n\n';
      response += '💰 Prix: ${price.toStringAsFixed(3)} DT\n';
      response += '🏷️ Catégorie: $category\n\n';

      if (description.length > 100) {
        response += '📝 ${description.substring(0, 100)}...\n\n';
      } else {
        response += '📝 $description\n\n';
      }

      response += 'Intéressé? Recherchez-le dans l\'application!';

      return response;
    } catch (e) {
      print('Error suggesting product: $e');
      return '❌ Impossible de suggérer un produit pour le moment.';
    }
  }

  void _sendChatMessage() async {
    if (chatController.text.isEmpty) return;

    String userMessage = chatController.text;

    setState(() {
      chatMessages.add(ChatMessage(
        text: userMessage,
        isBot: false,
        timestamp: DateTime.now(),
      ));
      chatController.clear();
      isTyping = true;
    });

    _scrollToBottom();

    // Small delay for better UX
    await Future.delayed(Duration(milliseconds: 500));

    String botResponse = await _handleUserQuery(userMessage);

    setState(() {
      chatMessages.add(ChatMessage(
        text: botResponse,
        isBot: true,
        timestamp: DateTime.now(),
      ));
      isTyping = false;
    });

    _scrollToBottom();
  }

  void _selectPredefinedQuestion(String question, String action) async {
    setState(() {
      chatMessages.add(ChatMessage(
        text: question,
        isBot: false,
        timestamp: DateTime.now(),
      ));
      isTyping = true;
    });

    _scrollToBottom();

    await Future.delayed(Duration(milliseconds: 500));

    String botResponse;
    if (action == 'mes_commandes') {
      botResponse = await _getMyOrders();
    } else if (action == 'suggestion') {
      botResponse = _suggestRandomProduct();
    } else {
      botResponse = _handleUnknownQuery();
    }

    setState(() {
      chatMessages.add(ChatMessage(
        text: botResponse,
        isBot: true,
        timestamp: DateTime.now(),
      ));
      isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return SizedBox.shrink();

    return Positioned(
      bottom: 80,
      right: 16,
      child: Container(
        width: 360,
        height: 550,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD48C41),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assistant BestMlawi',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'En ligne',
                            style: GoogleFonts.getFont(
                              'Poppins',
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages area
            Expanded(
              child: chatMessages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: _chatScrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chatMessages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < chatMessages.length) {
                    final message = chatMessages[index];
                    return _buildMessageBubble(message);
                  } else {
                    return _buildTypingIndicator();
                  }
                },
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: chatController,
                        onSubmitted: (_) => _sendChatMessage(),
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Votre message...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          hintStyle: GoogleFonts.getFont(
                            'Poppins',
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendChatMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD48C41),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isBot
              ? const Color(0xFFF5F7FB)
              : const Color(0xFFD48C41),
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          message.text,
          style: GoogleFonts.getFont(
            'Poppins',
            color:
            message.isBot ? const Color(0xFF3B2E1A) : Colors.white,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD48C41),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD48C41).withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFD48C41).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD48C41).withOpacity(0.1),
                    const Color(0xFFD48C41).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Color(0xFFD48C41),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bonjour! 👋',
              style: GoogleFonts.getFont(
                'Poppins',
                color: const Color(0xFF3B2E1A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commandes et suggestions de produits',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                'Poppins',
                color: const Color(0xFFACACAC),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Actions rapides:',
              style: GoogleFonts.getFont(
                'Poppins',
                color: const Color(0xFF3B2E1A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...predefinedQuestions.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _selectPredefinedQuestion(
                    item['question']!,
                    item['action']!,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      item['question']!,
                      style: GoogleFonts.getFont(
                        'Poppins',
                        color: const Color(0xFF3B2E1A),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
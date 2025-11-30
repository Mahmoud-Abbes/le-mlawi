import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final String? messageType;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
    this.quickReplies,
    this.messageType = 'text',
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
    {'question': '🛍 Quels produits avez-vous?', 'category': 'produits'},
    {'question': '🚚 Comment fonctionne la livraison?', 'category': 'livraison'},
    {'question': '💰 Quel est le prix?', 'category': 'prix'},
    {'question': '📞 Comment contacter le support?', 'category': 'support'},
    {'question': '❓ Comment passer une commande?', 'category': 'commande'},
    {'question': '🔄 Quelle est votre politique de retour?', 'category': 'retour'},
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
          text: 'Bonjour! 👋 Je suis l\'assistant BestMlawi. Comment puis-je vous aider aujourd\'hui?',
          isBot: true,
          timestamp: DateTime.now(),
          messageType: 'welcome',
        ));
      });
    }
  }

  String _generateDetailedResponse(String userMessage) {
    String lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('produit') || lowerMessage.contains('quoi')) {
      return 'Nous proposons une large gamme de produits de haute qualité!\n\n'
          '📦 Nos catégories principales:\n'
          '• Électronique\n• Mode\n• Maison\n• Beauté\n• Sport\n\n'
          '✨ Tous nos produits sont:\n'
          '• Contrôlés de qualité\n• Avec garantie\n• Livrés rapidement\n\n'
          'Vous pouvez rechercher par catégorie ou utiliser la barre de recherche!';
    }
    else if (lowerMessage.contains('livraison')) {
      return '🚚 Informations de livraison:\n\n'
          '⏱ Délais:\n• Livraison standard: 2-3 jours\n• Livraison express: 24h\n\n'
          '🗺 Zones de couverture:\n• Tunis et proches banlieues\n• Région côtière\n• Autres régions sur demande\n\n'
          '💵 Frais de livraison:\n• À partir de 5 DT\n• Gratuite à partir de 100 DT';
    }
    else if (lowerMessage.contains('prix') || lowerMessage.contains('coût')) {
      return '💰 Politique tarifaire:\n\n'
          '💎 Nos prix:\n• Compétitifs et transparents\n• Sans frais cachés\n• Affichés TTC\n\n'
          '🎁 Promotions actuelles:\n• Réductions saisonnières\n• Offres spéciales membres\n• Codes promo réguliers';
    }
    else if (lowerMessage.contains('support') || lowerMessage.contains('contact')) {
      return '📞 Nous sommes là pour vous!\n\n'
          '💬 Canaux de contact:\n• Chat en direct: 24h/24\n• Email: support@bestmlawi.tn\n• Téléphone: +216 XX XXX XXX\n\n'
          '🕐 Horaires:\n• Lun-Ven: 8h-20h\n• Sam: 9h-18h\n• Dim: 10h-16h';
    }
    else if (lowerMessage.contains('commande') || lowerMessage.contains('commander')) {
      return '📋 Comment passer une commande:\n\n'
          '1️⃣ Recherchez vos produits\n2️⃣ Sélectionnez les produits\n3️⃣ Procédez à la commande\n4️⃣ Confirmez le paiement\n5️⃣ Recevez votre colis';
    }
    else if (lowerMessage.contains('retour') || lowerMessage.contains('remboursement')) {
      return '🔄 Politique de retour:\n\n'
          '📅 Délai de rétractation:\n• 14 jours à partir de la réception\n• Sans justification\n• Gratuit\n\n'
          '✅ Conditions:\n• Produit non utilisé\n• Emballage intact\n• Avec tous les accessoires';
    }
    else if (lowerMessage.contains('paiement')) {
      return '💳 Modes de paiement:\n\n'
          '🏦 Options disponibles:\n• Carte bancaire (Visa/Mastercard)\n• Virement bancaire\n• Porte-monnaie digital\n• Paiement à la livraison\n\n'
          '🔒 Sécurité:\n• Chiffrement SSL 256-bit\n• Données protégées\n• Conforme PCI DSS';
    }
    else if (lowerMessage.contains('compte') || lowerMessage.contains('profil')) {
      return '👤 Gestion de compte:\n\n'
          '📝 Inscription:\n• Gratuite et rapide\n• Email + mot de passe\n• Confirmation par email\n\n'
          '👥 Avantages membres:\n• Historique d\'achats\n• Adresses sauvegardées\n• Programme de fidélité\n• Offres exclusives';
    }
    else {
      return '🤔 Je n\'ai pas bien compris votre question.\n\n'
          '📚 Je peux vous aider avec:\n• 🛍 Recherche de produits\n• 🚚 Informations de livraison\n• 💰 Tarification\n• 📞 Support client\n• 📋 Passage de commande\n• 🔄 Retours\n• 💳 Paiements\n• 👤 Compte utilisateur\n\n'
          'Pouvez-vous préciser votre question?';
    }
  }

  void _sendChatMessage() {
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

    // Auto-scroll to bottom
    Future.delayed(Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate bot thinking and response
    Future.delayed(Duration(milliseconds: 1200), () {
      String botResponse = _generateDetailedResponse(userMessage);

      setState(() {
        chatMessages.add(ChatMessage(
          text: botResponse,
          isBot: true,
          timestamp: DateTime.now(),
          messageType: 'text',
        ));
        isTyping = false;
      });

      // Auto-scroll after bot response
      Future.delayed(Duration(milliseconds: 100), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _selectPredefinedQuestion(String question) {
    chatController.text = question.replaceFirst(RegExp(r'^[🛍🚚💰📞📋🔄] '), '');
    _sendChatMessage();
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
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: chatController,
                              onSubmitted: (_) => _sendChatMessage(),
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: 'Votre message...',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                hintStyle: GoogleFonts.getFont(
                                  'Poppins',
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
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
          color: message.isBot ? const Color(0xFFF5F7FB) : const Color(0xFFD48C41),
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          message.text,
          style: GoogleFonts.getFont(
            'Poppins',
            color: message.isBot ? const Color(0xFF3B2E1A) : Colors.white,
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
              'Je suis l\'assistant BestMlawi',
              textAlign: TextAlign.center,
              style: GoogleFonts.getFont(
                'Poppins',
                color: const Color(0xFFACACAC),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Questions fréquentes:',
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
                  onTap: () => _selectPredefinedQuestion(item['question']!),
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
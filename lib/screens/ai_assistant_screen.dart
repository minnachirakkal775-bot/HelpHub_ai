import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';

class AiAssistantPanel extends StatefulWidget {
  const AiAssistantPanel({super.key});

  @override
  State<AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _AiAssistantPanelState extends State<AiAssistantPanel> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAiTyping = false;

  // Base list containing the initial welcome card context
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your HelpHub AI Assistant. How can I assist you with emergency or local care coordination today?',
      'isUser': false,
    }
  ];

  // Quick Action Selection Prompts
  final List<String> _suggestions = [
    "Find Blood Donors",
    "How to trigger SOS?",
    "Report Lost Item",
    "Volunteer Opportunities"
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage({String? customText}) async {
    final String userText = customText ?? _messageController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({'text': userText, 'isUser': true});
      if (customText == null) _messageController.clear();
      _isAiTyping = true;
    });
    _scrollToBottom();

    try {
      final String? apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("Your .env file or GROQ_API_KEY variable is missing or blank!");
      }

      final client = OpenAIClient(
        apiKey: apiKey,
        baseUrl: 'https://api.groq.com/openai/v1',
      );

      // FIXED: Added .timeout() to stop the typing indicator if the network request hangs
      final response = await client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('llama-3.1-8b-instant'),
          maxTokens: 120,
          temperature: 0.5,
          messages: [
            ChatCompletionMessage.system(
                content: "You are HelpHub AI, a professional assistant for a community coordination app. "
                    "You help users manage emergency, blood coordination, and lost & found workflows. "
                    "Keep all answers friendly, precise, and concise (under 3 sentences)."
            ),
            ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(userText)
            ),
          ],
        ),
      ).timeout(const Duration(seconds: 7)); // ⏱️ Stops hanging after 7 seconds

      final String aiResponse = response.choices.first.message.content ?? "I didn't receive a message context from the server.";

      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add({'text': aiResponse, 'isUser': false});
        });
      }
    } catch (e) {
      debugPrint("🚨 HelpHub Connection Failure: $e");
      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add({
            'text': "Connection error ($e). Please check your internet connection or API credentials.",
            'isUser': false
          });
        });
      }
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Sky Blue Background Canvas
      appBar: AppBar(
        title: const Text('HelpHub AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1), // Dark Blue Brand Accent
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Scrollable Chat Message Viewport Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return const _AiTypingIndicator();

                final msg = _messages[index];
                final bool isUser = msg['isUser'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        const CircleAvatar(
                          backgroundColor: Color(0xFF0D47A1),
                          radius: 16,
                          child: Icon(Icons.psychology, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFF0D47A1) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser ? Colors.white : Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Suggestion Prompt Chips Row
          if (_messages.length == 1 && !_isAiTyping)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestions.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(_suggestions[i]),
                      labelStyle: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.w600, fontSize: 12),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFB3E5FC)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () => _handleSendMessage(customText: _suggestions[i]),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),

          // Modern Footer Input Control Panel
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _messageController,
                      cursorColor: const Color(0xFF0D47A1),
                      decoration: const InputDecoration(
                        hintText: 'Ask about HelpHub or emergencies...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0D47A1),
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _handleSendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiTypingIndicator extends StatefulWidget {
  const _AiTypingIndicator();

  @override
  State<_AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<_AiTypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF0D47A1),
              radius: 16,
              child: Icon(Icons.psychology, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      double opacity = ((_controller.value * 3 - index) % 3) / 3;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: const Color(0xFF0D47A1).withOpacity(opacity.clamp(0.2, 1.0)), shape: BoxShape.circle),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
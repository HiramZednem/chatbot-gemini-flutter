import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speechToText = stt.SpeechToText();

  List<Map<String, String>> messages = [];
  bool isConnected = true;
  bool isListening = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }



  // Carga mensajes del historial
  Future<void> loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedMessages = prefs.getString('chatHistory');
    if (storedMessages != null) {
      List<dynamic> decodedList = json.decode(storedMessages);
      setState(() {
        messages = decodedList.map((message) {
          return Map<String, String>.from(message);
        }).toList();
      });
    }
  }

  Future<void> clearMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatHistory');
    //await speak('La conversación ha sido eliminada.');
    await flutterTts.stop();
    setState(() {
      messages.clear();
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonMessages = json.encode(messages);
    await prefs.setString('chatHistory', jsonMessages);
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  // Reconocimiento de voz
  Future<void> startListening() async {
    bool available = await speechToText.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (available) {
      setState(() {
        isListening = true;
      });

      speechToText.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void stopListening() {
    speechToText.stop();
    setState(() {
      isListening = false;
    });
  }

  void sendMessage() async {
    if(_controller.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    String userMessage = _controller.text;
    setState(() {
      messages.add({'role': 'user', 'message': userMessage});
    });

    await saveMessages();
    _scrollToBottom();
    _controller.clear();

    String context = messages
        .map((message) => '${message['role']}: ${message['message']}')
        .join('\n');

    String prompt = '''
You are an assistant specialized in answering questions briefly and accurately.

Conversation context: $context

User's question: $userMessage

Respond concisely, with a maximum of 2 to 3 sentences.
''';

    String botResponse = await apiService.getResponse(prompt);

    setState(() {
      isLoading = false;
      messages.add({'role': 'bot', 'message': botResponse});
    });

    await saveMessages();
    _scrollToBottom();
    await speak(botResponse);
  }

  void _scrollToBottom() {
    // Verifica si el controlador está adjunto antes de usarlo
    if (_scrollController.hasClients) {
      // Desplazarse hacia el final de la lista
      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent + 130);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                          child: Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 157, 150, 128)),
                          ),
                        ),
                      )),
                    ],
                  );
                }

                final message = messages[index];
                final isUserMessage = message['role'] == 'user';

                return Row(
                  mainAxisAlignment: isUserMessage
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUserMessage ? Colors.orange : const Color.fromARGB(255, 157, 150, 128),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    cursorColor: Colors.orange,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.orange,
                        width: 1.5,
                      )),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.orange,
                  ),
                  onPressed: isListening ? stopListening : startListening,
                ),
                IconButton(
                    icon: const Icon(Icons.send, color: Colors.orange),
                    onPressed: isConnected ? sendMessage : null),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String _apiKey = "AIzaSyAOXEInTeZIX2ZgQajoKvZgzMA7jKSQMAo";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: '', apiKey: _apiKey);
    _chat = _model.startChat();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      );
    });
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isLoading = true;
    });

    _textController.clear();
    _scrollDown();

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      setState(() {
        _messages.add(ChatMessage(text: text!, isUser: false));
        _isLoading = false;
        _scrollDown();
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error Occurred", isUser: false));
        _isLoading = false;
      });
    }
  }

  void _showAssistant() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المساعد الشخصي',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'معك أنس مرافقك الشخصي كيف أقدر أساعدك',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendChatMessage('ما هي المساعدة الي تقدر تقدمها ؟ ');
                },
                child: Text('طلب مساعدة'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          centerTitle: true,
          
          actions: [
            PopupMenuButton<int>(
              onSelected: (item) => onSelected(context, item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 0, child: Text('إعدادات')),
                PopupMenuItem<int>(value: 1, child: Text('عنك')),
              ],
            ),
          ],
          flexibleSpace: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 30,
                left: 16,
                right: 16,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'تجربة الشات بالذكاء الاصطناعي!',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.lightBlue[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return ChatBubble(message: message);
                  },
                ),
              ),
              if (_isLoading) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: _sendChatMessage,
                      ),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: () => _sendChatMessage(_textController.text),
                      child: Icon(Icons.send),
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: GestureDetector(
              onTap: _showAssistant,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.purple,
                child: Icon(
                  Icons.android,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      case 1:
        showAboutDialog(
          context: context,
          applicationName: 'تطبيق الدردشة بالذكاء الاصطناعي',
          applicationVersion: '1.0.0',
          applicationIcon: Icon(Icons.chat),
          children: [Text('هذا تطبيق دردشة يستخدم الذكاء الاصطناعي.')],
        );
        break;
    }
  }
}

class ChatMessage {
  String text;
  bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
      ),
      body: Center(
        child: Text('صفحة الإعدادات'),
      ),
    );
  }
}

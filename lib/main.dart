import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:flutter_tts/flutter_tts.dart';

// FFI type definitions
typedef GreetFunc = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);
typedef Greet = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);
typedef SpeakFunc = ffi.Void Function(ffi.Pointer<Utf8>);
typedef Speak = void Function(ffi.Pointer<Utf8>);
typedef SpeakWithPiperFunc = ffi.Void Function(ffi.Pointer<Utf8>);
typedef SpeakWithPiper = void Function(ffi.Pointer<Utf8>);
typedef GetAIResponseFunc = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);
typedef GetAIResponse = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);
typedef ProcessEmotionFunc = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);
typedef ProcessEmotion = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>);

// Load dynamic library with error handling
ffi.DynamicLibrary? dylib;
Greet? greetRust;
Speak? speakRust;
SpeakWithPiper? speakWithPiperRust;
GetAIResponse? getAIResponseRust;
ProcessEmotion? processEmotionRust;

// Text-to-Speech instance
FlutterTts? flutterTts;

void initializeRustBackend() {
  try {
    dylib = Platform.isWindows 
        ? ffi.DynamicLibrary.open('rust_backend.dll')
        : Platform.isAndroid
            ? ffi.DynamicLibrary.open("librust_backend.so")
            : ffi.DynamicLibrary.process();

    // FFI function bindings
    greetRust = dylib!
        .lookup<ffi.NativeFunction<GreetFunc>>("greet_user")
        .asFunction();

    speakRust = dylib!
        .lookup<ffi.NativeFunction<SpeakFunc>>("speak_text")
        .asFunction();

    speakWithPiperRust = dylib!
        .lookup<ffi.NativeFunction<SpeakWithPiperFunc>>("speak_with_piper")
        .asFunction();

    getAIResponseRust = dylib!
        .lookup<ffi.NativeFunction<GetAIResponseFunc>>("get_ai_response")
        .asFunction();

    processEmotionRust = dylib!
        .lookup<ffi.NativeFunction<ProcessEmotionFunc>>("process_emotion")
        .asFunction();
  } catch (e) {
    print('Failed to load Rust backend: $e');
    // Functions will remain null and fallback responses will be used
  }
}

// Voice configuration options
Map<String, String> availableLanguages = {
  'English (US)': 'en-US',
  'Arabic': 'ar',
  'English (UK)': 'en-GB',
  'French': 'fr-FR',
  'Spanish': 'es-ES',
  'German': 'de-DE',
};

String currentLanguage = 'en-US';
double currentSpeechRate = 0.5;
double currentVolume = 0.8;
double currentPitch = 1.0;

Future<void> initializeTts() async {
  try {
    flutterTts = FlutterTts();
    
    // Configure TTS settings
    await flutterTts!.setLanguage(currentLanguage);
    await flutterTts!.setSpeechRate(currentSpeechRate);
    await flutterTts!.setVolume(currentVolume);
    await flutterTts!.setPitch(currentPitch);
    
    print('TTS initialized successfully with language: $currentLanguage');
  } catch (e) {
    print('Failed to initialize TTS: $e');
    flutterTts = null;
  }
}

// Function to change voice settings
Future<void> updateVoiceSettings({
  String? language,
  double? speechRate,
  double? volume,
  double? pitch,
}) async {
  if (flutterTts == null) return;
  
  try {
    if (language != null) {
      currentLanguage = language;
      await flutterTts!.setLanguage(language);
    }
    if (speechRate != null) {
      currentSpeechRate = speechRate;
      await flutterTts!.setSpeechRate(speechRate);
    }
    if (volume != null) {
      currentVolume = volume;
      await flutterTts!.setVolume(volume);
    }
    if (pitch != null) {
      currentPitch = pitch;
      await flutterTts!.setPitch(pitch);
    }
    print('Voice settings updated successfully');
  } catch (e) {
    print('Failed to update voice settings: $e');
  }
}

// Function to get available voices
Future<List<dynamic>> getAvailableVoices() async {
  if (flutterTts == null) return [];
  try {
    return await flutterTts!.getVoices;
  } catch (e) {
    print('Failed to get available voices: $e');
    return [];
  }
}

// Rust FFI Integration Functions with fallback
String greetUser(String name) {
  if (greetRust != null) {
    try {
      final namePtr = name.toNativeUtf8();
      final resultPtr = greetRust!(namePtr);
      final result = resultPtr.toDartString();
      return result;
    } catch (e) {
      print('Error calling greetRust: $e');
    }
  }
  // Fallback response
  return "As-salāmu ʿalaykum, $name! Welcome to Akhī, your Islamic companion.";
}

Future<void> speakText(String text) async {
  if (speakRust != null) {
    try {
      final textPtr = text.toNativeUtf8();
      speakRust!(textPtr);
      return;
    } catch (e) {
      print('Error calling speakRust: $e');
    }
  }
  
  // Fallback: use Flutter TTS
  if (flutterTts != null) {
    try {
      await flutterTts!.speak(text);
      return;
    } catch (e) {
      print('Error with TTS: $e');
    }
  }
  
  // Final fallback: print to console
  print('Speaking: $text');
}

Future<void> speakWithPiper(String text) async {
  if (speakWithPiperRust != null) {
    try {
      final textPtr = text.toNativeUtf8();
      speakWithPiperRust!(textPtr);
      return;
    } catch (e) {
      print('Error calling speakWithPiperRust: $e');
    }
  }
  // Fallback to regular speak
  await speakText(text);
}

String getAIResponse(String input) {
  if (getAIResponseRust != null) {
    try {
      final inputPtr = input.toNativeUtf8();
      final resultPtr = getAIResponseRust!(inputPtr);
      final result = resultPtr.toDartString();
      return result;
    } catch (e) {
      print('Error calling getAIResponseRust: $e');
    }
  }
  // Fallback responses
  final responses = [
    "SubhanAllah, that's a thoughtful question, akhī. May Allah guide us both.",
    "Alhamdulillah for your curiosity. Let's reflect on this together.",
    "MashaAllah, I appreciate you sharing this with me, brother.",
    "May Allah grant you wisdom and peace in this matter.",
    "Barakallahu feek for reaching out. Let's seek guidance together."
  ];
  return responses[input.length % responses.length];
}

String processEmotion(String emotion) {
  if (processEmotionRust != null) {
    try {
      final emotionPtr = emotion.toNativeUtf8();
      final resultPtr = processEmotionRust!(emotionPtr);
      final result = resultPtr.toDartString();
      return result;
    } catch (e) {
      print('Error calling processEmotionRust: $e');
    }
  }
  // Fallback emotional responses
  switch (emotion.toLowerCase()) {
    case 'grateful':
      return "Alhamdulillahi rabbil alameen! Gratitude is a beautiful quality, akhī. Allah loves those who are thankful.";
    case 'anxious':
      return "I understand, akhī. Remember: 'And whoever relies upon Allah - then He is sufficient for him.' (Quran 65:3). Take deep breaths and make du'a.";
    case 'peaceful':
      return "SubhanAllah! Inner peace is a gift from Allah. May He continue to bless you with tranquility.";
    case 'confused':
      return "It's okay to feel confused sometimes, brother. Seek guidance through prayer and reflection. Allah will show you the way.";
    case 'joyful':
      return "MashaAllah! Your joy brings light to my heart. Remember to thank Allah for these beautiful moments.";
    default:
      return "Whatever you're feeling, akhī, remember that Allah is with you. Turn to Him in prayer and find comfort in His mercy.";
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeRustBackend();
  await initializeTts();
  runApp(ProviderScope(child: AkhiApp()));
}

class AkhiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akhī',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String greeting = "";
  String currentResponse = "";
  bool isLoading = false;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() {
    final result = greetUser("Akhī");
    setState(() {
      greeting = result;
      _messages.add(ChatMessage(text: result, isUser: false));
    });
  }

  void _handleEmotionSelection(String emotion) {
    setState(() {
      isLoading = true;
    });
    
    final response = processEmotion(emotion);
    
    setState(() {
      isLoading = false;
      _messages.add(ChatMessage(text: "I'm feeling $emotion", isUser: true));
      _messages.add(ChatMessage(text: response, isUser: false));
    });
    
    _speakText(response); // Fire and forget async call
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      isLoading = true;
    });
    
    _messageController.clear();
    
    final aiResponse = getAIResponse(userMessage);
    setState(() {
      _messages.add(ChatMessage(text: aiResponse, isUser: false));
      isLoading = false;
    });
    
    _speakText(aiResponse); // Fire and forget async call
  }

  Future<void> _speakText(String text) async {
    // Use Piper TTS for better voice quality
    await speakWithPiper(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akhī – Your Companion'),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: () => _speakText("As-salāmu ʿalaykum, akhī"), // Fire and forget async call
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VoiceSettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Daily Check-in Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade900.withOpacity(0.3),
              border: Border(bottom: BorderSide(color: Colors.teal.shade700)),
            ),
            child: Column(
              children: [
                Text(
                  "How is your heart today, akhī?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _EmotionButton(
                      emoji: "😔",
                      label: "Sad",
                      onPressed: () => _handleEmotionSelection("sad"),
                    ),
                    _EmotionButton(
                      emoji: "😠",
                      label: "Angry",
                      onPressed: () => _handleEmotionSelection("angry"),
                    ),
                    _EmotionButton(
                      emoji: "😴",
                      label: "Tired",
                      onPressed: () => _handleEmotionSelection("tired"),
                    ),
                    _EmotionButton(
                      emoji: "🕊️",
                      label: "Peaceful",
                      onPressed: () => _handleEmotionSelection("peaceful"),
                    ),
                    _EmotionButton(
                      emoji: "🤲",
                      label: "Need Duʿā",
                      onPressed: () => _handleEmotionSelection("need_dua"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          
          // Loading indicator
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(color: Colors.teal),
            ),
          
          // Message input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(top: BorderSide(color: Colors.teal.shade700)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Share what's on your heart...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.teal.shade700),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: Colors.teal),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class _EmotionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onPressed;

  const _EmotionButton({
    required this.emoji,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.teal.shade700,
              child: Text("🕌", style: TextStyle(fontSize: 16)),
              radius: 16,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.teal.shade700
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey.shade700,
              child: Text("👤", style: TextStyle(fontSize: 16)),
              radius: 16,
            ),
          ],
        ],
      ),
    );
  }
}

// Voice Settings Screen
class VoiceSettingsScreen extends StatefulWidget {
  @override
  _VoiceSettingsScreenState createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  String selectedLanguage = currentLanguage;
  double speechRate = currentSpeechRate;
  double volume = currentVolume;
  double pitch = currentPitch;
  List<dynamic> availableVoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableVoices();
  }

  Future<void> _loadAvailableVoices() async {
    final voices = await getAvailableVoices();
    setState(() {
      availableVoices = voices;
      isLoading = false;
    });
  }

  Future<void> _applySettings() async {
    await updateVoiceSettings(
      language: selectedLanguage,
      speechRate: speechRate,
      volume: volume,
      pitch: pitch,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice settings updated!'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Future<void> _testVoice() async {
    await speakText('As-salāmu ʿalaykum! This is how I sound with the current settings.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Settings'),
        backgroundColor: Colors.teal.shade800,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Selection
                  Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        dropdownColor: Colors.grey.shade800,
                        style: TextStyle(color: Colors.white),
                        items: availableLanguages.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.value,
                            child: Text(entry.key),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedLanguage = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Speech Rate
                  Text(
                    'Speech Rate: ${speechRate.toStringAsFixed(1)}x',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Slider(
                    value: speechRate,
                    min: 0.1,
                    max: 2.0,
                    divisions: 19,
                    activeColor: Colors.teal,
                    inactiveColor: Colors.teal.shade200,
                    onChanged: (double value) {
                      setState(() {
                        speechRate = value;
                      });
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Volume
                  Text(
                    'Volume: ${(volume * 100).round()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: Colors.teal,
                    inactiveColor: Colors.teal.shade200,
                    onChanged: (double value) {
                      setState(() {
                        volume = value;
                      });
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Pitch
                  Text(
                    'Pitch: ${pitch.toStringAsFixed(1)}x',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Slider(
                    value: pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    activeColor: Colors.teal,
                    inactiveColor: Colors.teal.shade200,
                    onChanged: (double value) {
                      setState(() {
                        pitch = value;
                      });
                    },
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _testVoice,
                          icon: Icon(Icons.play_arrow),
                          label: Text('Test Voice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _applySettings,
                          icon: Icon(Icons.check),
                          label: Text('Apply Settings'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Available Voices Info
                  if (availableVoices.isNotEmpty) ...[
                    Text(
                      'Available Voices: ${availableVoices.length}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 100,
                      child: ListView.builder(
                        itemCount: availableVoices.length > 5 ? 5 : availableVoices.length,
                        itemBuilder: (context, index) {
                          final voice = availableVoices[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              voice['name'] ?? 'Unknown Voice',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            subtitle: Text(
                              voice['locale'] ?? 'Unknown Locale',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 16),
                  
                  // Reset to Defaults
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedLanguage = 'en-US';
                          speechRate = 0.5;
                          volume = 0.8;
                          pitch = 1.0;
                        });
                      },
                      child: Text(
                        'Reset to Defaults',
                        style: TextStyle(color: Colors.teal.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// UTF8 conversion methods are provided by the ffi package

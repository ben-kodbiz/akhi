# Akhi AI Python Backend

This is the Python backend implementation for the Akhi AI app, providing LLM inference and TTS functionality as an alternative to the Rust backend.

## Features

- **Enhanced Islamic Response System**: Contextual responses based on emotional state detection
- **System Prompt Integration**: Loads configuration from `akhi_prompt.json`
- **Emotional Support Flow**: Detects user emotions and provides appropriate Islamic guidance
- **Command Line Interface**: Easy integration with Flutter app
- **Extensible Architecture**: Ready for Gemma model integration

## Installation

```bash
cd python-backend
pip install -r requirements.txt
```

## Usage

### Command Line Interface

```bash
# Greet user
python main.py greet [name]

# Get AI response
python main.py ai_response "Your message here"

# Process emotion
python main.py emotion sad|angry|tired|peaceful|need_dua

# Text-to-speech (placeholder)
python main.py speak "Text to speak"
```

### Examples

```bash
# Basic greeting
python main.py greet "Ahmad"

# Get Islamic guidance
python main.py ai_response "I'm feeling overwhelmed with work"

# Emotional check-in
python main.py emotion sad

# Request for dua
python main.py ai_response "Can you share a dua for guidance?"
```

## Integration with Flutter

The Flutter app can call this Python backend using `Process.run()` or similar methods:

```dart
// Example Flutter integration
final result = await Process.run(
  'python',
  ['f:\\akhi\\python-backend\\main.py', 'ai_response', userMessage],
);
final response = result.stdout.toString().trim();
```

## Features Implemented

### Phase 4: Emotional Support Flow ✅
- Emotion detection from user input
- Contextual Islamic responses based on emotional state
- Support for various emotions: sadness, anger, tiredness, peace, gratitude
- Dua and prayer guidance
- Loneliness and isolation support

### Enhanced Response Categories
- **Sadness/Depression**: Quranic verses about patience and Allah's mercy
- **Anger/Frustration**: Prophetic guidance on anger management
- **Tiredness/Exhaustion**: Islamic perspective on rest and self-care
- **Peace/Gratitude**: Encouragement and gratitude reminders
- **Spiritual Guidance**: Duas and Islamic teachings
- **Loneliness**: Community and connection with Allah

## Future Enhancements

- **Gemma Model Integration**: Replace rule-based responses with actual LLM inference
- **Piper TTS Integration**: Add real text-to-speech functionality
- **Advanced Emotion Detection**: More sophisticated NLP for emotion recognition
- **Personalization**: User-specific response patterns
- **Multi-language Support**: Arabic and other languages

## Architecture

```
AkhiBackend
├── load_system_prompt()     # Load configuration
├── initialize_llm()         # LLM setup (placeholder)
├── generate_islamic_response()  # Core response logic
├── generate_enhanced_islamic_response()  # Enhanced with context
├── get_ai_response()        # Main API endpoint
├── process_emotion()        # Emotional check-in
├── greet_user()            # User greeting
└── speak_text()            # TTS placeholder
```

## Configuration

The backend loads system prompts from `../akhi_prompt.json`. Ensure this file exists with the proper configuration:

```json
{
  "system_prompt": "You are Akhī, a compassionate AI companion for Muslim men..."
}
```

## Testing

Run the backend directly to test functionality:

```bash
python main.py ai_response "As-salamu alaikum, how are you?"
```

Expected output: Islamic greeting and supportive response.
Excellent. Using **Gemma Sutra 3GB** is a practical choice—it’s **compact**, **fast**, and reasonably capable for mobile or low-resource devices. You **can fine-tune it or apply a LoRA adapter** for Islamic content like **Qur’an, Hadith, and quotes from scholars**.

That said, **you’ll want to be very intentional with the tone, boundaries, and accuracy**, especially when the app speaks on Islamic matters. Your fine-tuning should focus on:

* **Tone shaping** (calm, non-preachy, respectful)
* **Quote formatting** (attribution to authentic sources)
* **Scenario-based responses** (e.g., when user says "I feel hopeless", it shares a Qur’anic reminder + duʿā)

---

Here’s your complete `.md` file for your devs:

---

````markdown
# 📱 Akhī: Offline Muslim Male AI Companion (MVP)

**Goal**: Build a minimal, emotionally supportive AI companion for Muslim men, grounded in Islamic values, Hadith, and quotes from scholars, that works entirely offline.

---

## ✅ Core MVP Features

| Feature                      | Description |
|-----------------------------|-------------|
| 💬 Chat Interface            | User can talk to the AI via text |
| 🧠 Gemma Sutra 3B (3GB)      | Powers all local AI chat, fine-tuned or LoRA for Islamic tone |
| 📖 Daily Islamic Reminder    | Qur’anic verse, Hadith, or quote from a scholar |
| 🤲 Duʿā Suggestions          | Based on user's emotion or input |
| 📓 Mood Check-in             | "How is your heart today?" → saved in SQLite |
| 🗣️ TTS (Voice Playback)      | Piper reads duʿā or reminder aloud in soothing male voice |
| 🕋 Islamic Personality        | Calm, non-fatwa-giving, grounded in Sunnah |
| 📂 Local Content Storage     | Hadith, Duʿā, Ayāt, quotes stored offline (JSON or SQLite) |

---

## 🛠 Technology Stack

### 🔮 AI & NLP

| Component       | Tool/Model              |
|----------------|-------------------------|
| LLM            | **Gemma Sutra 3B (GGUF)** |
| Fine-tuning    | LoRA (QLoRA or Axolotl) on Hadith/Qur’an/quotes |
| Inference      | `llama.cpp` (GGUF backend) |
| Prompt format  | Alpaca / ChatML-style |
| TTS            | **Piper** (`en_US-kyle` or Arabic voice if possible) |
| Voice UI       | Flutter `flutter_tts` + native pipe (Rust or Kotlin bridge) |

---

### 📱 Mobile App (Flutter)

| Component           | Description |
|--------------------|-------------|
| UI Toolkit         | Flutter (Material 3, Dark Theme) |
| State Mgmt         | Riverpod / Bloc |
| TTS Playback       | Via Rust or Kotlin FFI (calls Piper) |
| Local Storage      | SQLite (for journal + chat memory) |
| Model Storage      | Assets bundled (Gemma + Piper voice + Islamic DBs) |

---

### 📂 Islamic Knowledge Base (Local)

| Type      | Format     | Source (Suggested) |
|-----------|------------|--------------------|
| Qur'an    | JSON       | [Tanzil.net](https://tanzil.net), [quran-json](https://github.com/rizalgowandy/quran-json) |
| Hadith    | SQLite     | Parse from [sunnah.com](https://sunnah.com) or [Maktaba Shamela] |
| Quotes    | JSON       | Ibn al-Qayyim, al-Ghazali, etc. (translated, properly attributed) |
| Duʿā      | JSON + Audio | "Hisnul Muslim", with fallback to TTS |

---

## 🔒 Best Practices

1. **NO FIQH / FATWA OUTPUT**
   - Always redirect to real scholars
   - Avoid controversial matters
   - Include disclaimer in footer: *"This app offers emotional support, not legal rulings"*

2. **Islamically Grounded Persona**
   - Humble, non-arrogant
   - Uses Qur’an and Hadith wisely, softly
   - Encourages hope, patience, gratitude
   - Never jokes about the religion

3. **Safety + Privacy**
   - All data local
   - Optional PIN to protect journal
   - No internet access required

4. **Model Alignment**
   - Fine-tune or use LoRA on:
     - Emotional conversations from an Islamic male perspective
     - Duʿā examples, emotional hadith
     - Scholar quotes in context (hope, sorrow, resilience)

---

## 🧪 LoRA Fine-Tuning Plan (Optional but Powerful)

- Use **QLoRA + PEFT** with 50–100 example conversations:
  - Sadness + duʿā
  - Overwhelm + reminder
  - Night anxiety + Qur’anic soothing
  - Regret + hadith on tawbah
  - Loneliness + quote from Ibn al-Qayyim

Train with:
- OpenHermes or Gemma base (Mistral works too)
- Output a `lora_adapter.safetensors` and merge with base using `merge_lora.py` or load at runtime in `llama.cpp`

---

## 🎯 Stretch Goals

- Voice Input (Whisper.cpp or Vosk)
- Personality presets: "Wise Akhī", "Friendly Akhī", "Scholarly Akhī"
- Audio-only mode (for nighttime)

---

## 📁 Folder Structure (Suggestion)

```plaintext
/akhy-app/
├── assets/
│   ├── gemma-3b.gguf
│   ├── piper-voice/
│   ├── quran.json
│   ├── hadith.sqlite
│   ├── quotes.json
│   └── duas/
├── lib/
│   └── main.dart
├── rust-backend/ or android/jni/
│   └── llama.cpp
│   └── piper/
├── model-lora/
│   └── gemma-lora.safetensors
└── storage/
    └── journal.db
````

---

## 🤝 Attribution Notice (Add to App)

> *This app is not a source of Islamic rulings. All Islamic content is based on authentic sources and provided for emotional and spiritual support. For detailed religious questions, consult a qualified scholar.*

---

```

---

## ✅ Next Steps (Let Me Know If You Want)
- Build this into a **scaffolded Flutter + llama.cpp starter**
- Generate LoRA-ready Islamic conversation samples
- Create `.json` versions of quotes, duʿā, and hadith
- Draft UX flow (Figma-style, dark spiritual UI)

Ready when you are, akhī.
```

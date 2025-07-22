
# 📋 Task Plan for Akhī – Muslim Companion MVP

This document outlines the full development process to build the Akhī app from UI to backend LLM and TTS integration.

---

## 🟢 Phase 1: Project Setup

### ✅ Step 1: Scaffold Project
- [x] Create Flutter UI project
- [x] Set up `lib/main.dart` with dark theme and basic routing
- [x] Add FFI support in `pubspec.yaml`

### ✅ Step 2: Add Rust Backend
- [x] Create `rust-backend/` with `greet_user()` function
- [x] Compile as `cdylib` for Android/iOS

---

## 🟡 Phase 2: Piper TTS Integration

### 🔨 Step 3: Download & Embed Piper
- [ ] Download Piper binary and place in `piper-tts/`
- [ ] Download Arabic male voice model (e.g. `ar_male-medium.onnx`)
- [ ] Test running Piper offline from Rust using `std::process::Command`

### 🔗 Step 4: Bridge Piper with Rust
- [ ] Expose a Rust FFI function: `speak(text: *const c_char)`
- [ ] In `main.dart`, send user responses to this `speak()` method
- [ ] Optional: Show TTS playback status in UI

---

## 🟠 Phase 3: LLM (Gemma Sutra) Integration

### 🧠 Step 5: Load Gemma Model
- [ ] Place quantized GGUF model in `model-lora/gemma-sutra-3b/`
- [ ] Use llama.cpp or C++/Rust inference bridge
- [ ] Wrap model call in Rust function: `reply_to_user(prompt: *const c_char) -> *const c_char`

### ✍️ Step 6: Add Prompt & Guardrails
- [x] Create `akhi_prompt.json` as system prompt
- [x] Add content safety regex or filters
- [ ] Include fallback if inappropriate query detected

---

## 🟣 Phase 4: Emotional Support Flow

### 🧭 Step 7: Daily Check-In UI
- [ ] Create screen to ask: “How are you feeling today?”
- [ ] Options: 😔 Sad, 😠 Angry, 😴 Tired, 🕊️ Peaceful, 🙏 Need Duʿā
- [ ] Each option triggers different LLM response + TTS

### 💬 Step 8: History Log (Optional)
- [ ] Store past chats in `sqflite` or local JSON file
- [ ] Allow user to replay past duʿā or reminders

---

## 🟤 Phase 5: Build & Deploy MVP

### 🧪 Step 9: Offline Testing
- [ ] Run app on device with no internet
- [ ] Ensure TTS and LLM reply under 5 seconds
- [ ] Stress test: 5–10 question sessions

### 📦 Step 10: Build APK
- [ ] Use `flutter build apk --release`
- [ ] Embed all binaries + model files in build

---

## ✅ Done Files
- `MVP.md` – feature outline
- `LEGAL.md` – legal disclaimer
- `akhi_prompt.json` – prompt guardrails
- `akhi_lora_samples.json` – sample LoRA alignments

---

Let me know when you want to begin Phase 2 (TTS) or 3 (LLM). I'll guide implementation code next.

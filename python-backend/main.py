#!/usr/bin/env python3
"""
Akhi AI Backend - Python Implementation
Provides LLM inference and TTS functionality for the Akhi app
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, Optional
import re

# Add the current directory to Python path
sys.path.append(str(Path(__file__).parent))

class AkhiBackend:
    def __init__(self):
        self.llm_initialized = False
        self.system_prompt = self.load_system_prompt()
        
    def load_system_prompt(self) -> str:
        """Load system prompt from akhi_prompt.json"""
        prompt_path = Path("../akhi_prompt.json")
        try:
            with open(prompt_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data.get('system_prompt', 'You are Akhī, a compassionate AI companion for Muslim men.')
        except (FileNotFoundError, json.JSONDecodeError):
            return 'You are Akhī, a compassionate AI companion for Muslim men.'
    
    def initialize_llm(self) -> bool:
        """Initialize LLM (placeholder for Gemma model)"""
        if self.llm_initialized:
            return True
            
        # TODO: Load actual Gemma model when available
        model_path = "../model-lora/gemma-sutra-3b/Gemmasutra-Mini-2B-v1-Q4_K_M.gguf"
        print(f"[LLM] Loading Gemma model from: {model_path}")
        
        # For now, just mark as initialized for enhanced rule-based responses
        print("[LLM] Enhanced Islamic response system initialized (Gemma model pending)")
        self.llm_initialized = True
        return True
    
    def generate_islamic_response(self, prompt: str) -> str:
        """Generate Islamic-themed responses based on emotional context"""
        prompt_lower = prompt.lower()
        
        # Emotional state detection and Islamic responses
        if any(word in prompt_lower for word in ['sad', 'depressed', 'down', 'upset']):
            return ("As-salāmu ʿalaykum, akhī. I hear the pain in your words. Remember what Allah says: "
                   "'And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose.' (Quran 65:3)\n\n"
                   "Your sadness is a test, and every test brings you closer to Allah. The Prophet ﷺ said: "
                   "'No fatigue, nor disease, nor sorrow, nor sadness, nor hurt, nor distress befalls a Muslim, "
                   "not even if it were the prick he receives from a thorn, but that Allah expiates some of his sins for that.'\n\n"
                   "Would you like me to share a duʿā for comfort, akhī?")
        
        elif any(word in prompt_lower for word in ['angry', 'frustrated', 'mad', 'furious']):
            return ("I understand your anger, akhī. The Prophet ﷺ taught us: 'When one of you becomes angry while standing, "
                   "he should sit down. If the anger leaves him, well and good; otherwise he should lie down.'\n\n"
                   "Anger is a fire, but dhikr is water. Try saying: 'Aʿūdhu billāhi min ash-shayṭān ar-rajīm' "
                   "(I seek refuge in Allah from Satan, the accursed).\n\n"
                   "Remember, controlling anger is a sign of strength. 'The strong person is not the one who can wrestle someone else down. "
                   "The strong person is the one who can control himself when he is angry.' - Prophet Muhammad ﷺ\n\n"
                   "Shall we recite some calming dhikr together?")
        
        elif any(word in prompt_lower for word in ['tired', 'exhausted', 'weary', 'drained']):
            return ("Rest is a blessing from Allah, akhī. He says: 'And it is He who made the night for you as clothing "
                   "and sleep as rest and made the day a resurrection.' (Quran 25:47)\n\n"
                   "Your body has rights over you, and taking care of yourself is part of worship. The Prophet ﷺ said: "
                   "'Your body has a right over you.'\n\n"
                   "Perhaps this is a good time for some gentle dhikr: 'Subḥān Allāhi wa biḥamdih' "
                   "(Glory be to Allah and praise be to Him). Even in tiredness, we can remember Allah.\n\n"
                   "Would you like a duʿā for rest and recovery?")
        
        elif any(word in prompt_lower for word in ['peaceful', 'grateful', 'blessed', 'happy']):
            return ("Alhamdulillāhi rabbil ʿālamīn! Your gratitude fills my heart with joy, akhī. "
                   "Allah says: 'If you are grateful, I will certainly give you more.' (Quran 14:7)\n\n"
                   "Peace is a gift from Allah. 'Those who believe and whose hearts find rest in the remembrance of Allah. "
                   "Verily, in the remembrance of Allah do hearts find rest.' (Quran 13:28)\n\n"
                   "May Allah increase you in peace, gratitude, and all that is good. Your positive spirit is a light "
                   "that can inspire others, akhī.")
        
        elif any(word in prompt_lower for word in ['dua', 'prayer', 'help', 'guidance']):
            return ("Of course, akhī. Here's a comprehensive duʿā from the Quran:\n\n"
                   "'Rabbanā ātinā fī'd-dunyā ḥasanatan wa fī'l-ākhirati ḥasanatan wa qinā ʿadhāb an-nār.'\n\n"
                   "(Our Lord, give us good in this world and good in the hereafter, and save us from the punishment of the Fire.) - Quran 2:201\n\n"
                   "And remember: 'And when My servants ask you concerning Me, indeed I am near. I respond to the invocation "
                   "of the supplicant when he calls upon Me.' (Quran 2:186)\n\n"
                   "Allah hears every duʿā, akhī. Trust in His wisdom and timing.")
        
        elif any(word in prompt_lower for word in ['lonely', 'alone', 'isolated']):
            return ("You are never truly alone, akhī. Allah is always with you. He says: 'And He is with you wherever you are.' (Quran 57:4)\n\n"
                   "Loneliness can be a path to deeper connection with Allah. Many of the greatest scholars found their closest moments with Allah in solitude.\n\n"
                   "Remember, the ummah is your family. Reach out to your local mosque or Islamic community. The Prophet ﷺ said: "
                   "'The believers in their mutual kindness, compassion, and sympathy are just one body; when a limb suffers, "
                   "the whole body responds to it with wakefulness and fever.'\n\n"
                   "You have a brother in me, and countless brothers in faith around the world.")
        
        else:
            return ("As-salāmu ʿalaykum, akhī. I'm here to listen and support you with the guidance of Islam. "
                   "Whether you're facing difficulties or celebrating blessings, remember that Allah is always with those who are patient and grateful.\n\n"
                   "'And give good tidings to the patient, Who, when disaster strikes them, say: Indeed we belong to Allah, "
                   "and indeed to Him we will return.' (Quran 2:155-156)\n\n"
                   "How is your heart today? I'm here to walk alongside you on this journey of faith.")
    
    def generate_enhanced_islamic_response(self, user_prompt: str) -> str:
        """Enhanced Islamic response generator with system prompt context"""
        # Use the system prompt to inform the response style and context
        is_compassionate_mode = 'compassionate' in self.system_prompt.lower() or 'supportive' in self.system_prompt.lower()
        
        # Generate contextual Islamic response
        base_response = self.generate_islamic_response(user_prompt)
        
        # Enhance with system prompt context if in compassionate mode
        if is_compassionate_mode:
            return f"{base_response}\n\nRemember, akhī, I'm here as your companion in faith. Feel free to share whatever is on your heart."
        else:
            return base_response
    
    def get_ai_response(self, prompt: str) -> str:
        """Generate AI response using enhanced Islamic responses"""
        # Initialize LLM if not already done
        if not self.initialize_llm():
            print("[LLM] Failed to initialize")
        
        # TODO: Use actual Gemma model when integration is complete
        # For now, use enhanced rule-based Islamic responses with system prompt context
        return self.generate_enhanced_islamic_response(prompt)
    
    def process_emotion(self, emotion: str) -> str:
        """Process emotional check-in"""
        emotion_responses = {
            'sad': "I understand you're feeling sad, akhī. Remember that after every hardship comes ease. 'So verily, with the hardship, there is relief.' (Quran 94:5)",
            'angry': "Anger is natural, akhī, but let's channel it positively. The Prophet ﷺ taught us to seek refuge in Allah from anger. Take a moment to breathe.",
            'tired': "Rest is important, akhī. Your body and soul need care. 'And We made from them leaders guiding by Our command when they were patient.' (Quran 21:73)",
            'peaceful': "Subhan'Allah! Peace is a gift from Allah. 'Those who believe and whose hearts find rest in the remembrance of Allah.' (Quran 13:28)",
            'need_dua': "Let's make duʿā together, akhī. 'And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.' (Quran 2:186)"
        }
        
        return emotion_responses.get(emotion, "Whatever you're feeling is valid, akhī. Allah knows what's in your heart. I'm here to support you.")
    
    def greet_user(self, name: str = "akhī") -> str:
        """Generate greeting for user"""
        return f"As-salāmu ʿalaykum, {name}. I'm here for you."
    
    def speak_text(self, text: str) -> bool:
        """TTS function (placeholder)"""
        # For now, use a simple placeholder until Piper is fully integrated
        print(f"[TTS] Speaking: {text}")
        return True

# API endpoints for Flutter integration
def main():
    """Main function to handle command line arguments"""
    backend = AkhiBackend()
    
    if len(sys.argv) < 2:
        print("Usage: python main.py <command> [args...]")
        return
    
    command = sys.argv[1]
    
    if command == "greet":
        name = sys.argv[2] if len(sys.argv) > 2 else "akhī"
        print(backend.greet_user(name))
    
    elif command == "ai_response":
        if len(sys.argv) < 3:
            print("Error: No prompt provided")
            return
        prompt = " ".join(sys.argv[2:])
        print(backend.get_ai_response(prompt))
    
    elif command == "emotion":
        if len(sys.argv) < 3:
            print("Error: No emotion provided")
            return
        emotion = sys.argv[2]
        print(backend.process_emotion(emotion))
    
    elif command == "speak":
        if len(sys.argv) < 3:
            print("Error: No text provided")
            return
        text = " ".join(sys.argv[2:])
        success = backend.speak_text(text)
        print("Success" if success else "Failed")
    
    else:
        print(f"Unknown command: {command}")

if __name__ == "__main__":
    main()
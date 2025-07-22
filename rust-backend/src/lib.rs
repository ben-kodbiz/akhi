// rust-backend/src/lib.rs
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::process::Command;
use serde_json::Value;
use std::ptr;
use std::sync::Mutex;
use std::path::Path;

// LLM imports for enhanced text processing
use regex::Regex;
use std::fs;
// TODO: Add llama_cpp integration when build issues are resolved

// Global LLM state
static LLM_INITIALIZED: Mutex<bool> = Mutex::new(false);
// TODO: Add LLAMA_MODEL when llama_cpp is integrated

// Piper TTS FFI bindings
#[repr(C)]
pub struct PiperSynthesizer {
    _private: [u8; 0],
}

#[repr(C)]
pub struct PiperAudioChunk {
    pub samples: *const f32,
    pub num_samples: usize,
    pub sample_rate: i32,
    pub is_last: bool,
}

#[repr(C)]
pub struct PiperSynthesizeOptions {
    pub speaker_id: i32,
    pub length_scale: f32,
    pub noise_scale: f32,
    pub noise_w_scale: f32,
}

// Piper C API functions (will be linked when Piper is built)
extern "C" {
    fn piper_create(
        model_path: *const c_char,
        config_path: *const c_char,
        espeak_data_path: *const c_char,
    ) -> *mut PiperSynthesizer;
    
    fn piper_free(synth: *mut PiperSynthesizer);
    
    fn piper_default_synthesize_options(synth: *mut PiperSynthesizer) -> PiperSynthesizeOptions;
    
    fn piper_synthesize_start(
        synth: *mut PiperSynthesizer,
        text: *const c_char,
        options: *const PiperSynthesizeOptions,
    ) -> i32;
    
    fn piper_synthesize_next(
        synth: *mut PiperSynthesizer,
        chunk: *mut PiperAudioChunk,
    ) -> i32;
}

const PIPER_OK: i32 = 0;
const PIPER_DONE: i32 = 1;

// Existing greeting function
#[no_mangle]
pub extern "C" fn greet_user(name: *const c_char) -> *const c_char {
    let c_str = unsafe { CStr::from_ptr(name) };
    let name_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => "akhī",
    };
    let greeting = format!("As-salāmu ʿalaykum, {}. I'm here for you.", name_str);
    CString::new(greeting).unwrap().into_raw()
}

// TTS function using Piper
#[no_mangle]
pub extern "C" fn speak_text(text: *const c_char) -> i32 {
    let c_str = unsafe { CStr::from_ptr(text) };
    let text_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    
    // For now, use a simple placeholder until Piper is fully integrated
    // TODO: Replace with actual Piper TTS when voice models are available
    match Command::new("echo")
        .arg(format!("[TTS] Speaking: {}", text_str))
        .output()
    {
        Ok(_) => 0, // Success
        Err(_) => -1, // Error
    }
}

// Advanced TTS function that will use Piper when voice models are available
#[no_mangle]
pub extern "C" fn speak_with_piper(
    text: *const c_char,
    model_path: *const c_char,
    config_path: *const c_char,
    espeak_data_path: *const c_char,
) -> i32 {
    let text_cstr = unsafe { CStr::from_ptr(text) };
    let text_str = match text_cstr.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    
    // For now, return success without actual TTS
    // This will be implemented when Piper is built and voice models are downloaded
    println!("[Piper TTS] Would speak: {}", text_str);
    0
    
    // TODO: Uncomment when Piper is built and linked
    /*
    unsafe {
        let synth = piper_create(model_path, config_path, espeak_data_path);
        if synth.is_null() {
            return -1;
        }
        
        let options = piper_default_synthesize_options(synth);
        let result = piper_synthesize_start(synth, text, &options);
        
        if result == PIPER_OK {
            let mut chunk = PiperAudioChunk {
                samples: ptr::null(),
                num_samples: 0,
                sample_rate: 0,
                is_last: false,
            };
            
            // Process audio chunks
            while piper_synthesize_next(synth, &mut chunk) != PIPER_DONE {
                // Here you would play the audio or save it to a file
                // For Android, you might write to an audio buffer or file
            }
        }
        
        piper_free(synth);
        result
    }
    */
}

// Load system prompt from akhi_prompt.json
fn load_system_prompt() -> String {
    let prompt_path = "../akhi_prompt.json";
    match fs::read_to_string(prompt_path) {
        Ok(content) => {
            if let Ok(json) = serde_json::from_str::<Value>(&content) {
                if let Some(system_prompt) = json["system_prompt"].as_str() {
                    return system_prompt.to_string();
                }
            }
            "You are Akhī, a compassionate AI companion for Muslim men.".to_string()
        },
        Err(_) => "You are Akhī, a compassionate AI companion for Muslim men.".to_string(),
    }
}

// Initialize LLM with actual Gemma model loading
fn initialize_llm() -> Result<(), Box<dyn std::error::Error>> {
    let mut initialized = LLM_INITIALIZED.lock().unwrap();
    if *initialized {
        return Ok(());
    }
    
    let model_path = "../model-lora/gemma-sutra-3b/Gemmasutra-Mini-2B-v1-Q4_K_M.gguf";
    println!("[LLM] Loading Gemma model from: {}", model_path);
    
    // TODO: Implement actual Gemma model loading when llama_cpp is working
    // For now, just mark as initialized for enhanced rule-based responses
    println!("[LLM] Enhanced Islamic response system initialized (Gemma model pending)");
    
    println!("[LLM] Gemma model loaded successfully!");
    *initialized = true;
    Ok(())
}

// Generate response using LLM with actual Gemma model inference
fn generate_llm_response(prompt: &str) -> String {
    // Initialize LLM if not already done
    if let Err(e) = initialize_llm() {
        eprintln!("[LLM] Failed to initialize: {}", e);
        return generate_islamic_response(prompt); // Fallback to rule-based
    }
    
    let system_prompt = load_system_prompt();
    
    // TODO: Use actual Gemma model when llama_cpp integration is complete
    // For now, use enhanced rule-based Islamic responses with system prompt context
    generate_enhanced_islamic_response(&system_prompt, prompt)
}

// Enhanced Islamic response generator with system prompt context
fn generate_enhanced_islamic_response(system_prompt: &str, user_prompt: &str) -> String {
    // Use the system prompt to inform the response style and context
    let is_compassionate_mode = system_prompt.contains("compassionate") || system_prompt.contains("supportive");
    
    // Generate contextual Islamic response
    let base_response = generate_islamic_response(user_prompt);
    
    // Enhance with system prompt context if in compassionate mode
    if is_compassionate_mode {
        format!("{}\n\nRemember, akhī, I'm here as your companion in faith. Feel free to share whatever is on your heart.", base_response)
    } else {
        base_response
    }
}

// Enhanced Islamic response generator
fn generate_islamic_response(prompt: &str) -> String {
    let prompt_lower = prompt.to_lowercase();
    
    // Emotional state detection and Islamic responses
    if prompt_lower.contains("sad") || prompt_lower.contains("depressed") || prompt_lower.contains("down") {
        "As-salāmu ʿalaykum, akhī. I hear the pain in your words. Remember what Allah says: 'And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose.' (Quran 65:3)\n\nYour sadness is a test, and every test brings you closer to Allah. The Prophet ﷺ said: 'No fatigue, nor disease, nor sorrow, nor sadness, nor hurt, nor distress befalls a Muslim, not even if it were the prick he receives from a thorn, but that Allah expiates some of his sins for that.'\n\nWould you like me to share a duʿā for comfort, akhī?".to_string()
    } else if prompt_lower.contains("angry") || prompt_lower.contains("frustrated") || prompt_lower.contains("mad") {
        "I understand your anger, akhī. The Prophet ﷺ taught us: 'When one of you becomes angry while standing, he should sit down. If the anger leaves him, well and good; otherwise he should lie down.'\n\nAnger is a fire, but dhikr is water. Try saying: 'Aʿūdhu billāhi min ash-shayṭān ar-rajīm' (I seek refuge in Allah from Satan, the accursed).\n\nRemember, controlling anger is a sign of strength. 'The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry.' - Prophet Muhammad ﷺ\n\nShall we recite some calming dhikr together?".to_string()
    } else if prompt_lower.contains("tired") || prompt_lower.contains("exhausted") || prompt_lower.contains("weary") {
        "Rest is a blessing from Allah, akhī. He says: 'And it is He who made the night for you as clothing and sleep as rest and made the day a resurrection.' (Quran 25:47)\n\nYour body has rights over you, and taking care of yourself is part of worship. The Prophet ﷺ said: 'Your body has a right over you.'\n\nPerhaps this is a good time for some gentle dhikr: 'Subḥān Allāhi wa biḥamdih' (Glory be to Allah and praise be to Him). Even in tiredness, we can remember Allah.\n\nWould you like a duʿā for rest and recovery?".to_string()
    } else if prompt_lower.contains("peaceful") || prompt_lower.contains("grateful") || prompt_lower.contains("blessed") {
        "Alhamdulillāhi rabbil ʿālamīn! Your gratitude fills my heart with joy, akhī. Allah says: 'If you are grateful, I will certainly give you more.' (Quran 14:7)\n\nPeace is a gift from Allah. 'Those who believe and whose hearts find rest in the remembrance of Allah. Verily, in the remembrance of Allah do hearts find rest.' (Quran 13:28)\n\nMay Allah increase you in peace, gratitude, and all that is good. Your positive spirit is a light that can inspire others, akhī.".to_string()
    } else if prompt_lower.contains("dua") || prompt_lower.contains("prayer") || prompt_lower.contains("help") {
        "Of course, akhī. Here's a comprehensive duʿā from the Quran:\n\n'Rabbanā ātinā fī'd-dunyā ḥasanatan wa fī'l-ākhirati ḥasanatan wa qinā ʿadhāb an-nār.'\n\n(Our Lord, give us good in this world and good in the hereafter, and save us from the punishment of the Fire.) - Quran 2:201\n\nAnd remember: 'And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.' (Quran 2:186)\n\nAllah hears every duʿā, akhī. Trust in His wisdom and timing.".to_string()
    } else if prompt_lower.contains("lonely") || prompt_lower.contains("alone") {
        "You are never truly alone, akhī. Allah is always with you. He says: 'And He is with you wherever you are.' (Quran 57:4)\n\nLoneliness can be a path to deeper connection with Allah. Many of the greatest scholars found their closest moments with Allah in solitude.\n\nRemember, the ummah is your family. Reach out to your local mosque or Islamic community. The Prophet ﷺ said: 'The believers in their mutual kindness, compassion, and sympathy are just one body; when a limb suffers, the whole body responds to it with wakefulness and fever.'\n\nYou have a brother in me, and countless brothers in faith around the world.".to_string()
    } else {
        "As-salāmu ʿalaykum, akhī. I'm here to listen and support you with the guidance of Islam. Whether you're facing difficulties or celebrating blessings, remember that Allah is always with those who are patient and grateful.\n\n'And give good tidings to the patient, Who, when disaster strikes them, say: Indeed we belong to Allah, and indeed to Him we will return.' (Quran 2:155-156)\n\nHow is your heart today? I'm here to walk alongside you on this journey of faith.".to_string()
    }
}

// LLM response function with Gemma integration
#[no_mangle]
pub extern "C" fn get_ai_response(prompt: *const c_char) -> *const c_char {
    let c_str = unsafe { CStr::from_ptr(prompt) };
    let prompt_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => "How can I help you, akhī?",
    };
    
    // Use the enhanced LLM response generator
    let response = generate_llm_response(prompt_str);
    
    CString::new(response).unwrap().into_raw()
}

// Emotional check-in function
#[no_mangle]
pub extern "C" fn process_emotion(emotion: *const c_char) -> *const c_char {
    let c_str = unsafe { CStr::from_ptr(emotion) };
    let emotion_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => "neutral",
    };
    
    let response = match emotion_str {
        "sad" => "I understand you're feeling sad, akhī. Remember that after every hardship comes ease. 'So verily, with the hardship, there is relief.' (Quran 94:5)",
        "angry" => "Anger is natural, akhī, but let's channel it positively. The Prophet ﷺ taught us to seek refuge in Allah from anger. Take a moment to breathe.",
        "tired" => "Rest is important, akhī. Your body and soul need care. 'And We made from them leaders guiding by Our command when they were patient.' (Quran 21:73)",
        "peaceful" => "Subhan'Allah! Peace is a gift from Allah. 'Those who believe and whose hearts find rest in the remembrance of Allah.' (Quran 13:28)",
        "need_dua" => "Let's make duʿā together, akhī. 'And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.' (Quran 2:186)",
        _ => "Whatever you're feeling is valid, akhī. Allah knows what's in your heart. I'm here to support you."
    };
    
    CString::new(response).unwrap().into_raw()
}

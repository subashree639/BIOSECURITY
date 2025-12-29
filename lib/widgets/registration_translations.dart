import '../widgets/multilingual_address_input.dart';

class RegistrationTranslations {
  static Map<Language, Map<String, String>> get translations => {
    Language.english: {
      // Phone registration
      'phoneHint': 'Enter 10-digit mobile number (e.g., 9876543210)',
      'sendOTP': 'Send OTP',
      'addCustomId': 'Add Custom ID',
      'customFarmerId': 'Custom Farmer ID',
      'ifNotCustom': 'If you don\'t add a custom ID, one will be generated automatically.',
      'verifyLogin': 'Verify & Register',
      'resendOTP': 'Resend OTP',
      'otpLabel': 'OTP',
      'registrationSuccess': 'Registration successful!',
      'enterOTP': 'Please enter the OTP',
      'enterCustomId': 'Enter custom ID or disable custom option',
      'customIdExists': 'Custom ID already in use',
      'fillAddressFields': 'Please fill in all address fields',
      'registrationError': 'Registration error',
      'otpGenerated': 'OTP generated and displayed on screen. Enter this OTP to verify.',
      'invalidPhone': 'Please enter a valid 10-digit mobile number (e.g., 9876543210)',
      'extractOtpError': 'Failed to extract OTP from response',
      'rateLimitError': 'Too many OTP requests. Please wait',

      // Voice registration
      'voiceEnrollment': 'Voice Enrollment',
      'voiceRecording': 'Recording your voice — hold still and speak the phrase when prompted.',
      'voiceTapToStart': 'Tap ENROLL to start voice capture. You will be asked to say a short phrase three times.',
      'voiceEnrollmentComplete': 'Enrollment complete — your Farmer ID is:',
      'enrollVoice': 'ENROLL',
      'cancel': 'Cancel',
      'continueToDashboard': 'Continue to Dashboard',
      'retryEnrollment': 'Retry Enrollment',
      'processingEnrollment': 'Processing enrollment...',

      // Common
      'registerByMobile': 'Register by Mobile',
      'registerAsFarmer': 'Register as Farmer',
      'welcomeRegister': 'Welcome! Choose your registration method',
      'voiceRegistration': 'Voice Registration',
      'voiceRegDesc': 'Register using your voice for quick and secure access',
      'mobileRegistration': 'Mobile Registration',
      'mobileRegDesc': 'Register using your mobile number with OTP verification',
    },
    Language.tamil: {
      // Phone registration
      'phoneHint': '10 இலக்க மொபைல் எண்ணை உள்ளிடவும் (எ.கா., 9876543210)',
      'sendOTP': 'OTP அனுப்பு',
      'addCustomId': 'தனிப்பயன் ID சேர்க்க',
      'customFarmerId': 'தனிப்பயன் விவசாயி ID',
      'ifNotCustom': 'தனிப்பயன் ID சேர்க்காவிட்டால், தானாக உருவாக்கப்படும்.',
      'verifyLogin': 'சரிபார் & பதிவு செய்',
      'resendOTP': 'OTP மீண்டும் அனுப்பு',
      'otpLabel': 'OTP',
      'registrationSuccess': 'பதிவு வெற்றிகரமாக!',
      'enterOTP': 'OTP-ஐ உள்ளிடவும்',
      'enterCustomId': 'தனிப்பயன் ID உள்ளிடவும் அல்லது விருப்பத்தை முடக்கவும்',
      'customIdExists': 'தனிப்பயன் ID ஏற்கனவே பயன்பாட்டில் உள்ளது',
      'fillAddressFields': 'எல்லா முகவரி புலங்களையும் நிரப்பவும்',
      'registrationError': 'பதிவு பிழை',
      'otpGenerated': 'OTP உருவாக்கப்பட்டு திரையில் காட்டப்பட்டது. இந்த OTP-ஐ சரிபார்க்க உள்ளிடவும்.',
      'invalidPhone': 'சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும் (எ.கா., 9876543210)',
      'extractOtpError': 'பதிலிலிருந்து OTP எடுக்க முடியவில்லை',
      'rateLimitError': 'மிக அதிக OTP கோரிக்கைகள். தயவுசெய்து காத்திருக்கவும்',

      // Voice registration
      'voiceEnrollment': 'குரல் பதிவு',
      'voiceRecording': 'உங்கள் குரலை பதிவு செய்கிறது — அமைதியாக இருந்து கேட்கப்படும்போது பேசவும்.',
      'voiceTapToStart': 'குரல் பதிவை தொடங்க ENROLL-ஐ தட்டவும். நீங்கள் ஒரு சிறிய சொற்றொடரை மூன்று முறை சொல்ல வேண்டும்.',
      'voiceEnrollmentComplete': 'பதிவு முடிந்தது — உங்கள் விவசாயி ID:',
      'enrollVoice': 'பதிவு செய்',
      'cancel': 'ரத்து செய்',
      'continueToDashboard': 'டாஷ்போர்டுக்கு தொடரவும்',
      'retryEnrollment': 'பதிவை மீண்டும் முயற்சி',
      'processingEnrollment': 'பதிவை செயல்படுத்துகிறது...',

      // Common
      'registerByMobile': 'மொபைல் மூலம் பதிவு',
      'registerAsFarmer': 'விவசாயியாக பதிவு செய்',
      'welcomeRegister': 'வருக! உங்கள் பதிவு முறையை தேர்வு செய்க',
      'voiceRegistration': 'குரல் பதிவு',
      'voiceRegDesc': 'விரைவான மற்றும் பாதுகாப்பான அணுகலுக்காக உங்கள் குரல் மூலம் பதிவு செய்க',
      'mobileRegistration': 'மொபைல் பதிவு',
      'mobileRegDesc': 'OTP சரிபார்ப்புடன் உங்கள் மொபைல் எண் மூலம் பதிவு செய்க',
    },
    Language.hindi: {
      // Phone registration
      'phoneHint': '10 अंकों का मोबाइल नंबर दर्ज करें (जैसे, 9876543210)',
      'sendOTP': 'OTP भेजें',
      'addCustomId': 'कस्टम ID जोड़ें',
      'customFarmerId': 'कस्टम किसान ID',
      'ifNotCustom': 'यदि आप कस्टम ID नहीं जोड़ते हैं, तो एक स्वचालित रूप से उत्पन्न हो जाएगा।',
      'verifyLogin': 'सत्यापित करें और पंजीकरण करें',
      'resendOTP': 'OTP पुनः भेजें',
      'otpLabel': 'OTP',
      'registrationSuccess': 'पंजीकरण सफल!',
      'enterOTP': 'कृपया OTP दर्ज करें',
      'enterCustomId': 'कस्टम ID दर्ज करें या विकल्प अक्षम करें',
      'customIdExists': 'कस्टम ID पहले से उपयोग में है',
      'fillAddressFields': 'कृपया सभी पता फ़ील्ड भरें',
      'registrationError': 'पंजीकरण त्रुटि',
      'otpGenerated': 'OTP उत्पन्न किया गया और स्क्रीन पर प्रदर्शित किया गया। सत्यापन के लिए यह OTP दर्ज करें।',
      'invalidPhone': 'कृपया वैध 10 अंकों का मोबाइल नंबर दर्ज करें (जैसे, 9876543210)',
      'extractOtpError': 'प्रतिक्रिया से OTP निकालने में विफल',
      'rateLimitError': 'बहुत अधिक OTP अनुरोध। कृपया प्रतीक्षा करें',

      // Voice registration
      'voiceEnrollment': 'आवाज पंजीकरण',
      'voiceRecording': 'आपकी आवाज रिकॉर्ड हो रही है — शांत रहें और संकेत मिलने पर बोलें।',
      'voiceTapToStart': 'आवाज कैप्चर शुरू करने के लिए ENROLL पर टैप करें। आपको एक छोटा वाक्य तीन बार बोलना होगा।',
      'voiceEnrollmentComplete': 'पंजीकरण पूरा — आपकी किसान ID:',
      'enrollVoice': 'पंजीकरण करें',
      'cancel': 'रद्द करें',
      'continueToDashboard': 'डैशबोर्ड पर जारी रखें',
      'retryEnrollment': 'पंजीकरण पुनः प्रयास करें',
      'processingEnrollment': 'पंजीकरण संसाधित हो रहा है...',

      // Common
      'registerByMobile': 'मोबाइल द्वारा पंजीकरण',
      'registerAsFarmer': 'किसान के रूप में पंजीकरण करें',
      'welcomeRegister': 'स्वागत! अपना पंजीकरण तरीका चुनें',
      'voiceRegistration': 'आवाज पंजीकरण',
      'voiceRegDesc': 'त्वरित और सुरक्षित पहुंच के लिए अपनी आवाज का उपयोग करके पंजीकरण करें',
      'mobileRegistration': 'मोबाइल पंजीकरण',
      'mobileRegDesc': 'OTP सत्यापन के साथ अपने मोबाइल नंबर का उपयोग करके पंजीकरण करें',
    },
  };

  static String getText(String key, Language language) {
    return translations[language]?[key] ?? translations[Language.english]![key] ?? key;
  }
}
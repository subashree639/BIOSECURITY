// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'ஏபிசி (ஆன்டிபயாடிக் செக்)';

  @override
  String get appSubtitle => 'விவசாயிகளுக்கு ஆன்டிபயாடிக் செக்';

  @override
  String get farmer => 'விவசாயி';

  @override
  String get vet => 'மருத்துவர்';

  @override
  String get seller => 'விற்பனையாளர்';

  @override
  String get login => 'உள்நுழை';

  @override
  String get register => 'பதிவு செய்';

  @override
  String get newToApp => 'பயன்பாட்டில் புதியவரா? பதிவு செய்';

  @override
  String get tapMicSayPassphrase =>
      'மைக் அழுத்தி உங்கள் கடவுச்சொல்லை சொல்லுங்கள்';

  @override
  String voiceRegistered(Object id) {
    return 'குரல் பதிவு செய்யப்பட்டது — ஐடி: $id';
  }

  @override
  String get listening => 'விவசாயி — கேட்கிறது...';

  @override
  String get loginWithMobile => 'மொபைல் மூலம் உள்நுழை (OTP)';

  @override
  String get enterMobileNumber => 'மொபைல் எண்ணை உள்ளீடு செய்யுங்கள்';

  @override
  String get sendOTP => 'OTP அனுப்பு';

  @override
  String get verifyLogin => 'சரிபார்த்து உள்நுழை';

  @override
  String get resendOTP => 'OTP மீண்டும் அனுப்பு';

  @override
  String get enterOTP => '6-இலக்க OTP உள்ளீடு செய்யுங்கள்';

  @override
  String otpSentTo(Object number) {
    return 'OTP அனுப்பப்பட்டது: $number';
  }

  @override
  String get incorrectOTP => 'தவறான OTP';

  @override
  String get enterValidMobile => 'சரியான மொபைல் உள்ளீடு செய்யுங்கள்';

  @override
  String mockOTP(Object otp) {
    return 'மாக் OTP: $otp';
  }

  @override
  String mockOTPFarmer(Object otp) {
    return 'மாக் OTP (விவசாயி): $otp';
  }

  @override
  String mockOTPSeller(Object otp) {
    return 'மாக் OTP (விற்பனையாளர்): $otp';
  }

  @override
  String get veterinaryLogin => 'மருத்துவ உள்நுழைவு';

  @override
  String get pleaseEnterLoginDetails =>
      'உங்கள் உள்நுழைவு விவரங்களை உள்ளீடு செய்யுங்கள்';

  @override
  String get username => 'பயனர்பெயர்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get vetIdRegNo => 'மருத்துவர் ஐடி / பதிவு எண்';

  @override
  String get loginAsVet => 'மருத்துவராக உள்நுழை';

  @override
  String get newToAppRegisterVet =>
      'பயன்பாட்டில் புதியவரா? மருத்துவராக பதிவு செய்';

  @override
  String get verifying => 'சரிபார்க்கிறது...';

  @override
  String get invalidVetCredentials => 'தவறான மருத்துவர் சான்றுகள்';

  @override
  String get sellerUser => 'விற்பனையாளர் / பயனர்';

  @override
  String get pleaseEnterPhoneNumber =>
      'உங்கள் தொலைபேசி எண்ணை உள்ளீடு செய்யுங்கள்';

  @override
  String get verifyOTP => 'OTP சரிபார்க்க';

  @override
  String get otpSent => 'OTP அனுப்பப்பட்டது';

  @override
  String get registerAsFarmer => 'விவசாயியாக பதிவு செய்';

  @override
  String get welcomeRegister =>
      'வரவேற்கிறோம்! ஏபிசி பயன்படுத்த பதிவு செய்யுங்கள் — குரல் அல்லது மொபைல் பதிவை தேர்ந்தெடுக்கவும்';

  @override
  String get voiceRegistration => 'குரல் பதிவு';

  @override
  String get voiceRegDesc =>
      'குரல் சுயவிவரத்தை பதிவு செய்யுங்கள் (சிமுலேட் என்ரோல்). விவசாயிகளுடன் பகிரக்கூடிய ஒரு எளிய விவசாயி ஐடியை உருவாக்குங்கள்.';

  @override
  String get mobileRegistration => 'மொபைல் பதிவு';

  @override
  String get mobileRegDesc =>
      'உங்கள் தொலைபேசி எண்ணைப் பயன்படுத்தி பதிவு செய்யுங்கள் (OTP). உங்கள் தொலைபேசியை விவசாயி ஐடியாக வைத்திருக்கலாம் அல்லது ஒரு தனிப்பயன் ஐடியை தேர்ந்தெடுக்கலாம்.';

  @override
  String get voiceEnrollment => 'குரல் என்ரோல்மென்ட் (சிமுலேட்)';

  @override
  String get tapEnrollStart =>
      'குரல் கேப்சர் தொடங்க ENROLL அழுத்தவும். உங்களுக்கு மூன்று முறை ஒரு சிறிய வாக்கியத்தை சொல்ல கேட்கப்படும்.';

  @override
  String get recordingVoice =>
      'உங்கள் குரலை பதிவு செய்கிறது — நிலையாக இருங்கள் மற்றும் குறிப்பிடப்பட்டபோது வாக்கியத்தை சொல்லுங்கள்.';

  @override
  String get enrollmentComplete =>
      'என்ரோல்மென்ட் முடிந்தது — உங்கள் விவசாயி ஐடி:';

  @override
  String get enrollVoice => 'குரல் என்ரோல் செய்';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get processingEnrollment => 'என்ரோல்மென்ட் செயலாக்கம்...';

  @override
  String get continueToDashboard => 'டாஷ்போர்டுக்கு தொடர்ந்து';

  @override
  String get retryEnrollment => 'என்ரோல்மென்ட் மீண்டும் முயற்சி செய்';

  @override
  String get registerByMobile => 'மொபைல் மூலம் பதிவு செய்';

  @override
  String get mobileNumber => 'மொபைல் எண்';

  @override
  String get addCustomId => 'தனிப்பயன் ஐடி சேர்க்க?';

  @override
  String get customFarmerId =>
      'தனிப்பயன் விவசாயி ஐடி (அக்ஷரங்கள் மற்றும் எண்கள்)';

  @override
  String get ifNotCustom =>
      'நீங்கள் ஒரு தனிப்பயன் ஐடியை வழங்கவில்லை என்றால், உங்கள் தொலைபேசி எண் உங்கள் விவசாயி ஐடியாக பயன்படுத்தப்படும்.';

  @override
  String get enterValidPhone => 'சரியான தொலைபேசி உள்ளீடு செய்யுங்கள்';

  @override
  String get idAlreadyInUse => 'தனிப்பயன் ஐடி ஏற்கனவே பயன்பாட்டில் உள்ளது';

  @override
  String registeredFarmerId(Object id) {
    return 'பதிவு செய்யப்பட்டது — விவசாயி ஐடி: $id';
  }

  @override
  String registrationError(Object error) {
    return 'பதிவு பிழை: $error';
  }

  @override
  String get registerVet => 'மருத்துவர் பதிவு செய்';

  @override
  String get registerAsVetDoctor => 'மருத்துவராக பதிவு செய்';

  @override
  String get useProfessionalCredentials =>
      'பதிவு செய்ய தொழில்முறை சான்றுகளை பயன்படுத்துங்கள் (பயனர்பெயர் + கடவுச்சொல் + மருத்துவர் ஐடி).';

  @override
  String get registerWithCredentials => 'சான்றுகளுடன் பதிவு செய்';

  @override
  String get createUsernamePasswordVetId =>
      'பயனர்பெயர் + கடவுச்சொல் + மருத்துவர் ஐடி உருவாக்கு';

  @override
  String get contactSupport => 'உதவியை தொடர்பு கொள்';

  @override
  String get enterpriseOnboarding =>
      'உங்களுக்கு எண்டர்பிரைஸ் ஆன்போர்டிங் தேவையா என்றால் எங்களுக்கு தெரிவிக்கவும்';

  @override
  String get contactSupportPlaceholder => 'உதவியை தொடர்பு கொள் (பிளேஸ்ஹோல்டர்)';

  @override
  String get veterinaryRegistration => 'மருத்துவ பதிவு';

  @override
  String get fillAllFields => 'அனைத்து புலங்களையும் நிரப்பு';

  @override
  String get vetRegistered =>
      'மருத்துவர் பதிவு செய்யப்பட்டது — உள்நுழைய கடவுச்சொல்லை பயன்படுத்து';

  @override
  String get farmerDashboard => 'விவசாயி டாஷ்போர்ட்';

  @override
  String get logout => 'வெளியேறு';

  @override
  String animalsCount(Object count, Object withdrawal) {
    return 'விலங்குகள்: $count • விலகலில்: $withdrawal';
  }

  @override
  String get animalDatabase => 'விலங்கு தரவுத்தளம்';

  @override
  String get manageAnimalDatabase => 'விலங்கு தரவுத்தளத்தை நிர்வகி';

  @override
  String get addAnimal => 'விலங்கு சேர்க்க';

  @override
  String get addNewAnimal => 'புதிய விலங்கு சேர்க்க';

  @override
  String get guides => 'வழிகாட்டிகள்';

  @override
  String get withdrawalDosingGuides => 'விலகல் மற்றும் டோசிங் வழிகாட்டிகள்';

  @override
  String get guidesPlaceholder => 'வழிகாட்டிகள் (பிளேஸ்ஹோல்டர்)';

  @override
  String get contactVet => 'மருத்துவரை தொடர்பு கொள்';

  @override
  String get shareFarmerIdWithVet => 'மருத்துவருடன் விவசாயி ஐடியை பகிர்';

  @override
  String shareId(Object id) {
    return 'ஐடி பகிர்: $id';
  }

  @override
  String get animalId => 'விலங்கு ஐடி';

  @override
  String get enterId => 'ஐடி உள்ளீடு செய்';

  @override
  String get generate => 'உருவாக்கு';

  @override
  String get species => 'இனம்';

  @override
  String get selectSpecies => 'இனத்தை தேர்ந்தெடு';

  @override
  String get age => 'வயது (ஆண்டுகள்)';

  @override
  String get enterAge => 'வயதை உள்ளீடு செய்';

  @override
  String get breed => 'இனம்';

  @override
  String get chooseBreed => 'இனம் தேர்ந்தெடு';

  @override
  String get enterBreed => 'இனம் உள்ளீடு செய்';

  @override
  String get saveAnimal => 'விலங்கு சேமி';

  @override
  String get animalSaved => 'விலங்கு சேமிக்கப்பட்டது';

  @override
  String get animalDatabaseTitle => 'விலங்கு தரவுத்தளம்';

  @override
  String get searchByIdSpeciesBreed => 'ஐடி, இனம் அல்லது இனத்தால் தேடு';

  @override
  String get all => 'அனைத்தும்';

  @override
  String get noAnimalsYet => 'இன்னும் விலங்குகள் இல்லை';

  @override
  String get tapAddCreateAnimals =>
      'விலங்குகளை உருவாக்க சேர்க்கு என்பதைத் தட்டவும்';

  @override
  String get animalDetails => 'விலங்கு விவரங்கள்';

  @override
  String get close => 'மூடு';

  @override
  String get id => 'ஐடி';

  @override
  String get lastMedicine => 'கடைசி மருந்து';

  @override
  String get withdrawalEnd => 'விலகல் முடிவு';

  @override
  String get deleteAnimal => 'விலங்கு நீக்கு';

  @override
  String get deleted => 'நீக்கப்பட்டது';

  @override
  String get vetConsulting => 'மருத்துவ ஆலோசனை';

  @override
  String get enterFarmerIdOrPhone => 'விவசாயி ஐடி அல்லது தொலைபேசி';

  @override
  String get load => 'ஏற்று';

  @override
  String loadedAnimals(Object count) {
    return 'விலங்குகள் ஏற்றப்பட்டன — மொத்தம் $count (டெமோ)';
  }

  @override
  String get enterFarmerId => 'விவசாயி ஐடி அல்லது தொலைபேசி உள்ளீடு செய்';

  @override
  String get noAnimalsInDatabase => 'தரவுத்தளத்தில் விலங்குகள் இல்லை.';

  @override
  String get consult => 'ஆலோசனை';

  @override
  String consultAnimal(Object id) {
    return 'ஆலோசனை • $id';
  }

  @override
  String get medicine => 'மருந்து (தட்டச்சு செய்ய தொடங்கு)';

  @override
  String get dosage => 'டோஸ் (mg/kg)';

  @override
  String get withdrawalPeriod => 'விலகல் காலம் (நாட்கள்)';

  @override
  String get notes => 'குறிப்புகள் (விருப்பமானது)';

  @override
  String get saveConsultation => 'ஆலோசனை சேமி';

  @override
  String get savedToAnimalRecord => 'விலங்கு பதிவில் ஆலோசனை சேமிக்கப்பட்டது';

  @override
  String get enterMedicine => 'மருந்து உள்ளீடு செய்';

  @override
  String get consultingHistory => 'ஆலோசனை வரலாறு';

  @override
  String get noConsultationHistory =>
      'ஆலோசனை வரலாறு பிளேஸ்ஹோல்டர் (தேவைப்படும்போது சேமி).';

  @override
  String get sellerDashboard => 'விற்பனையாளர் டாஷ்போர்ட்';

  @override
  String get foodScanner => 'உணவு ஸ்கேனர்';

  @override
  String get scanFoodQR => 'உணவு/QR ஸ்கேன் செய்';

  @override
  String get animalScanner => 'விலங்கு ஸ்கேனர்';

  @override
  String get scanAnimalTag => 'விலங்கு டேக் ஸ்கேன் செய்';

  @override
  String get foodScannerPlaceholder => 'உணவு ஸ்கேனர் பிளேஸ்ஹோல்டர்';

  @override
  String get animalScannerPlaceholder => 'விலங்கு ஸ்கேனர் பிளேஸ்ஹோல்டர்';

  @override
  String get camera => 'கேமரா';

  @override
  String imageCaptured(Object path) {
    return 'படம் கேப்சர் செய்யப்பட்டது: $path';
  }

  @override
  String get cameraNotAvailable => 'கேமரா கிடைக்கவில்லை';

  @override
  String errorCapturingImage(Object error) {
    return 'படம் கேப்சர் செய்யும் பிழை: $error';
  }

  @override
  String get safe => 'பாதுகாப்பானது';

  @override
  String get inWithdrawal => 'விலகலில்';

  @override
  String get phoneNumber => 'தொலைபேசி எண்';

  @override
  String get farmerId => 'விவசாயி ஐடி';

  @override
  String get guest => 'விருந்தினர்';

  @override
  String get home => 'முகப்பு';

  @override
  String get animals => 'விலங்குகள்';

  @override
  String get history => 'வரலாறு';

  @override
  String get noHistoryYet => 'இன்னும் ஆலோசனை வரலாறு இல்லை.';

  @override
  String lastMedicineDosage(Object dosage, Object end, Object medicine) {
    return 'கடைசி மருந்து: $medicine • $dosage mg/kg\nவிலகல் முடிவு: $end';
  }

  @override
  String get unknown => 'தெரியாதது';

  @override
  String get selectLanguage => 'மொழி தேர்ந்தெடு';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get chooseYourLanguage => 'உங்கள் மொழியை தேர்ந்தெடுக்கவும்';

  @override
  String get continueButton => 'தொடர்ந்து';

  @override
  String get enterUsernamePasswordVetId =>
      'பயனர்பெயர்/கடவுச்சொல்/மருத்துவர் ஐடி உள்ளீடு செய்யுங்கள்';

  @override
  String get productType => 'தயாரிப்பு வகை';

  @override
  String get mrlInformation => 'எம்ஆர்எல் தகவல்';

  @override
  String get currentMRL => 'தற்போதைய எம்ஆர்எல்';

  @override
  String get status => 'நிலை';

  @override
  String get withdrawalDays => 'விலகல் நாட்கள்';

  @override
  String get allStatus => 'அனைத்து நிலை';

  @override
  String get withdrawal => 'விலகல்';

  @override
  String ageWithValue(Object age) {
    return 'வயது • $age';
  }

  @override
  String get view => 'பார்க்க';

  @override
  String get delete => 'நீக்கு';

  @override
  String get addedToDatabase => 'தரவுத்தளத்தில் சேர்க்கப்பட்டது';

  @override
  String get withdrawalGuides => 'விலகல் வழிகாட்டிகள்';

  @override
  String get noAnimalsInWithdrawalPeriod => 'விலகல் காலத்தில் விலங்குகள் இல்லை';

  @override
  String get allAnimalsSafeForConsumption =>
      'உங்கள் அனைத்து விலங்குகளும் நுகர்வுக்கு பாதுகாப்பானவை';

  @override
  String get withdrawalDetails => 'விலகல் விவரங்கள்';

  @override
  String get timeRemaining => 'மீதமுள்ள நேரம்';

  @override
  String get medicineAndWithdrawal => 'மருந்து மற்றும் விலகல்';

  @override
  String get consultingVet => 'ஆலோசனை மருத்துவர்';

  @override
  String get noVetAssigned => 'மருத்துவர் ஒதுக்கப்படவில்லை';

  @override
  String get viewMrlGraph => 'எம்ஆர்எல் வரைபடத்தை பார்க்க';

  @override
  String get started => 'தொடங்கியது';

  @override
  String get ends => 'முடிகிறது';

  @override
  String get prescriptions => 'மருந்து பரிந்துரைகள்';

  @override
  String get qrCodes => 'QR குறியீடுகள்';

  @override
  String get analytics => 'பகுப்பாய்வு';

  @override
  String get alerts => 'எச்சரிக்கைகள்';

  @override
  String get blockchain => 'பிளாக்செயின்';

  @override
  String get noDigitalPrescriptions => 'டிஜிட்டல் மருந்து பரிந்துரைகள் இல்லை';

  @override
  String get prescriptionsWillAppearHere =>
      'மருத்துவ ஆலோசனைகளுக்குப் பிறகு மருந்து பரிந்துரைகள் இங்கே தோன்றும்';

  @override
  String get prescriptionFor => 'மருந்து பரிந்துரை';

  @override
  String get active => 'செயலில்';

  @override
  String get completed => 'முடிந்தது';

  @override
  String get digitalPrescription => 'டிஜிட்டல் மருந்து பரிந்துரை';

  @override
  String get prescriptionStatus => 'மருந்து பரிந்துரை நிலை';

  @override
  String get activeWithdrawalPeriod => 'விலகல் காலம் செயலில்';

  @override
  String get completedSafeToConsume => 'முடிந்தது - நுகர்வுக்கு பாதுகாப்பானது';

  @override
  String get animalInformation => 'விலங்கு தகவல்';

  @override
  String get prescriptionDetails => 'மருந்து பரிந்துரை விவரங்கள்';

  @override
  String get prescribedBy => 'பரிந்துரை செய்தவர்';

  @override
  String get viewDetails => 'விவரங்களை பார்க்க';

  @override
  String get qrCertificateGenerator => 'QR சான்றிதழ் உருவாக்கி';

  @override
  String get generateQrCodesForAnimalCertificates =>
      'விலங்கு சான்றிதழ்களுக்கு QR குறியீடுகளை உருவாக்குங்கள்';

  @override
  String get qrGenerationDate => 'QR உருவாக்க தேதி';

  @override
  String get noAnimalsAvailable => 'விலங்குகள் கிடைக்கவில்லை';

  @override
  String get addAnimalsToGenerateQrCertificates =>
      'QR சான்றிதழ்களை உருவாக்க விலங்குகளை சேர்க்கவும்';

  @override
  String get generateQrCertificate => 'QR சான்றிதழ் உருவாக்கு';

  @override
  String get qrCertificateGenerated => 'QR சான்றிதழ் உருவாக்கப்பட்டது';

  @override
  String get animalInWithdrawalNotSafeToConsume =>
      'விலங்கு விலகலில் உள்ளது - நுகர்வுக்கு பாதுகாப்பல்ல';

  @override
  String get doNotConsumeProducts =>
      'இந்த விலங்கின் தயாரிப்புகளை நுகர்வு செய்ய வேண்டாம்';

  @override
  String get certificateDetails => 'சான்றிதழ் விவரங்கள்';

  @override
  String get validUntil => 'செல்லுபடியாகும் வரை';

  @override
  String get withdrawalEnds => 'விலகல் முடிகிறது';

  @override
  String get share => 'பகிர்';

  @override
  String get farmAnalytics => 'பண்ணை பகுப்பாய்வு';

  @override
  String get animalHealthAnalytics => 'விலங்கு ஆரோக்கிய பகுப்பாய்வு';

  @override
  String get withdrawalPeriodAnalytics => 'விலகல் கால பகுப்பாய்வு';

  @override
  String get mrlComplianceAnalytics => 'எம்ஆர்எல் இணங்கல் பகுப்பாய்வு';

  @override
  String get farmAlerts => 'பண்ணை எச்சரிக்கைகள்';

  @override
  String get withdrawalAlerts => 'விலகல் எச்சரிக்கைகள்';

  @override
  String get healthAlerts => 'ஆரோக்கிய எச்சரிக்கைகள்';

  @override
  String get complianceAlerts => 'இணங்கல் எச்சரிக்கைகள்';

  @override
  String get blockchainVerification => 'பிளாக்செயின் சரிபார்ப்பு';

  @override
  String get animalRecordsOnBlockchain => 'பிளாக்செயினில் விலங்கு பதிவுகள்';

  @override
  String get verifyAnimalData => 'விலங்கு தரவை சரிபார்க்க';

  @override
  String get blockchainTransactions => 'பிளாக்செயின் பரிவர்த்தனைகள்';

  @override
  String get aiVetAssistant => 'AI மருத்துவ உதவியாளர்';

  @override
  String get aiTreatmentRecommendations => 'AI சிகிச்சை பரிந்துரைகள்';

  @override
  String get getAiRecommendations => 'AI பரிந்துரைகளை பெற';

  @override
  String get aiHealthAnalysis => 'AI ஆரோக்கிய பகுப்பாய்வு';

  @override
  String get shareWithVet => 'மருத்துவருடன் பகிர்';

  @override
  String get digitalCertificate => 'டிஜிட்டல் சான்றிதழ்';

  @override
  String get withdrawalPeriodActive => 'விலகல் காலம் செயலில்';

  @override
  String get withdrawalPeriodCompleted => 'விலகல் காலம் முடிந்தது';

  @override
  String get endsOn => 'முடிகிறது';

  @override
  String get certificateReadyForSharing =>
      'பகிர்வுக்கு QR சான்றிதழ் தயாராக உள்ளது';

  @override
  String get animalIdentification => 'விலங்கு அடையாளம்';

  @override
  String get enterUniqueAnimalId =>
      'தனித்துவமான விலங்கு ஐடியை உள்ளீடு செய்யுங்கள்';

  @override
  String get generateId => 'ஐடி உருவாக்கு';

  @override
  String get pleaseEnterAnimalId => 'விலங்கு ஐடியை உள்ளீடு செய்யுங்கள்';

  @override
  String get pleaseSelectSpecies => 'இனத்தை தேர்ந்தெடுக்கவும்';

  @override
  String get breedAgeDetails => 'இனம் மற்றும் வயது விவரங்கள்';

  @override
  String get pleaseEnterAge => 'வயதை உள்ளீடு செய்யுங்கள்';

  @override
  String get enterValidAge => 'சரியான வயதை உள்ளீடு செய்யுங்கள் (0-50)';

  @override
  String get enterCustomBreed => 'தனிப்பயன் இனத்தை உள்ளீடு செய்யுங்கள்';

  @override
  String get enterBreedName => 'இனத்தின் பெயரை உள்ளீடு செய்யுங்கள்';

  @override
  String get pleaseSelectBreed => 'இனத்தை தேர்ந்தெடுக்கவும்';

  @override
  String get pleaseEnterBreed => 'இனத்தை உள்ளீடு செய்யுங்கள்';

  @override
  String get otherCustom => 'மற்றவை (தனிப்பயன்)';

  @override
  String get selectSpeciesFirst => 'முதலில் இனத்தை தேர்ந்தெடு';

  @override
  String get saving => 'சேமிக்கப்படுகிறது...';

  @override
  String get animalAddedSuccessfully => 'விலங்கு வெற்றிகரமாக சேர்க்கப்பட்டது!';

  @override
  String get failedToSaveAnimal =>
      'விலங்கை சேமிக்க இயலவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get allTypes => 'அனைத்து வகைகளும்';

  @override
  String get withdrawalWarning => 'விலகல் எச்சரிக்கை';

  @override
  String get withdrawalExpired => 'விலகல் காலாவதியானது';

  @override
  String get mrlViolation => 'எம்ஆர்எல் மீறல்';

  @override
  String get treatmentOverdue => 'சிகிச்சை காலாவதியானது';

  @override
  String get complianceRisk => 'இணங்கல் ஆபத்து';

  @override
  String get allSeverities => 'அனைத்து தீவிரங்கள்';

  @override
  String get totalAlerts => 'மொத்த எச்சரிக்கைகள்';

  @override
  String get unread => 'படிக்காதவை';

  @override
  String get critical => 'முக்கியமானது';

  @override
  String get noAlertsFound => 'எச்சரிக்கைகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get allComplianceChecksPassing =>
      'அனைத்து இணங்கல் சரிபார்ப்புகளும் தேர்ச்சி பெறுகின்றன';

  @override
  String get createCustomAlert => 'தனிப்பயன் எச்சரிக்கை உருவாக்கு';

  @override
  String get alertTitle => 'எச்சரிக்கை தலைப்பு';

  @override
  String get alertMessage => 'எச்சரிக்கை செய்தி';

  @override
  String get severity => 'தீவிரம்';

  @override
  String get alertType => 'எச்சரிக்கை வகை';

  @override
  String get createAlert => 'எச்சரிக்கை உருவாக்கு';

  @override
  String get read => 'படி';

  @override
  String get markAsRead => 'படித்ததாக குறி';

  @override
  String get dismiss => 'நிராகரி';

  @override
  String get justNow => 'இப்போதே';

  @override
  String minutesAgo(Object count) {
    return '$count நிமிடங்களுக்கு முன்பு';
  }

  @override
  String hoursAgo(Object count) {
    return '$count மணி நேரங்களுக்கு முன்பு';
  }

  @override
  String daysAgo(Object count) {
    return '$count நாட்களுக்கு முன்பு';
  }

  @override
  String get low => 'குறைவு';

  @override
  String get medium => 'நடுத்தரம்';

  @override
  String get high => 'அதிகம்';

  @override
  String animalIdLabel(Object id) {
    return 'விலங்கு ஐடி: $id';
  }

  @override
  String get cow => 'மாடு';

  @override
  String get buffalo => 'எருமை';

  @override
  String get goat => 'ஆடு';

  @override
  String get sheep => 'செம்மறி ஆடு';

  @override
  String get pig => 'பன்றி';

  @override
  String get poultry => 'கோழி';

  @override
  String get other => 'மற்றவை';

  @override
  String get jersey => 'ஜெர்சி';

  @override
  String get holstein => 'ஹால்ஸ்டைன்';

  @override
  String get sahiwal => 'சஹிவால்';

  @override
  String get gir => 'கிர்';

  @override
  String get redSindhi => 'சிவப்பு சிந்தி';

  @override
  String get tharparkar => 'தார்பார்கர்';

  @override
  String get murrah => 'முற்றா';

  @override
  String get niliRavi => 'நீலி ராவி';

  @override
  String get jaffarabadi => 'ஜஃபராபாதி';

  @override
  String get surti => 'சூர்தி';

  @override
  String get bhadawari => 'பாதவரி';

  @override
  String get beetal => 'பீட்டல்';

  @override
  String get boer => 'போயர்';

  @override
  String get jamunapari => 'ஜாமுனபாரி';

  @override
  String get sirohi => 'சிரோஹி';

  @override
  String get barbari => 'பார்பரி';

  @override
  String get merino => 'மெரினோ';

  @override
  String get rambouillet => 'ராம்போலியட்';

  @override
  String get cheviot => 'செவியாட்';

  @override
  String get suffolk => 'சஃபோக்';

  @override
  String get hampshire => 'ஹாம்ப்ஷயர்';

  @override
  String get largeWhite => 'பெரிய வெள்ளை';

  @override
  String get yorkshire => 'யார்க்ஷயர்';

  @override
  String get berkshire => 'பெர்க்ஷயர்';

  @override
  String get desi => 'தேசி';

  @override
  String get layer => 'லேயர்';

  @override
  String get broiler => 'ப்ராய்லர்';

  @override
  String get amuAnalyticsDashboard => 'ஏஎம்யூ பகுப்பாய்வு டாஷ்போர்ட்';

  @override
  String get noDataAvailable => 'தரவு எதுவும் கிடைக்கவில்லை';

  @override
  String analysisPeriod(Object end, Object start) {
    return 'பகுப்பாய்வு காலம்: $start முதல் $end';
  }

  @override
  String get summaryStatistics => 'சுருக்கமான புள்ளியியல்';

  @override
  String get totalAnimals => 'மொத்த விலங்குகள்';

  @override
  String get animalsTreated => 'சிகிச்சையளிக்கப்பட்ட விலங்குகள்';

  @override
  String get treatmentRate => 'சிகிச்சை விகிதம்';

  @override
  String get complianceIssues => 'இணங்கல் சிக்கல்கள்';

  @override
  String get trendAnalysis => 'மரபு பகுப்பாய்வு';

  @override
  String get trendDirection => 'மரபு திசை';

  @override
  String get volatility => 'அதிர்ச்சி';

  @override
  String get seasonalPatterns => 'பருவகால முறைகள்';

  @override
  String get noSeasonalPatternsDetected =>
      'பருவகால முறைகள் எதுவும் கண்டறியப்படவில்லை';

  @override
  String peakMonths(Object months) {
    return 'உச்ச மாதங்கள்: $months';
  }

  @override
  String lowMonths(Object months) {
    return 'குறைவான மாதங்கள்: $months';
  }

  @override
  String get complianceAnalysis => 'இணங்கல் பகுப்பாய்வு';

  @override
  String get complianceRate => 'இணங்கல் விகிதம்';

  @override
  String get compliantAnimals => 'இணங்கிய விலங்குகள்';

  @override
  String get riskFactors => 'ஆபத்து காரணிகள்';

  @override
  String get noSignificantRiskFactors =>
      'முக்கியமான ஆபத்து காரணிகள் எதுவும் அடையாளம் காணப்படவில்லை';

  @override
  String get noMedicineUsageData =>
      'மருந்து பயன்பாட்டு தரவு எதுவும் கிடைக்கவில்லை';

  @override
  String get medicineUsageDistribution => 'மருந்து பயன்பாட்டு விநியோகம்';

  @override
  String get noRecommendationsAvailable => 'பரிந்துரைகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get recommendations => 'பரிந்துரைகள்';

  @override
  String failedToLoadAnalytics(Object error) {
    return 'பகுப்பாய்வை ஏற்றுவதில் தோல்வி: $error';
  }

  @override
  String get addAnimalsFirstAi =>
      'AI பரிந்துரைகளைப் பெற சில விலங்குகளை முதலில் சேர்க்கவும்';

  @override
  String failedToGetAiRecommendations(Object error) {
    return 'AI பரிந்துரைகளைப் பெறுவதில் தோல்வி: $error';
  }

  @override
  String get noSpecificRecommendations =>
      'இந்த நேரத்தில் குறிப்பிட்ட பரிந்துரைகள் எதுவும் இல்லை';

  @override
  String get healthScore => 'ஆரோக்கிய மதிப்பெண்';

  @override
  String get aiRecommendations => 'AI பரிந்துரைகள்';

  @override
  String get preventiveCare => 'தடுப்பு பராமரிப்பு';

  @override
  String failedToAnalyzeHealth(Object error) {
    return 'ஆரோக்கியத்தை பகுப்பாய்வு செய்வதில் தோல்வி: $error';
  }

  @override
  String get loggingOut => 'வெளியேறுகிறது...';

  @override
  String get aiTreatmentRecommendationsDesc => 'AI சிகிச்சை பரிந்துரைகள்';

  @override
  String ageAddedToDatabase(Object age) {
    return 'வயது: $age • தரவுத்தளத்தில் சேர்க்கப்பட்டது';
  }

  @override
  String get searchAnimals => 'விலங்குகளைத் தேடு';

  @override
  String get withdrawalStatus => 'விலகல்';

  @override
  String get safeStatus => 'பாதுகாப்பானது';

  @override
  String get inWithdrawalStatus => 'விலகலில்';

  @override
  String get viewButton => 'பார்';

  @override
  String get aiButton => 'AI';

  @override
  String get deleteButton => 'நீக்கு';

  @override
  String get deletedMessage => 'நீக்கப்பட்டது';

  @override
  String prescriptionForSpecies(Object species) {
    return '$species க்கான மருந்து பரிந்துரை';
  }

  @override
  String get activeStatus => 'செயலில்';

  @override
  String get completedStatus => 'முடிந்தது';

  @override
  String get medicineLabel => 'மருந்து';

  @override
  String get dosageLabel => 'அளவு';

  @override
  String get withdrawalPeriodLabel => 'விலகல் காலம்';

  @override
  String get endsLabel => 'முடிகிறது';

  @override
  String prescribedByLabel(Object vet) {
    return 'பரிந்துரைத்தவர்: $vet';
  }

  @override
  String get viewDetailsButton => 'விவரங்களைப் பார்';

  @override
  String get digitalPrescriptionTitle => 'டிஜிட்டல் மருந்து பரிந்துரை';

  @override
  String get prescriptionStatusLabel => 'மருந்து பரிந்துரை நிலை';

  @override
  String get activeWithdrawalPeriodStatus => 'செயலில் - விலகல் காலம்';

  @override
  String get completedSafeToConsumeStatus =>
      'முடிந்தது - நுகர்வுக்கு பாதுகாப்பானது';

  @override
  String get animalInformationSection => 'விலங்கு தகவல்';

  @override
  String get prescriptionDetailsSection => 'மருந்து பரிந்துரை விவரங்கள்';

  @override
  String speciesAndBreedLabel(Object breed, Object species) {
    return 'இனம் மற்றும் வயது: $species - $breed';
  }

  @override
  String get productTypeLabel => 'தயாரிப்பு வகை';

  @override
  String prescribedDateLabel(Object date) {
    return 'பரிந்துரைக்கப்பட்ட தேதி: $date';
  }

  @override
  String withdrawalEndsLabel(Object date) {
    return 'விலகல் முடிகிறது: $date';
  }

  @override
  String get mrlStatusSection => 'எம்ஆர்எல் நிலை';

  @override
  String currentMrlLabel(Object mrl) {
    return 'தற்போதைய எம்ஆர்எல்: $mrl அலகுகள்';
  }

  @override
  String statusLabel(Object status) {
    return 'நிலை: $status';
  }

  @override
  String get veterinaryInformationSection => 'மருத்துவ தகவல்';

  @override
  String consultingVetLabel(Object vet) {
    return 'ஆலோசனை மருத்துவர்: $vet';
  }

  @override
  String vetIdLabel(Object id) {
    return 'மருத்துவர் ஐடி: $id';
  }

  @override
  String get noVetAssignedMessage => 'மருத்துவர் எவரும் ஒதுக்கப்படவில்லை';

  @override
  String get viewMrlGraphButton => 'எம்ஆர்எல் வரைபடத்தைப் பார்';

  @override
  String get noAnimalsAvailableMessage => 'விலங்குகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get addAnimalsToGenerateQrMessage =>
      'QR சான்றிதழ்களை உருவாக்க விலங்குகளைச் சேர்க்கவும்';

  @override
  String get qrCertificateGeneratorTitle => 'QR சான்றிதழ் உருவாக்கி';

  @override
  String get generateQrCodesDesc =>
      'விலங்கு சான்றிதழ்களுக்கு QR குறியீடுகளை உருவாக்கு';

  @override
  String qrGenerationDateLabel(Object date) {
    return 'QR உருவாக்க தேதி: $date';
  }

  @override
  String speciesBreedDisplay(Object breed, Object species) {
    return '$species - $breed';
  }

  @override
  String idDisplay(Object id) {
    return 'ஐடி: $id';
  }

  @override
  String get withdrawalPeriodActiveMessage => 'விலகல் காலம் செயலில்';

  @override
  String get withdrawalPeriodCompletedMessage => 'விலகல் காலம் முடிந்தது';

  @override
  String endsDateDisplay(Object date) {
    return 'முடிகிறது: $date';
  }

  @override
  String get generateQrCertificateButton => 'QR சான்றிதழை உருவாக்கு';

  @override
  String get generatingQrCertificateMessage =>
      'QR சான்றிதழ் உருவாக்கப்படுகிறது...';

  @override
  String get qrCertificateGeneratedTitle => 'QR சான்றிதழ் உருவாக்கப்பட்டது';

  @override
  String get animalInWithdrawalWarning =>
      '⚠️ விலங்கு விலகலில் உள்ளது - நுகர்வுக்கு பாதுகாப்பானது அல்ல';

  @override
  String get safeToConsumeMessage => '✅ நுகர்வுக்கு பாதுகாப்பானது';

  @override
  String get doNotConsumeWarning =>
      'விலகல் காலம் முடியும் வரை இந்த விலங்கின் தயாரிப்புகளை நுகர வேண்டாம்.';

  @override
  String get certificateDetailsSection => 'சான்றிதழ் விவரங்கள்';

  @override
  String get speciesLabel => 'இனம்';

  @override
  String farmerIdLabel(Object id) {
    return 'விவசாயி ஐடி: $id';
  }

  @override
  String generatedDateLabel(Object date) {
    return 'உருவாக்கப்பட்ட தேதி: $date';
  }

  @override
  String validUntilLabel(Object date) {
    return 'செல்லுபடியாகும் வரை: $date';
  }

  @override
  String get qrCertificateReadyMessage =>
      'பகிர்வுக்கு QR சான்றிதழ் தயாராக உள்ளது';

  @override
  String get errorTitle => 'பிழை';

  @override
  String failedToGenerateQrMessage(Object error) {
    return 'QR சான்றிதழை உருவாக்குவதில் தோல்வி: $error';
  }

  @override
  String get doNotConsumeProductsWarning =>
      'Do not consume products from this animal until withdrawal period ends.';
}

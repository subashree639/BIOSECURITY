// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'एबीसी (एंटीबायोटिक चेक)';

  @override
  String get appSubtitle => 'किसानों के लिए एंटीबायोटिक चेक';

  @override
  String get farmer => 'किसान';

  @override
  String get vet => 'पशु चिकित्सक';

  @override
  String get seller => 'विक्रेता';

  @override
  String get login => 'लॉगिन';

  @override
  String get register => 'पंजीकरण';

  @override
  String get newToApp => 'ऐप में नए हैं? पंजीकरण करें';

  @override
  String get tapMicSayPassphrase => 'माइक पर टैप करें और अपना पासफ्रेज बोलें';

  @override
  String voiceRegistered(Object id) {
    return 'वॉइस पंजीकृत — आईडी: $id';
  }

  @override
  String get listening => 'किसान — सुन रहा है...';

  @override
  String get loginWithMobile => 'मोबाइल के साथ लॉगिन (OTP)';

  @override
  String get enterMobileNumber => 'मोबाइल नंबर दर्ज करें';

  @override
  String get sendOTP => 'OTP भेजें';

  @override
  String get verifyLogin => 'सत्यापित करें और लॉगिन करें';

  @override
  String get resendOTP => 'OTP पुनः भेजें';

  @override
  String get enterOTP => '6-अंकीय OTP दर्ज करें';

  @override
  String otpSentTo(Object number) {
    return 'OTP भेजा गया: $number';
  }

  @override
  String get incorrectOTP => 'गलत OTP';

  @override
  String get enterValidMobile => 'मान्य मोबाइल दर्ज करें';

  @override
  String mockOTP(Object otp) {
    return 'मॉक OTP: $otp';
  }

  @override
  String mockOTPFarmer(Object otp) {
    return 'मॉक OTP (किसान): $otp';
  }

  @override
  String mockOTPSeller(Object otp) {
    return 'मॉक OTP (विक्रेता): $otp';
  }

  @override
  String get veterinaryLogin => 'पशु चिकित्सा लॉगिन';

  @override
  String get pleaseEnterLoginDetails => 'कृपया अपना लॉगिन विवरण दर्ज करें';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get password => 'पासवर्ड';

  @override
  String get vetIdRegNo => 'पशु चिकित्सक आईडी / पंजीकरण संख्या';

  @override
  String get loginAsVet => 'पशु चिकित्सक के रूप में लॉगिन करें';

  @override
  String get newToAppRegisterVet =>
      'ऐप में नए हैं? पशु चिकित्सक के रूप में पंजीकरण करें';

  @override
  String get verifying => 'सत्यापित किया जा रहा है...';

  @override
  String get invalidVetCredentials => 'अमान्य पशु चिकित्सक क्रेडेंशियल';

  @override
  String get sellerUser => 'विक्रेता / उपयोगकर्ता';

  @override
  String get pleaseEnterPhoneNumber => 'कृपया अपना फोन नंबर दर्ज करें';

  @override
  String get verifyOTP => 'OTP सत्यापित करें';

  @override
  String get otpSent => 'OTP भेजा गया';

  @override
  String get registerAsFarmer => 'किसान के रूप में पंजीकरण करें';

  @override
  String get welcomeRegister =>
      'स्वागत है! एबीसी का उपयोग करने के लिए पंजीकरण करें — वॉइस या मोबाइल पंजीकरण चुनें';

  @override
  String get voiceRegistration => 'वॉइस पंजीकरण';

  @override
  String get voiceRegDesc =>
      'वॉइस प्रोफाइल पंजीकृत करें (सिमुलेटेड एनरोल)। एक साधारण किसान आईडी बनाएं जिसे आप पशु चिकित्सकों के साथ साझा कर सकते हैं।';

  @override
  String get mobileRegistration => 'मोबाइल पंजीकरण';

  @override
  String get mobileRegDesc =>
      'अपने फोन नंबर का उपयोग करके पंजीकरण करें (OTP)। आप अपने फोन को किसान आईडी के रूप में रख सकते हैं या एक कस्टम आईडी चुन सकते हैं।';

  @override
  String get voiceEnrollment => 'वॉइस एनरोलमेंट (सिमुलेटेड)';

  @override
  String get tapEnrollStart =>
      'वॉइस कैप्चर शुरू करने के लिए ENROLL पर टैप करें। आपको तीन बार एक छोटा वाक्य बोलना होगा।';

  @override
  String get recordingVoice =>
      'आपकी आवाज रिकॉर्ड की जा रही है — स्थिर रहें और जब संकेत मिले तो वाक्य बोलें।';

  @override
  String get enrollmentComplete => 'एनरोलमेंट पूरा हुआ — आपका किसान आईडी है:';

  @override
  String get enrollVoice => 'वॉइस एनरोल करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get processingEnrollment => 'एनरोलमेंट प्रोसेस किया जा रहा है...';

  @override
  String get continueToDashboard => 'डैशबोर्ड पर जारी रखें';

  @override
  String get retryEnrollment => 'एनरोलमेंट पुनः प्रयास करें';

  @override
  String get registerByMobile => 'मोबाइल द्वारा पंजीकरण करें';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get addCustomId => 'कस्टम आईडी जोड़ें?';

  @override
  String get customFarmerId => 'कस्टम किसान आईडी (अक्षरांकीय)';

  @override
  String get ifNotCustom =>
      'यदि आप एक कस्टम आईडी प्रदान नहीं करते हैं, तो आपका फोन नंबर आपके किसान आईडी के रूप में उपयोग किया जाएगा।';

  @override
  String get enterValidPhone => 'मान्य फोन दर्ज करें';

  @override
  String get idAlreadyInUse => 'कस्टम आईडी पहले से उपयोग में है';

  @override
  String registeredFarmerId(Object id) {
    return 'पंजीकृत — किसान आईडी: $id';
  }

  @override
  String registrationError(Object error) {
    return 'पंजीकरण त्रुटि: $error';
  }

  @override
  String get registerVet => 'पशु चिकित्सक पंजीकरण करें';

  @override
  String get registerAsVetDoctor => 'पशु चिकित्सक के रूप में पंजीकरण करें';

  @override
  String get useProfessionalCredentials =>
      'पंजीकरण करने के लिए पेशेवर क्रेडेंशियल का उपयोग करें (उपयोगकर्ता नाम + पासवर्ड + पशु चिकित्सक आईडी)।';

  @override
  String get registerWithCredentials => 'क्रेडेंशियल के साथ पंजीकरण करें';

  @override
  String get createUsernamePasswordVetId =>
      'उपयोगकर्ता नाम + पासवर्ड + पशु चिकित्सक आईडी बनाएं';

  @override
  String get contactSupport => 'सहायता से संपर्क करें';

  @override
  String get enterpriseOnboarding =>
      'यदि आपको एंटरप्राइज ऑनबोर्डिंग की आवश्यकता है तो हमें बताएं';

  @override
  String get contactSupportPlaceholder => 'सहायता से संपर्क करें (प्लेसहोल्डर)';

  @override
  String get veterinaryRegistration => 'पशु चिकित्सा पंजीकरण';

  @override
  String get fillAllFields => 'सभी फ़ील्ड भरें';

  @override
  String get vetRegistered =>
      'पशु चिकित्सक पंजीकृत — लॉगिन करने के लिए क्रेडेंशियल का उपयोग करें';

  @override
  String get farmerDashboard => 'किसान डैशबोर्ड';

  @override
  String get logout => 'लॉगआउट';

  @override
  String animalsCount(Object count, Object withdrawal) {
    return 'जानवर: $count • निकासी में: $withdrawal';
  }

  @override
  String get animalDatabase => 'जानवर डेटाबेस';

  @override
  String get manageAnimalDatabase => 'जानवर डेटाबेस प्रबंधित करें';

  @override
  String get addAnimal => 'जानवर जोड़ें';

  @override
  String get addNewAnimal => 'नया जानवर जोड़ें';

  @override
  String get guides => 'गाइड';

  @override
  String get withdrawalDosingGuides => 'निकासी और खुराक गाइड';

  @override
  String get guidesPlaceholder => 'गाइड (प्लेसहोल्डर)';

  @override
  String get contactVet => 'पशु चिकित्सक से संपर्क करें';

  @override
  String get shareFarmerIdWithVet => 'पशु चिकित्सक के साथ किसान आईडी साझा करें';

  @override
  String shareId(Object id) {
    return 'आईडी साझा करें: $id';
  }

  @override
  String get animalId => 'जानवर आईडी';

  @override
  String get enterId => 'आईडी दर्ज करें';

  @override
  String get generate => 'जनरेट';

  @override
  String get species => 'प्रजाति';

  @override
  String get selectSpecies => 'प्रजाति चुनें';

  @override
  String get age => 'आयु (वर्ष)';

  @override
  String get enterAge => 'आयु दर्ज करें';

  @override
  String get breed => 'नस्ल';

  @override
  String get chooseBreed => 'नस्ल चुनें';

  @override
  String get enterBreed => 'नस्ल दर्ज करें';

  @override
  String get saveAnimal => 'जानवर सहेजें';

  @override
  String get animalSaved => 'जानवर सहेजा गया';

  @override
  String get animalDatabaseTitle => 'जानवर डेटाबेस';

  @override
  String get searchByIdSpeciesBreed => 'आईडी, प्रजाति या नस्ल द्वारा खोजें';

  @override
  String get all => 'सभी';

  @override
  String get noAnimalsYet => 'अभी तक कोई जानवर नहीं';

  @override
  String get tapAddCreateAnimals => 'जानवर बनाने के लिए जोड़ें पर टैप करें';

  @override
  String get animalDetails => 'जानवर विवरण';

  @override
  String get close => 'बंद करें';

  @override
  String get id => 'आईडी';

  @override
  String get lastMedicine => 'अंतिम दवा';

  @override
  String get withdrawalEnd => 'निकासी समाप्ति';

  @override
  String get deleteAnimal => 'जानवर हटाएं';

  @override
  String get deleted => 'हटाया गया';

  @override
  String get vetConsulting => 'पशु चिकित्सा परामर्श';

  @override
  String get enterFarmerIdOrPhone => 'किसान आईडी या फोन';

  @override
  String get load => 'लोड करें';

  @override
  String loadedAnimals(Object count) {
    return 'जानवर लोड किए गए — कुल $count (डेमो)';
  }

  @override
  String get enterFarmerId => 'किसान आईडी या फोन दर्ज करें';

  @override
  String get noAnimalsInDatabase => 'डेटाबेस में कोई जानवर नहीं।';

  @override
  String get consult => 'परामर्श';

  @override
  String consultAnimal(Object id) {
    return 'परामर्श • $id';
  }

  @override
  String get medicine => 'दवा';

  @override
  String get dosage => 'खुराक (mg/kg)';

  @override
  String get withdrawalPeriod => 'निकासी अवधि (दिन)';

  @override
  String get notes => 'नोट्स (वैकल्पिक)';

  @override
  String get saveConsultation => 'परामर्श सहेजें';

  @override
  String get savedToAnimalRecord => 'जानवर रिकॉर्ड में परामर्श सहेजा गया';

  @override
  String get enterMedicine => 'दवा दर्ज करें';

  @override
  String get consultingHistory => 'परामर्श इतिहास';

  @override
  String get noConsultationHistory =>
      'परामर्श इतिहास प्लेसहोल्डर (जब आवश्यक हो तो बनाए रखें)।';

  @override
  String get sellerDashboard => 'विक्रेता डैशबोर्ड';

  @override
  String get foodScanner => 'खाद्य स्कैनर';

  @override
  String get scanFoodQR => 'खाद्य/QR स्कैन करें';

  @override
  String get animalScanner => 'जानवर स्कैनर';

  @override
  String get scanAnimalTag => 'जानवर टैग स्कैन करें';

  @override
  String get foodScannerPlaceholder => 'खाद्य स्कैनर प्लेसहोल्डर';

  @override
  String get animalScannerPlaceholder => 'जानवर स्कैनर प्लेसहोल्डर';

  @override
  String get camera => 'कैमरा';

  @override
  String imageCaptured(Object path) {
    return 'छवि कैप्चर की गई: $path';
  }

  @override
  String get cameraNotAvailable => 'कैमरा उपलब्ध नहीं है';

  @override
  String errorCapturingImage(Object error) {
    return 'छवि कैप्चर करने में त्रुटि: $error';
  }

  @override
  String get safe => 'सुरक्षित';

  @override
  String get inWithdrawal => 'निकासी में';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get farmerId => 'किसान आईडी';

  @override
  String get guest => 'अतिथि';

  @override
  String get home => 'होम';

  @override
  String get animals => 'जानवर';

  @override
  String get history => 'इतिहास';

  @override
  String get noHistoryYet => 'अभी तक कोई परामर्श इतिहास नहीं।';

  @override
  String lastMedicineDosage(Object dosage, Object end, Object medicine) {
    return 'अंतिम दवा: $medicine • $dosage mg/kg\nनिकासी समाप्ति: $end';
  }

  @override
  String get unknown => 'अज्ञात';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get tamil => 'तमिल';

  @override
  String get chooseYourLanguage => 'अपनी भाषा चुनें';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get enterUsernamePasswordVetId =>
      'उपयोगकर्ता नाम/पासवर्ड/पशु चिकित्सक आईडी दर्ज करें';

  @override
  String get productType => 'उत्पाद प्रकार';

  @override
  String get mrlInformation => 'एमआरएल जानकारी';

  @override
  String get currentMRL => 'वर्तमान एमआरएल';

  @override
  String get status => 'स्थिति';

  @override
  String get withdrawalDays => 'निकासी दिन';

  @override
  String get allStatus => 'सभी स्थिति';

  @override
  String get withdrawal => 'निकासी';

  @override
  String ageWithValue(Object age) {
    return 'आयु • $age';
  }

  @override
  String get view => 'देखें';

  @override
  String get delete => 'हटाएं';

  @override
  String get addedToDatabase => 'डेटाबेस में जोड़ा गया';

  @override
  String get withdrawalGuides => 'निकासी गाइड';

  @override
  String get noAnimalsInWithdrawalPeriod => 'निकासी अवधि में कोई जानवर नहीं';

  @override
  String get allAnimalsSafeForConsumption =>
      'आपके सभी जानवर उपभोग के लिए सुरक्षित हैं';

  @override
  String get withdrawalDetails => 'निकासी विवरण';

  @override
  String get timeRemaining => 'शेष समय';

  @override
  String get medicineAndWithdrawal => 'दवा और निकासी';

  @override
  String get consultingVet => 'परामर्शी पशु चिकित्सक';

  @override
  String get noVetAssigned => 'कोई पशु चिकित्सक नियुक्त नहीं';

  @override
  String get viewMrlGraph => 'एमआरएल ग्राफ देखें';

  @override
  String get started => 'शुरू हुआ';

  @override
  String get ends => 'समाप्त होता है';

  @override
  String get prescriptions => 'दवा निर्देश';

  @override
  String get qrCodes => 'QR कोड';

  @override
  String get analytics => 'विश्लेषण';

  @override
  String get alerts => 'अलर्ट';

  @override
  String get blockchain => 'ब्लॉकचेन';

  @override
  String get noDigitalPrescriptions => 'कोई डिजिटल दवा निर्देश नहीं';

  @override
  String get prescriptionsWillAppearHere =>
      'पशु चिकित्सा परामर्श के बाद दवा निर्देश यहां दिखाई देंगे';

  @override
  String get prescriptionFor => 'दवा निर्देश';

  @override
  String get active => 'सक्रिय';

  @override
  String get completed => 'पूर्ण';

  @override
  String get digitalPrescription => 'डिजिटल दवा निर्देश';

  @override
  String get prescriptionStatus => 'दवा निर्देश स्थिति';

  @override
  String get activeWithdrawalPeriod => 'निकासी अवधि सक्रिय';

  @override
  String get completedSafeToConsume => 'पूर्ण - उपभोग के लिए सुरक्षित';

  @override
  String get animalInformation => 'जानवर जानकारी';

  @override
  String get prescriptionDetails => 'दवा निर्देश विवरण';

  @override
  String get prescribedBy => 'निर्देशक';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get qrCertificateGenerator => 'QR प्रमाणपत्र जनरेटर';

  @override
  String get generateQrCodesForAnimalCertificates =>
      'जानवर प्रमाणपत्रों के लिए QR कोड जनरेट करें';

  @override
  String get qrGenerationDate => 'QR जनरेशन तिथि';

  @override
  String get noAnimalsAvailable => 'कोई जानवर उपलब्ध नहीं';

  @override
  String get addAnimalsToGenerateQrCertificates =>
      'QR प्रमाणपत्र जनरेट करने के लिए जानवर जोड़ें';

  @override
  String get generateQrCertificate => 'QR प्रमाणपत्र जनरेट करें';

  @override
  String get qrCertificateGenerated => 'QR प्रमाणपत्र जनरेट किया गया';

  @override
  String get animalInWithdrawalNotSafeToConsume =>
      'जानवर निकासी में है - उपभोग के लिए सुरक्षित नहीं';

  @override
  String get doNotConsumeProducts => 'इस जानवर के उत्पादों का उपभोग न करें';

  @override
  String get certificateDetails => 'प्रमाणपत्र विवरण';

  @override
  String get validUntil => 'मान्य तक';

  @override
  String get withdrawalEnds => 'निकासी समाप्त';

  @override
  String get share => 'साझा करें';

  @override
  String get farmAnalytics => 'खेत विश्लेषण';

  @override
  String get animalHealthAnalytics => 'जानवर स्वास्थ्य विश्लेषण';

  @override
  String get withdrawalPeriodAnalytics => 'निकासी अवधि विश्लेषण';

  @override
  String get mrlComplianceAnalytics => 'एमआरएल अनुपालन विश्लेषण';

  @override
  String get farmAlerts => 'खेत अलर्ट';

  @override
  String get withdrawalAlerts => 'निकासी अलर्ट';

  @override
  String get healthAlerts => 'स्वास्थ्य अलर्ट';

  @override
  String get complianceAlerts => 'अनुपालन अलर्ट';

  @override
  String get blockchainVerification => 'ब्लॉकचेन सत्यापन';

  @override
  String get animalRecordsOnBlockchain => 'ब्लॉकचेन पर जानवर रिकॉर्ड';

  @override
  String get verifyAnimalData => 'जानवर डेटा सत्यापित करें';

  @override
  String get blockchainTransactions => 'ब्लॉकचेन लेनदेन';

  @override
  String get aiVetAssistant => 'AI पशु चिकित्सक सहायक';

  @override
  String get aiTreatmentRecommendations => 'AI उपचार सिफारिशें';

  @override
  String get getAiRecommendations => 'AI सिफारिशें प्राप्त करें';

  @override
  String get aiHealthAnalysis => 'AI स्वास्थ्य विश्लेषण';

  @override
  String get shareWithVet => 'पशु चिकित्सक के साथ साझा करें';

  @override
  String get digitalCertificate => 'डिजिटल प्रमाणपत्र';

  @override
  String get withdrawalPeriodActive => 'निकासी अवधि सक्रिय';

  @override
  String get withdrawalPeriodCompleted => 'निकासी अवधि पूर्ण';

  @override
  String get endsOn => 'समाप्त होता है';

  @override
  String get certificateReadyForSharing =>
      'साझा करने के लिए QR प्रमाणपत्र तैयार';

  @override
  String get animalIdentification => 'जानवर पहचान';

  @override
  String get enterUniqueAnimalId => 'अद्वितीय जानवर आईडी दर्ज करें';

  @override
  String get generateId => 'आईडी जनरेट करें';

  @override
  String get pleaseEnterAnimalId => 'कृपया जानवर आईडी दर्ज करें';

  @override
  String get pleaseSelectSpecies => 'कृपया प्रजाति चुनें';

  @override
  String get breedAgeDetails => 'नस्ल और आयु विवरण';

  @override
  String get pleaseEnterAge => 'कृपया आयु दर्ज करें';

  @override
  String get enterValidAge => 'मान्य आयु दर्ज करें (0-50)';

  @override
  String get enterCustomBreed => 'कस्टम नस्ल दर्ज करें';

  @override
  String get enterBreedName => 'नस्ल का नाम दर्ज करें';

  @override
  String get pleaseSelectBreed => 'कृपया नस्ल चुनें';

  @override
  String get pleaseEnterBreed => 'कृपया नस्ल दर्ज करें';

  @override
  String get otherCustom => 'अन्य (कस्टम)';

  @override
  String get selectSpeciesFirst => 'पहले प्रजाति चुनें';

  @override
  String get saving => 'सहेजा जा रहा है...';

  @override
  String get animalAddedSuccessfully => 'जानवर सफलतापूर्वक जोड़ा गया!';

  @override
  String get failedToSaveAnimal =>
      'जानवर सहेजने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get allTypes => 'सभी प्रकार';

  @override
  String get withdrawalWarning => 'निकासी चेतावनी';

  @override
  String get withdrawalExpired => 'निकासी समाप्त';

  @override
  String get mrlViolation => 'एमआरएल उल्लंघन';

  @override
  String get treatmentOverdue => 'उपचार अतिदेय';

  @override
  String get complianceRisk => 'अनुपालन जोखिम';

  @override
  String get allSeverities => 'सभी गंभीरताएं';

  @override
  String get totalAlerts => 'कुल अलर्ट';

  @override
  String get unread => 'अपठित';

  @override
  String get critical => 'गंभीर';

  @override
  String get noAlertsFound => 'कोई अलर्ट नहीं मिला';

  @override
  String get allComplianceChecksPassing => 'सभी अनुपालन जांच पास हो रही हैं';

  @override
  String get createCustomAlert => 'कस्टम अलर्ट बनाएं';

  @override
  String get alertTitle => 'अलर्ट शीर्षक';

  @override
  String get alertMessage => 'अलर्ट संदेश';

  @override
  String get severity => 'गंभीरता';

  @override
  String get alertType => 'अलर्ट प्रकार';

  @override
  String get createAlert => 'अलर्ट बनाएं';

  @override
  String get read => 'पढ़ें';

  @override
  String get markAsRead => 'पढ़ा हुआ मार्क करें';

  @override
  String get dismiss => 'खारिज करें';

  @override
  String get justNow => 'अभी अभी';

  @override
  String minutesAgo(Object count) {
    return '$count मिनट पहले';
  }

  @override
  String hoursAgo(Object count) {
    return '$count घंटे पहले';
  }

  @override
  String daysAgo(Object count) {
    return '$count दिन पहले';
  }

  @override
  String get low => 'कम';

  @override
  String get medium => 'मध्यम';

  @override
  String get high => 'उच्च';

  @override
  String animalIdLabel(Object id) {
    return 'जानवर आईडी: $id';
  }

  @override
  String get cow => 'गाय';

  @override
  String get buffalo => 'भैंस';

  @override
  String get goat => 'बकरी';

  @override
  String get sheep => 'भेड़';

  @override
  String get pig => 'सूअर';

  @override
  String get poultry => 'कुखुरा';

  @override
  String get other => 'अन्य';

  @override
  String get jersey => 'जर्सी';

  @override
  String get holstein => 'होलस्टीन';

  @override
  String get sahiwal => 'सहिवाल';

  @override
  String get gir => 'गिर';

  @override
  String get redSindhi => 'लाल सिंधी';

  @override
  String get tharparkar => 'थारपारकर';

  @override
  String get murrah => 'मुर्रा';

  @override
  String get niliRavi => 'नीली रावी';

  @override
  String get jaffarabadi => 'जाफराबादी';

  @override
  String get surti => 'सुरती';

  @override
  String get bhadawari => 'भदावरी';

  @override
  String get beetal => 'बीटल';

  @override
  String get boer => 'बोअर';

  @override
  String get jamunapari => 'जामुनापरी';

  @override
  String get sirohi => 'सिरोही';

  @override
  String get barbari => 'बारबरी';

  @override
  String get merino => 'मेरिनो';

  @override
  String get rambouillet => 'रैम्बौलिए';

  @override
  String get cheviot => 'शेवियट';

  @override
  String get suffolk => 'सफ़ोक';

  @override
  String get hampshire => 'हैंपशायर';

  @override
  String get largeWhite => 'लार्ज व्हाइट';

  @override
  String get yorkshire => 'यॉर्कशायर';

  @override
  String get berkshire => 'बर्कशायर';

  @override
  String get desi => 'देशी';

  @override
  String get layer => 'लेयर';

  @override
  String get broiler => 'ब्रॉयलर';

  @override
  String get amuAnalyticsDashboard => 'एएमयू एनालिटिक्स डैशबोर्ड';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं';

  @override
  String analysisPeriod(Object end, Object start) {
    return 'विश्लेषण अवधि: $start से $end';
  }

  @override
  String get summaryStatistics => 'सारांश आंकड़े';

  @override
  String get totalAnimals => 'कुल जानवर';

  @override
  String get animalsTreated => 'उपचारित जानवर';

  @override
  String get treatmentRate => 'उपचार दर';

  @override
  String get complianceIssues => 'अनुपालन मुद्दे';

  @override
  String get trendAnalysis => 'प्रवृत्ति विश्लेषण';

  @override
  String get trendDirection => 'प्रवृत्ति दिशा';

  @override
  String get volatility => 'अस्थिरता';

  @override
  String get seasonalPatterns => 'मौसमी पैटर्न';

  @override
  String get noSeasonalPatternsDetected => 'कोई मौसमी पैटर्न नहीं पाया गया';

  @override
  String peakMonths(Object months) {
    return 'पीक महीने: $months';
  }

  @override
  String lowMonths(Object months) {
    return 'कम महीने: $months';
  }

  @override
  String get complianceAnalysis => 'अनुपालन विश्लेषण';

  @override
  String get complianceRate => 'अनुपालन दर';

  @override
  String get compliantAnimals => 'अनुपालित जानवर';

  @override
  String get riskFactors => 'जोखिम कारक';

  @override
  String get noSignificantRiskFactors =>
      'कोई महत्वपूर्ण जोखिम कारक नहीं पहचाना गया';

  @override
  String get noMedicineUsageData => 'कोई दवा उपयोग डेटा उपलब्ध नहीं';

  @override
  String get medicineUsageDistribution => 'दवा उपयोग वितरण';

  @override
  String get noRecommendationsAvailable => 'कोई सिफारिशें उपलब्ध नहीं';

  @override
  String get recommendations => 'सिफारिशें';

  @override
  String failedToLoadAnalytics(Object error) {
    return 'एनालिटिक्स लोड करने में विफल: $error';
  }

  @override
  String get addAnimalsFirstAi =>
      'AI सिफारिशें प्राप्त करने के लिए पहले कुछ जानवर जोड़ें';

  @override
  String failedToGetAiRecommendations(Object error) {
    return 'AI सिफारिशें प्राप्त करने में विफल: $error';
  }

  @override
  String get noSpecificRecommendations => 'इस समय कोई विशिष्ट सिफारिशें नहीं';

  @override
  String get healthScore => 'स्वास्थ्य स्कोर';

  @override
  String get aiRecommendations => 'AI सिफारिशें';

  @override
  String get preventiveCare => 'निवारक देखभाल';

  @override
  String failedToAnalyzeHealth(Object error) {
    return 'स्वास्थ्य विश्लेषण करने में विफल: $error';
  }

  @override
  String get loggingOut => 'लॉग आउट हो रहा है...';

  @override
  String get aiTreatmentRecommendationsDesc => 'AI उपचार सिफारिशें';

  @override
  String ageAddedToDatabase(Object age) {
    return 'आयु: $age • डेटाबेस में जोड़ा गया';
  }

  @override
  String get searchAnimals => 'जानवर खोजें';

  @override
  String get withdrawalStatus => 'निकासी';

  @override
  String get safeStatus => 'सुरक्षित';

  @override
  String get inWithdrawalStatus => 'निकासी में';

  @override
  String get viewButton => 'देखें';

  @override
  String get aiButton => 'AI';

  @override
  String get deleteButton => 'हटाएं';

  @override
  String get deletedMessage => 'हटाया गया';

  @override
  String prescriptionForSpecies(Object species) {
    return 'प्रिस्क्रिप्शन $species के लिए';
  }

  @override
  String get activeStatus => 'सक्रिय';

  @override
  String get completedStatus => 'पूर्ण';

  @override
  String get medicineLabel => 'दवा';

  @override
  String get dosageLabel => 'खुराक';

  @override
  String get withdrawalPeriodLabel => 'निकासी अवधि';

  @override
  String get endsLabel => 'समाप्त होता है';

  @override
  String prescribedByLabel(Object vet) {
    return 'निर्देशक: $vet';
  }

  @override
  String get viewDetailsButton => 'विवरण देखें';

  @override
  String get digitalPrescriptionTitle => 'डिजिटल प्रिस्क्रिप्शन';

  @override
  String get prescriptionStatusLabel => 'प्रिस्क्रिप्शन स्थिति';

  @override
  String get activeWithdrawalPeriodStatus => 'सक्रिय - निकासी अवधि';

  @override
  String get completedSafeToConsumeStatus => 'पूर्ण - उपभोग के लिए सुरक्षित';

  @override
  String get animalInformationSection => 'जानवर जानकारी';

  @override
  String get prescriptionDetailsSection => 'प्रिस्क्रिप्शन विवरण';

  @override
  String speciesAndBreedLabel(Object breed, Object species) {
    return 'प्रजाति और नस्ल: $species - $breed';
  }

  @override
  String get productTypeLabel => 'उत्पाद प्रकार';

  @override
  String prescribedDateLabel(Object date) {
    return 'निर्दिष्ट तिथि: $date';
  }

  @override
  String withdrawalEndsLabel(Object date) {
    return 'निकासी समाप्त: $date';
  }

  @override
  String get mrlStatusSection => 'एमआरएल स्थिति';

  @override
  String currentMrlLabel(Object mrl) {
    return 'वर्तमान एमआरएल: $mrl इकाइयाँ';
  }

  @override
  String statusLabel(Object status) {
    return 'स्थिति: $status';
  }

  @override
  String get veterinaryInformationSection => 'पशु चिकित्सा जानकारी';

  @override
  String consultingVetLabel(Object vet) {
    return 'परामर्शी पशु चिकित्सक: $vet';
  }

  @override
  String vetIdLabel(Object id) {
    return 'पशु चिकित्सक आईडी: $id';
  }

  @override
  String get noVetAssignedMessage => 'कोई पशु चिकित्सक नियुक्त नहीं';

  @override
  String get viewMrlGraphButton => 'एमआरएल ग्राफ देखें';

  @override
  String get noAnimalsAvailableMessage => 'कोई जानवर उपलब्ध नहीं';

  @override
  String get addAnimalsToGenerateQrMessage =>
      'QR प्रमाणपत्र जनरेट करने के लिए जानवर जोड़ें';

  @override
  String get qrCertificateGeneratorTitle => 'QR प्रमाणपत्र जनरेटर';

  @override
  String get generateQrCodesDesc =>
      'जानवर प्रमाणपत्रों के लिए QR कोड जनरेट करें';

  @override
  String qrGenerationDateLabel(Object date) {
    return 'QR जनरेशन तिथि: $date';
  }

  @override
  String speciesBreedDisplay(Object breed, Object species) {
    return '$species - $breed';
  }

  @override
  String idDisplay(Object id) {
    return 'आईडी: $id';
  }

  @override
  String get withdrawalPeriodActiveMessage => 'निकासी अवधि सक्रिय';

  @override
  String get withdrawalPeriodCompletedMessage => 'निकासी अवधि पूर्ण';

  @override
  String endsDateDisplay(Object date) {
    return 'समाप्त: $date';
  }

  @override
  String get generateQrCertificateButton => 'QR प्रमाणपत्र जनरेट करें';

  @override
  String get generatingQrCertificateMessage =>
      'QR प्रमाणपत्र जनरेट हो रहा है...';

  @override
  String get qrCertificateGeneratedTitle => 'QR प्रमाणपत्र जनरेट किया गया';

  @override
  String get animalInWithdrawalWarning =>
      '⚠️ जानवर निकासी में है - उपभोग के लिए सुरक्षित नहीं';

  @override
  String get safeToConsumeMessage => '✅ उपभोग के लिए सुरक्षित';

  @override
  String get doNotConsumeWarning => 'इस जानवर के उत्पादों का उपभोग न करें';

  @override
  String get certificateDetailsSection => 'प्रमाणपत्र विवरण';

  @override
  String get speciesLabel => 'प्रजाति';

  @override
  String farmerIdLabel(Object id) {
    return 'किसान आईडी: $id';
  }

  @override
  String generatedDateLabel(Object date) {
    return 'जनरेट तिथि: $date';
  }

  @override
  String validUntilLabel(Object date) {
    return 'मान्य तक: $date';
  }

  @override
  String get qrCertificateReadyMessage =>
      'साझा करने के लिए QR प्रमाणपत्र तैयार';

  @override
  String get errorTitle => 'त्रुटि';

  @override
  String failedToGenerateQrMessage(Object error) {
    return 'QR प्रमाणपत्र जनरेट करने में विफल: $error';
  }

  @override
  String get doNotConsumeProductsWarning =>
      'Do not consume products from this animal until withdrawal period ends.';
}

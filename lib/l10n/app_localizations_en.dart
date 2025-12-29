// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ABC (Antibiotic Check)';

  @override
  String get appSubtitle => 'Antibiotic Check for Farmers';

  @override
  String get farmer => 'Farmer';

  @override
  String get vet => 'Vet';

  @override
  String get seller => 'Seller';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get newToApp => 'New to app? Register';

  @override
  String get tapMicSayPassphrase => 'Tap mic & say your passphrase';

  @override
  String voiceRegistered(Object id) {
    return 'Voice registered — ID: $id';
  }

  @override
  String get listening => 'Farmer — Listening...';

  @override
  String get loginWithMobile => 'Login with Mobile (OTP)';

  @override
  String get enterMobileNumber => 'Enter mobile number';

  @override
  String get sendOTP => 'Send OTP';

  @override
  String get verifyLogin => 'Verify & Login';

  @override
  String get resendOTP => 'Resend OTP';

  @override
  String get enterOTP => 'Enter 6-digit OTP';

  @override
  String otpSentTo(Object number) {
    return 'OTP sent to $number';
  }

  @override
  String get incorrectOTP => 'Incorrect OTP';

  @override
  String get enterValidMobile => 'Enter valid mobile';

  @override
  String mockOTP(Object otp) {
    return 'Mock OTP: $otp';
  }

  @override
  String mockOTPFarmer(Object otp) {
    return 'Mock OTP (farmer): $otp';
  }

  @override
  String mockOTPSeller(Object otp) {
    return 'Mock OTP (seller): $otp';
  }

  @override
  String get veterinaryLogin => 'Veterinary Login';

  @override
  String get pleaseEnterLoginDetails => 'Please enter your login details';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get vetIdRegNo => 'Vet ID / Reg No';

  @override
  String get loginAsVet => 'Login as Vet';

  @override
  String get newToAppRegisterVet => 'New to app? Register as Vet';

  @override
  String get verifying => 'Verifying...';

  @override
  String get invalidVetCredentials => 'Invalid vet credentials';

  @override
  String get sellerUser => 'Seller / User';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get verifyOTP => 'Verify OTP';

  @override
  String get otpSent => 'OTP sent';

  @override
  String get registerAsFarmer => 'Register as Farmer';

  @override
  String get welcomeRegister =>
      'Welcome! Register to use ABC — choose voice or mobile registration';

  @override
  String get voiceRegistration => 'Voice Registration';

  @override
  String get voiceRegDesc =>
      'Register voice profile (simulated enroll). Create a simple Farmer ID you can share with vets.';

  @override
  String get mobileRegistration => 'Mobile Registration';

  @override
  String get mobileRegDesc =>
      'Register using your phone number (OTP). You can keep your phone as Farmer ID or choose a custom ID.';

  @override
  String get voiceEnrollment => 'Voice Enrollment (simulated)';

  @override
  String get tapEnrollStart =>
      'Tap ENROLL to start voice capture. You will be asked to say a short phrase three times.';

  @override
  String get recordingVoice =>
      'Recording your voice — hold still and speak the phrase when prompted.';

  @override
  String get enrollmentComplete => 'Enrollment complete — your Farmer ID is:';

  @override
  String get enrollVoice => 'Enroll Voice';

  @override
  String get cancel => 'Cancel';

  @override
  String get processingEnrollment => 'Processing enrollment...';

  @override
  String get continueToDashboard => 'Continue to Dashboard';

  @override
  String get retryEnrollment => 'Retry Enrollment';

  @override
  String get registerByMobile => 'Register by Mobile';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get addCustomId => 'Add custom ID?';

  @override
  String get customFarmerId => 'Custom Farmer ID (alphanumeric)';

  @override
  String get ifNotCustom =>
      'If you do not provide a custom ID, your phone number will be used as your Farmer ID.';

  @override
  String get enterValidPhone => 'Enter valid phone';

  @override
  String get idAlreadyInUse => 'Custom ID already in use';

  @override
  String registeredFarmerId(Object id) {
    return 'Registered — Farmer ID: $id';
  }

  @override
  String registrationError(Object error) {
    return 'Registration error: $error';
  }

  @override
  String get registerVet => 'Register Vet';

  @override
  String get registerAsVetDoctor => 'Register as Veterinary Doctor';

  @override
  String get useProfessionalCredentials =>
      'Use professional credentials to register (username + password + vet id).';

  @override
  String get registerWithCredentials => 'Register with credentials';

  @override
  String get createUsernamePasswordVetId =>
      'Create username + password + vet ID';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get enterpriseOnboarding =>
      'If you need enterprise onboarding let us know';

  @override
  String get contactSupportPlaceholder => 'Contact support (placeholder)';

  @override
  String get veterinaryRegistration => 'Veterinary Registration';

  @override
  String get fillAllFields => 'Fill all fields';

  @override
  String get vetRegistered => 'Vet registered — use credentials to login';

  @override
  String get farmerDashboard => 'Farmer Dashboard';

  @override
  String get logout => 'Logout';

  @override
  String animalsCount(Object count, Object withdrawal) {
    return 'Animals: $count • In withdrawal: $withdrawal';
  }

  @override
  String get animalDatabase => 'Animal Database';

  @override
  String get manageAnimalDatabase => 'Manage animal database';

  @override
  String get addAnimal => 'Add Animal';

  @override
  String get addNewAnimal => 'Add new animal';

  @override
  String get guides => 'Guides';

  @override
  String get withdrawalDosingGuides => 'Withdrawal & dosing guides';

  @override
  String get guidesPlaceholder => 'Guides (placeholder)';

  @override
  String get contactVet => 'Contact Vet';

  @override
  String get shareFarmerIdWithVet => 'Share Farmer ID with vet';

  @override
  String shareId(Object id) {
    return 'Share ID: $id';
  }

  @override
  String get animalId => 'Animal ID';

  @override
  String get enterId => 'Enter id';

  @override
  String get generate => 'Gen';

  @override
  String get species => 'Species';

  @override
  String get selectSpecies => 'Select Species';

  @override
  String get age => 'Age (yrs)';

  @override
  String get enterAge => 'Enter age';

  @override
  String get breed => 'Breed';

  @override
  String get chooseBreed => 'Choose breed';

  @override
  String get enterBreed => 'Enter breed';

  @override
  String get saveAnimal => 'Save Animal';

  @override
  String get animalSaved => 'Animal saved';

  @override
  String get animalDatabaseTitle => 'Animal Database';

  @override
  String get searchByIdSpeciesBreed => 'Search by id, species or breed';

  @override
  String get all => 'All';

  @override
  String get noAnimalsYet => 'No animals yet';

  @override
  String get tapAddCreateAnimals => 'Tap add to create animals';

  @override
  String get animalDetails => 'Animal Details';

  @override
  String get close => 'Close';

  @override
  String get id => 'ID';

  @override
  String get lastMedicine => 'Last Medicine';

  @override
  String get withdrawalEnd => 'Withdrawal End';

  @override
  String get deleteAnimal => 'Delete Animal';

  @override
  String get deleted => 'Deleted';

  @override
  String get vetConsulting => 'Vet Consulting';

  @override
  String get enterFarmerIdOrPhone => 'Farmer ID or phone';

  @override
  String get load => 'Load';

  @override
  String loadedAnimals(Object count) {
    return 'Loaded animals — $count total (demo)';
  }

  @override
  String get enterFarmerId => 'Enter farmer id or phone';

  @override
  String get noAnimalsInDatabase => 'No animals in database.';

  @override
  String get consult => 'Consult';

  @override
  String consultAnimal(Object id) {
    return 'Consult • $id';
  }

  @override
  String get medicine => 'Medicine';

  @override
  String get dosage => 'Dosage (mg/kg)';

  @override
  String get withdrawalPeriod => 'Withdrawal Period (days)';

  @override
  String get notes => 'Notes (optional)';

  @override
  String get saveConsultation => 'Save Consultation';

  @override
  String get savedToAnimalRecord => 'Saved consultation to animal record';

  @override
  String get enterMedicine => 'Enter medicine';

  @override
  String get consultingHistory => 'Consulting History';

  @override
  String get noConsultationHistory =>
      'Consultation history placeholder (persist when you need).';

  @override
  String get sellerDashboard => 'Seller Dashboard';

  @override
  String get foodScanner => 'Food Scanner';

  @override
  String get scanFoodQR => 'Scan food/QR';

  @override
  String get animalScanner => 'Animal Scanner';

  @override
  String get scanAnimalTag => 'Scan animal tag';

  @override
  String get foodScannerPlaceholder => 'Food scanner placeholder';

  @override
  String get animalScannerPlaceholder => 'Animal scanner placeholder';

  @override
  String get camera => 'Camera';

  @override
  String imageCaptured(Object path) {
    return 'Image captured: $path';
  }

  @override
  String get cameraNotAvailable => 'Camera not available';

  @override
  String errorCapturingImage(Object error) {
    return 'Error capturing image: $error';
  }

  @override
  String get safe => 'Safe';

  @override
  String get inWithdrawal => 'In Withdrawal';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get farmerId => 'Farmer ID';

  @override
  String get guest => 'Guest';

  @override
  String get home => 'Home';

  @override
  String get animals => 'Animals';

  @override
  String get history => 'History';

  @override
  String get noHistoryYet => 'No consultation history yet.';

  @override
  String lastMedicineDosage(Object dosage, Object end, Object medicine) {
    return 'Last Medicine: $medicine • $dosage mg/kg\nWithdrawal End: $end';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get chooseYourLanguage => 'Choose Your Language';

  @override
  String get continueButton => 'Continue';

  @override
  String get enterUsernamePasswordVetId => 'Enter username/password/vet id';

  @override
  String get productType => 'Product Type';

  @override
  String get mrlInformation => 'MRL Information';

  @override
  String get currentMRL => 'Current MRL';

  @override
  String get status => 'Status';

  @override
  String get withdrawalDays => 'Withdrawal Days';

  @override
  String get allStatus => 'All Status';

  @override
  String get withdrawal => 'Withdrawal';

  @override
  String ageWithValue(Object age) {
    return 'Age • $age';
  }

  @override
  String get view => 'View';

  @override
  String get delete => 'Delete';

  @override
  String get addedToDatabase => 'Added to database';

  @override
  String get withdrawalGuides => 'Withdrawal Guides';

  @override
  String get noAnimalsInWithdrawalPeriod => 'No animals in withdrawal period';

  @override
  String get allAnimalsSafeForConsumption =>
      'All your animals are safe for consumption';

  @override
  String get withdrawalDetails => 'Withdrawal Details';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get medicineAndWithdrawal => 'Medicine & Withdrawal';

  @override
  String get consultingVet => 'Consulting Vet';

  @override
  String get noVetAssigned => 'No vet assigned';

  @override
  String get viewMrlGraph => 'View MRL Graph';

  @override
  String get started => 'Started';

  @override
  String get ends => 'Ends';

  @override
  String get prescriptions => 'Prescriptions';

  @override
  String get qrCodes => 'QR Codes';

  @override
  String get analytics => 'Analytics';

  @override
  String get alerts => 'Alerts';

  @override
  String get blockchain => 'Blockchain';

  @override
  String get noDigitalPrescriptions => 'No Digital Prescriptions';

  @override
  String get prescriptionsWillAppearHere =>
      'Prescriptions will appear here after veterinary consultations';

  @override
  String get prescriptionFor => 'Prescription for';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Completed';

  @override
  String get digitalPrescription => 'Digital Prescription';

  @override
  String get prescriptionStatus => 'Prescription Status';

  @override
  String get activeWithdrawalPeriod => 'Active - Withdrawal Period';

  @override
  String get completedSafeToConsume => 'Completed - Safe to Consume';

  @override
  String get animalInformation => 'Animal Information';

  @override
  String get prescriptionDetails => 'Prescription Details';

  @override
  String get prescribedBy => 'Prescribed by';

  @override
  String get viewDetails => 'View Details';

  @override
  String get qrCertificateGenerator => 'QR Certificate Generator';

  @override
  String get generateQrCodesForAnimalCertificates =>
      'Generate QR codes for animal certificates with safety status';

  @override
  String get qrGenerationDate => 'QR Generation Date';

  @override
  String get noAnimalsAvailable => 'No Animals Available';

  @override
  String get addAnimalsToGenerateQrCertificates =>
      'Add animals to generate QR certificates';

  @override
  String get generateQrCertificate => 'Generate QR Certificate';

  @override
  String get qrCertificateGenerated => 'QR Certificate Generated';

  @override
  String get animalInWithdrawalNotSafeToConsume =>
      'ANIMAL IN WITHDRAWAL - NOT SAFE TO CONSUME';

  @override
  String get doNotConsumeProducts =>
      'Do not consume products from this animal until withdrawal period ends.';

  @override
  String get certificateDetails => 'Certificate Details';

  @override
  String get validUntil => 'Valid Until';

  @override
  String get withdrawalEnds => 'Withdrawal Ends';

  @override
  String get share => 'Share';

  @override
  String get farmAnalytics => 'Farm Analytics';

  @override
  String get animalHealthAnalytics => 'Animal Health Analytics';

  @override
  String get withdrawalPeriodAnalytics => 'Withdrawal Period Analytics';

  @override
  String get mrlComplianceAnalytics => 'MRL Compliance Analytics';

  @override
  String get farmAlerts => 'Farm Alerts';

  @override
  String get withdrawalAlerts => 'Withdrawal Alerts';

  @override
  String get healthAlerts => 'Health Alerts';

  @override
  String get complianceAlerts => 'Compliance Alerts';

  @override
  String get blockchainVerification => 'Blockchain Verification';

  @override
  String get animalRecordsOnBlockchain => 'Animal Records on Blockchain';

  @override
  String get verifyAnimalData => 'Verify Animal Data';

  @override
  String get blockchainTransactions => 'Blockchain Transactions';

  @override
  String get aiVetAssistant => 'AI Vet Assistant';

  @override
  String get aiTreatmentRecommendations => 'AI Treatment Recommendations';

  @override
  String get getAiRecommendations => 'Get AI Recommendations';

  @override
  String get aiHealthAnalysis => 'AI Health Analysis';

  @override
  String get shareWithVet => 'Share with Vet';

  @override
  String get digitalCertificate => 'Digital Certificate';

  @override
  String get withdrawalPeriodActive => 'Withdrawal Period Active';

  @override
  String get withdrawalPeriodCompleted => 'Withdrawal Period Completed';

  @override
  String get endsOn => 'Ends';

  @override
  String get certificateReadyForSharing => 'QR Certificate ready for sharing';

  @override
  String get animalIdentification => 'Animal Identification';

  @override
  String get enterUniqueAnimalId => 'Enter unique animal ID';

  @override
  String get generateId => 'Generate ID';

  @override
  String get pleaseEnterAnimalId => 'Please enter an animal ID';

  @override
  String get pleaseSelectSpecies => 'Please select a species';

  @override
  String get breedAgeDetails => 'Breed & Age Details';

  @override
  String get pleaseEnterAge => 'Please enter age';

  @override
  String get enterValidAge => 'Enter valid age (0-50)';

  @override
  String get enterCustomBreed => 'Enter Custom Breed';

  @override
  String get enterBreedName => 'Enter breed name';

  @override
  String get pleaseSelectBreed => 'Please select a breed';

  @override
  String get pleaseEnterBreed => 'Please enter breed';

  @override
  String get otherCustom => 'Other (Custom)';

  @override
  String get selectSpeciesFirst => 'Select species first';

  @override
  String get saving => 'Saving...';

  @override
  String get animalAddedSuccessfully => 'Animal added successfully!';

  @override
  String get failedToSaveAnimal => 'Failed to save animal. Please try again.';

  @override
  String get allTypes => 'All Types';

  @override
  String get withdrawalWarning => 'Withdrawal Warning';

  @override
  String get withdrawalExpired => 'Withdrawal Expired';

  @override
  String get mrlViolation => 'MRL Violation';

  @override
  String get treatmentOverdue => 'Treatment Overdue';

  @override
  String get complianceRisk => 'Compliance Risk';

  @override
  String get allSeverities => 'All Severities';

  @override
  String get totalAlerts => 'Total Alerts';

  @override
  String get unread => 'Unread';

  @override
  String get critical => 'Critical';

  @override
  String get noAlertsFound => 'No alerts found';

  @override
  String get allComplianceChecksPassing => 'All compliance checks are passing';

  @override
  String get createCustomAlert => 'Create Custom Alert';

  @override
  String get alertTitle => 'Alert Title';

  @override
  String get alertMessage => 'Alert Message';

  @override
  String get severity => 'Severity';

  @override
  String get alertType => 'Alert Type';

  @override
  String get createAlert => 'Create Alert';

  @override
  String get read => 'Read';

  @override
  String get markAsRead => 'Mark as Read';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String animalIdLabel(Object id) {
    return 'Animal ID: $id';
  }

  @override
  String get cow => 'Cow';

  @override
  String get buffalo => 'Buffalo';

  @override
  String get goat => 'Goat';

  @override
  String get sheep => 'Sheep';

  @override
  String get pig => 'Pig';

  @override
  String get poultry => 'Poultry';

  @override
  String get other => 'Other';

  @override
  String get jersey => 'Jersey';

  @override
  String get holstein => 'Holstein';

  @override
  String get sahiwal => 'Sahiwal';

  @override
  String get gir => 'Gir';

  @override
  String get redSindhi => 'Red Sindhi';

  @override
  String get tharparkar => 'Tharparkar';

  @override
  String get murrah => 'Murrah';

  @override
  String get niliRavi => 'Nili-Ravi';

  @override
  String get jaffarabadi => 'Jaffarabadi';

  @override
  String get surti => 'Surti';

  @override
  String get bhadawari => 'Bhadawari';

  @override
  String get beetal => 'Beetal';

  @override
  String get boer => 'Boer';

  @override
  String get jamunapari => 'Jamunapari';

  @override
  String get sirohi => 'Sirohi';

  @override
  String get barbari => 'Barbari';

  @override
  String get merino => 'Merino';

  @override
  String get rambouillet => 'Rambouillet';

  @override
  String get cheviot => 'Cheviot';

  @override
  String get suffolk => 'Suffolk';

  @override
  String get hampshire => 'Hampshire';

  @override
  String get largeWhite => 'Large White';

  @override
  String get yorkshire => 'Yorkshire';

  @override
  String get berkshire => 'Berkshire';

  @override
  String get desi => 'Desi';

  @override
  String get layer => 'Layer';

  @override
  String get broiler => 'Broiler';

  @override
  String get amuAnalyticsDashboard => 'AMU Analytics Dashboard';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String analysisPeriod(Object end, Object start) {
    return 'Analysis Period: $start to $end';
  }

  @override
  String get summaryStatistics => 'Summary Statistics';

  @override
  String get totalAnimals => 'Total Animals';

  @override
  String get animalsTreated => 'Animals Treated';

  @override
  String get treatmentRate => 'Treatment Rate';

  @override
  String get complianceIssues => 'Compliance Issues';

  @override
  String get trendAnalysis => 'Trend Analysis';

  @override
  String get trendDirection => 'Trend Direction';

  @override
  String get volatility => 'Volatility';

  @override
  String get seasonalPatterns => 'Seasonal Patterns';

  @override
  String get noSeasonalPatternsDetected => 'No seasonal patterns detected';

  @override
  String peakMonths(Object months) {
    return 'Peak months: $months';
  }

  @override
  String lowMonths(Object months) {
    return 'Low months: $months';
  }

  @override
  String get complianceAnalysis => 'Compliance Analysis';

  @override
  String get complianceRate => 'Compliance Rate';

  @override
  String get compliantAnimals => 'Compliant Animals';

  @override
  String get riskFactors => 'Risk Factors';

  @override
  String get noSignificantRiskFactors =>
      'No significant risk factors identified';

  @override
  String get noMedicineUsageData => 'No medicine usage data available';

  @override
  String get medicineUsageDistribution => 'Medicine Usage Distribution';

  @override
  String get noRecommendationsAvailable => 'No recommendations available';

  @override
  String get recommendations => 'Recommendations';

  @override
  String failedToLoadAnalytics(Object error) {
    return 'Failed to load analytics: $error';
  }

  @override
  String get addAnimalsFirstAi =>
      'Add some animals first to get AI recommendations';

  @override
  String failedToGetAiRecommendations(Object error) {
    return 'Failed to get AI recommendations: $error';
  }

  @override
  String get noSpecificRecommendations =>
      'No specific recommendations at this time';

  @override
  String get healthScore => 'Health Score';

  @override
  String get aiRecommendations => 'AI Recommendations';

  @override
  String get preventiveCare => 'Preventive Care';

  @override
  String failedToAnalyzeHealth(Object error) {
    return 'Failed to analyze health: $error';
  }

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get aiTreatmentRecommendationsDesc => 'AI treatment recommendations';

  @override
  String ageAddedToDatabase(Object age) {
    return 'Age: $age • Added to database';
  }

  @override
  String get searchAnimals => 'Search animals';

  @override
  String get withdrawalStatus => 'Withdrawal';

  @override
  String get safeStatus => 'Safe';

  @override
  String get inWithdrawalStatus => 'In Withdrawal';

  @override
  String get viewButton => 'View';

  @override
  String get aiButton => 'AI';

  @override
  String get deleteButton => 'Delete';

  @override
  String get deletedMessage => 'Deleted';

  @override
  String prescriptionForSpecies(Object species) {
    return 'Prescription for $species';
  }

  @override
  String get activeStatus => 'Active';

  @override
  String get completedStatus => 'Completed';

  @override
  String get medicineLabel => 'Medicine';

  @override
  String get dosageLabel => 'Dosage';

  @override
  String get withdrawalPeriodLabel => 'Withdrawal Period';

  @override
  String get endsLabel => 'Ends';

  @override
  String prescribedByLabel(Object vet) {
    return 'Prescribed by: $vet';
  }

  @override
  String get viewDetailsButton => 'View Details';

  @override
  String get digitalPrescriptionTitle => 'Digital Prescription';

  @override
  String get prescriptionStatusLabel => 'Prescription Status';

  @override
  String get activeWithdrawalPeriodStatus => 'Active - Withdrawal Period';

  @override
  String get completedSafeToConsumeStatus => 'Completed - Safe to Consume';

  @override
  String get animalInformationSection => 'Animal Information';

  @override
  String get prescriptionDetailsSection => 'Prescription Details';

  @override
  String speciesAndBreedLabel(Object breed, Object species) {
    return 'Species & Breed: $species - $breed';
  }

  @override
  String get productTypeLabel => 'Product Type';

  @override
  String prescribedDateLabel(Object date) {
    return 'Prescribed Date: $date';
  }

  @override
  String withdrawalEndsLabel(Object date) {
    return 'Withdrawal Ends: $date';
  }

  @override
  String get mrlStatusSection => 'MRL Status';

  @override
  String currentMrlLabel(Object mrl) {
    return 'Current MRL: $mrl units';
  }

  @override
  String statusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get veterinaryInformationSection => 'Veterinary Information';

  @override
  String consultingVetLabel(Object vet) {
    return 'Consulting Vet: $vet';
  }

  @override
  String vetIdLabel(Object id) {
    return 'Vet ID: $id';
  }

  @override
  String get noVetAssignedMessage => 'No vet assigned';

  @override
  String get viewMrlGraphButton => 'View MRL Graph';

  @override
  String get noAnimalsAvailableMessage => 'No Animals Available';

  @override
  String get addAnimalsToGenerateQrMessage =>
      'Add animals to generate QR certificates';

  @override
  String get qrCertificateGeneratorTitle => 'QR Certificate Generator';

  @override
  String get generateQrCodesDesc =>
      'Generate QR codes for animal certificates with safety status';

  @override
  String qrGenerationDateLabel(Object date) {
    return 'QR Generation Date: $date';
  }

  @override
  String speciesBreedDisplay(Object breed, Object species) {
    return '$species - $breed';
  }

  @override
  String idDisplay(Object id) {
    return 'ID: $id';
  }

  @override
  String get withdrawalPeriodActiveMessage => 'Withdrawal Period Active';

  @override
  String get withdrawalPeriodCompletedMessage => 'Withdrawal Period Completed';

  @override
  String endsDateDisplay(Object date) {
    return 'Ends: $date';
  }

  @override
  String get generateQrCertificateButton => 'Generate QR Certificate';

  @override
  String get generatingQrCertificateMessage => 'Generating QR Certificate...';

  @override
  String get qrCertificateGeneratedTitle => 'QR Certificate Generated';

  @override
  String get animalInWithdrawalWarning =>
      '⚠️ ANIMAL IN WITHDRAWAL - NOT SAFE TO CONSUME';

  @override
  String get safeToConsumeMessage => '✅ SAFE TO CONSUME';

  @override
  String get doNotConsumeWarning =>
      'Do not consume products from this animal until withdrawal period ends.';

  @override
  String get certificateDetailsSection => 'Certificate Details';

  @override
  String get speciesLabel => 'Species';

  @override
  String farmerIdLabel(Object id) {
    return 'Farmer ID: $id';
  }

  @override
  String generatedDateLabel(Object date) {
    return 'Generated Date: $date';
  }

  @override
  String validUntilLabel(Object date) {
    return 'Valid Until: $date';
  }

  @override
  String get qrCertificateReadyMessage => 'QR Certificate ready for sharing';

  @override
  String get errorTitle => 'Error';

  @override
  String failedToGenerateQrMessage(Object error) {
    return 'Failed to generate QR certificate: $error';
  }

  @override
  String get doNotConsumeProductsWarning =>
      'Do not consume products from this animal until withdrawal period ends.';
}

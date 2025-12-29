import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ta')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ABC (Antibiotic Check)'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Antibiotic Check for Farmers'**
  String get appSubtitle;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @vet.
  ///
  /// In en, this message translates to:
  /// **'Vet'**
  String get vet;

  /// No description provided for @seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get seller;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @newToApp.
  ///
  /// In en, this message translates to:
  /// **'New to app? Register'**
  String get newToApp;

  /// No description provided for @tapMicSayPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Tap mic & say your passphrase'**
  String get tapMicSayPassphrase;

  /// No description provided for @voiceRegistered.
  ///
  /// In en, this message translates to:
  /// **'Voice registered — ID: {id}'**
  String voiceRegistered(Object id);

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Farmer — Listening...'**
  String get listening;

  /// No description provided for @loginWithMobile.
  ///
  /// In en, this message translates to:
  /// **'Login with Mobile (OTP)'**
  String get loginWithMobile;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobileNumber;

  /// No description provided for @sendOTP.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOTP;

  /// No description provided for @verifyLogin.
  ///
  /// In en, this message translates to:
  /// **'Verify & Login'**
  String get verifyLogin;

  /// No description provided for @resendOTP.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOTP;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOTP;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {number}'**
  String otpSentTo(Object number);

  /// No description provided for @incorrectOTP.
  ///
  /// In en, this message translates to:
  /// **'Incorrect OTP'**
  String get incorrectOTP;

  /// No description provided for @enterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter valid mobile'**
  String get enterValidMobile;

  /// No description provided for @mockOTP.
  ///
  /// In en, this message translates to:
  /// **'Mock OTP: {otp}'**
  String mockOTP(Object otp);

  /// No description provided for @mockOTPFarmer.
  ///
  /// In en, this message translates to:
  /// **'Mock OTP (farmer): {otp}'**
  String mockOTPFarmer(Object otp);

  /// No description provided for @mockOTPSeller.
  ///
  /// In en, this message translates to:
  /// **'Mock OTP (seller): {otp}'**
  String mockOTPSeller(Object otp);

  /// No description provided for @veterinaryLogin.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Login'**
  String get veterinaryLogin;

  /// No description provided for @pleaseEnterLoginDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter your login details'**
  String get pleaseEnterLoginDetails;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @vetIdRegNo.
  ///
  /// In en, this message translates to:
  /// **'Vet ID / Reg No'**
  String get vetIdRegNo;

  /// No description provided for @loginAsVet.
  ///
  /// In en, this message translates to:
  /// **'Login as Vet'**
  String get loginAsVet;

  /// No description provided for @newToAppRegisterVet.
  ///
  /// In en, this message translates to:
  /// **'New to app? Register as Vet'**
  String get newToAppRegisterVet;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @invalidVetCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid vet credentials'**
  String get invalidVetCredentials;

  /// No description provided for @sellerUser.
  ///
  /// In en, this message translates to:
  /// **'Seller / User'**
  String get sellerUser;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOTP;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent'**
  String get otpSent;

  /// No description provided for @registerAsFarmer.
  ///
  /// In en, this message translates to:
  /// **'Register as Farmer'**
  String get registerAsFarmer;

  /// No description provided for @welcomeRegister.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Register to use ABC — choose voice or mobile registration'**
  String get welcomeRegister;

  /// No description provided for @voiceRegistration.
  ///
  /// In en, this message translates to:
  /// **'Voice Registration'**
  String get voiceRegistration;

  /// No description provided for @voiceRegDesc.
  ///
  /// In en, this message translates to:
  /// **'Register voice profile (simulated enroll). Create a simple Farmer ID you can share with vets.'**
  String get voiceRegDesc;

  /// No description provided for @mobileRegistration.
  ///
  /// In en, this message translates to:
  /// **'Mobile Registration'**
  String get mobileRegistration;

  /// No description provided for @mobileRegDesc.
  ///
  /// In en, this message translates to:
  /// **'Register using your phone number (OTP). You can keep your phone as Farmer ID or choose a custom ID.'**
  String get mobileRegDesc;

  /// No description provided for @voiceEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Voice Enrollment (simulated)'**
  String get voiceEnrollment;

  /// No description provided for @tapEnrollStart.
  ///
  /// In en, this message translates to:
  /// **'Tap ENROLL to start voice capture. You will be asked to say a short phrase three times.'**
  String get tapEnrollStart;

  /// No description provided for @recordingVoice.
  ///
  /// In en, this message translates to:
  /// **'Recording your voice — hold still and speak the phrase when prompted.'**
  String get recordingVoice;

  /// No description provided for @enrollmentComplete.
  ///
  /// In en, this message translates to:
  /// **'Enrollment complete — your Farmer ID is:'**
  String get enrollmentComplete;

  /// No description provided for @enrollVoice.
  ///
  /// In en, this message translates to:
  /// **'Enroll Voice'**
  String get enrollVoice;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @processingEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Processing enrollment...'**
  String get processingEnrollment;

  /// No description provided for @continueToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Continue to Dashboard'**
  String get continueToDashboard;

  /// No description provided for @retryEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Retry Enrollment'**
  String get retryEnrollment;

  /// No description provided for @registerByMobile.
  ///
  /// In en, this message translates to:
  /// **'Register by Mobile'**
  String get registerByMobile;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @addCustomId.
  ///
  /// In en, this message translates to:
  /// **'Add custom ID?'**
  String get addCustomId;

  /// No description provided for @customFarmerId.
  ///
  /// In en, this message translates to:
  /// **'Custom Farmer ID (alphanumeric)'**
  String get customFarmerId;

  /// No description provided for @ifNotCustom.
  ///
  /// In en, this message translates to:
  /// **'If you do not provide a custom ID, your phone number will be used as your Farmer ID.'**
  String get ifNotCustom;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter valid phone'**
  String get enterValidPhone;

  /// No description provided for @idAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Custom ID already in use'**
  String get idAlreadyInUse;

  /// No description provided for @registeredFarmerId.
  ///
  /// In en, this message translates to:
  /// **'Registered — Farmer ID: {id}'**
  String registeredFarmerId(Object id);

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error: {error}'**
  String registrationError(Object error);

  /// No description provided for @registerVet.
  ///
  /// In en, this message translates to:
  /// **'Register Vet'**
  String get registerVet;

  /// No description provided for @registerAsVetDoctor.
  ///
  /// In en, this message translates to:
  /// **'Register as Veterinary Doctor'**
  String get registerAsVetDoctor;

  /// No description provided for @useProfessionalCredentials.
  ///
  /// In en, this message translates to:
  /// **'Use professional credentials to register (username + password + vet id).'**
  String get useProfessionalCredentials;

  /// No description provided for @registerWithCredentials.
  ///
  /// In en, this message translates to:
  /// **'Register with credentials'**
  String get registerWithCredentials;

  /// No description provided for @createUsernamePasswordVetId.
  ///
  /// In en, this message translates to:
  /// **'Create username + password + vet ID'**
  String get createUsernamePasswordVetId;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @enterpriseOnboarding.
  ///
  /// In en, this message translates to:
  /// **'If you need enterprise onboarding let us know'**
  String get enterpriseOnboarding;

  /// No description provided for @contactSupportPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Contact support (placeholder)'**
  String get contactSupportPlaceholder;

  /// No description provided for @veterinaryRegistration.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Registration'**
  String get veterinaryRegistration;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Fill all fields'**
  String get fillAllFields;

  /// No description provided for @vetRegistered.
  ///
  /// In en, this message translates to:
  /// **'Vet registered — use credentials to login'**
  String get vetRegistered;

  /// No description provided for @farmerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Farmer Dashboard'**
  String get farmerDashboard;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @animalsCount.
  ///
  /// In en, this message translates to:
  /// **'Animals: {count} • In withdrawal: {withdrawal}'**
  String animalsCount(Object count, Object withdrawal);

  /// No description provided for @animalDatabase.
  ///
  /// In en, this message translates to:
  /// **'Animal Database'**
  String get animalDatabase;

  /// No description provided for @manageAnimalDatabase.
  ///
  /// In en, this message translates to:
  /// **'Manage animal database'**
  String get manageAnimalDatabase;

  /// No description provided for @addAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add Animal'**
  String get addAnimal;

  /// No description provided for @addNewAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add new animal'**
  String get addNewAnimal;

  /// No description provided for @guides.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get guides;

  /// No description provided for @withdrawalDosingGuides.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal & dosing guides'**
  String get withdrawalDosingGuides;

  /// No description provided for @guidesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Guides (placeholder)'**
  String get guidesPlaceholder;

  /// No description provided for @contactVet.
  ///
  /// In en, this message translates to:
  /// **'Contact Vet'**
  String get contactVet;

  /// No description provided for @shareFarmerIdWithVet.
  ///
  /// In en, this message translates to:
  /// **'Share Farmer ID with vet'**
  String get shareFarmerIdWithVet;

  /// No description provided for @shareId.
  ///
  /// In en, this message translates to:
  /// **'Share ID: {id}'**
  String shareId(Object id);

  /// No description provided for @animalId.
  ///
  /// In en, this message translates to:
  /// **'Animal ID'**
  String get animalId;

  /// No description provided for @enterId.
  ///
  /// In en, this message translates to:
  /// **'Enter id'**
  String get enterId;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Gen'**
  String get generate;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @selectSpecies.
  ///
  /// In en, this message translates to:
  /// **'Select Species'**
  String get selectSpecies;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age (yrs)'**
  String get age;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enterAge;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @chooseBreed.
  ///
  /// In en, this message translates to:
  /// **'Choose breed'**
  String get chooseBreed;

  /// No description provided for @enterBreed.
  ///
  /// In en, this message translates to:
  /// **'Enter breed'**
  String get enterBreed;

  /// No description provided for @saveAnimal.
  ///
  /// In en, this message translates to:
  /// **'Save Animal'**
  String get saveAnimal;

  /// No description provided for @animalSaved.
  ///
  /// In en, this message translates to:
  /// **'Animal saved'**
  String get animalSaved;

  /// No description provided for @animalDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal Database'**
  String get animalDatabaseTitle;

  /// No description provided for @searchByIdSpeciesBreed.
  ///
  /// In en, this message translates to:
  /// **'Search by id, species or breed'**
  String get searchByIdSpeciesBreed;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noAnimalsYet.
  ///
  /// In en, this message translates to:
  /// **'No animals yet'**
  String get noAnimalsYet;

  /// No description provided for @tapAddCreateAnimals.
  ///
  /// In en, this message translates to:
  /// **'Tap add to create animals'**
  String get tapAddCreateAnimals;

  /// No description provided for @animalDetails.
  ///
  /// In en, this message translates to:
  /// **'Animal Details'**
  String get animalDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @lastMedicine.
  ///
  /// In en, this message translates to:
  /// **'Last Medicine'**
  String get lastMedicine;

  /// No description provided for @withdrawalEnd.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal End'**
  String get withdrawalEnd;

  /// No description provided for @deleteAnimal.
  ///
  /// In en, this message translates to:
  /// **'Delete Animal'**
  String get deleteAnimal;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @vetConsulting.
  ///
  /// In en, this message translates to:
  /// **'Vet Consulting'**
  String get vetConsulting;

  /// No description provided for @enterFarmerIdOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Farmer ID or phone'**
  String get enterFarmerIdOrPhone;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// No description provided for @loadedAnimals.
  ///
  /// In en, this message translates to:
  /// **'Loaded animals — {count} total (demo)'**
  String loadedAnimals(Object count);

  /// No description provided for @enterFarmerId.
  ///
  /// In en, this message translates to:
  /// **'Enter farmer id or phone'**
  String get enterFarmerId;

  /// No description provided for @noAnimalsInDatabase.
  ///
  /// In en, this message translates to:
  /// **'No animals in database.'**
  String get noAnimalsInDatabase;

  /// No description provided for @consult.
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get consult;

  /// No description provided for @consultAnimal.
  ///
  /// In en, this message translates to:
  /// **'Consult • {id}'**
  String consultAnimal(Object id);

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage (mg/kg)'**
  String get dosage;

  /// No description provided for @withdrawalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Period (days)'**
  String get withdrawalPeriod;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes;

  /// No description provided for @saveConsultation.
  ///
  /// In en, this message translates to:
  /// **'Save Consultation'**
  String get saveConsultation;

  /// No description provided for @savedToAnimalRecord.
  ///
  /// In en, this message translates to:
  /// **'Saved consultation to animal record'**
  String get savedToAnimalRecord;

  /// No description provided for @enterMedicine.
  ///
  /// In en, this message translates to:
  /// **'Enter medicine'**
  String get enterMedicine;

  /// No description provided for @consultingHistory.
  ///
  /// In en, this message translates to:
  /// **'Consulting History'**
  String get consultingHistory;

  /// No description provided for @noConsultationHistory.
  ///
  /// In en, this message translates to:
  /// **'Consultation history placeholder (persist when you need).'**
  String get noConsultationHistory;

  /// No description provided for @sellerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Seller Dashboard'**
  String get sellerDashboard;

  /// No description provided for @foodScanner.
  ///
  /// In en, this message translates to:
  /// **'Food Scanner'**
  String get foodScanner;

  /// No description provided for @scanFoodQR.
  ///
  /// In en, this message translates to:
  /// **'Scan food/QR'**
  String get scanFoodQR;

  /// No description provided for @animalScanner.
  ///
  /// In en, this message translates to:
  /// **'Animal Scanner'**
  String get animalScanner;

  /// No description provided for @scanAnimalTag.
  ///
  /// In en, this message translates to:
  /// **'Scan animal tag'**
  String get scanAnimalTag;

  /// No description provided for @foodScannerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Food scanner placeholder'**
  String get foodScannerPlaceholder;

  /// No description provided for @animalScannerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Animal scanner placeholder'**
  String get animalScannerPlaceholder;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @imageCaptured.
  ///
  /// In en, this message translates to:
  /// **'Image captured: {path}'**
  String imageCaptured(Object path);

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera not available'**
  String get cameraNotAvailable;

  /// No description provided for @errorCapturingImage.
  ///
  /// In en, this message translates to:
  /// **'Error capturing image: {error}'**
  String errorCapturingImage(Object error);

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// No description provided for @inWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'In Withdrawal'**
  String get inWithdrawal;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @farmerId.
  ///
  /// In en, this message translates to:
  /// **'Farmer ID'**
  String get farmerId;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No consultation history yet.'**
  String get noHistoryYet;

  /// No description provided for @lastMedicineDosage.
  ///
  /// In en, this message translates to:
  /// **'Last Medicine: {medicine} • {dosage} mg/kg\nWithdrawal End: {end}'**
  String lastMedicineDosage(Object dosage, Object end, Object medicine);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get chooseYourLanguage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @enterUsernamePasswordVetId.
  ///
  /// In en, this message translates to:
  /// **'Enter username/password/vet id'**
  String get enterUsernamePasswordVetId;

  /// No description provided for @productType.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get productType;

  /// No description provided for @mrlInformation.
  ///
  /// In en, this message translates to:
  /// **'MRL Information'**
  String get mrlInformation;

  /// No description provided for @currentMRL.
  ///
  /// In en, this message translates to:
  /// **'Current MRL'**
  String get currentMRL;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @withdrawalDays.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Days'**
  String get withdrawalDays;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get allStatus;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawal;

  /// No description provided for @ageWithValue.
  ///
  /// In en, this message translates to:
  /// **'Age • {age}'**
  String ageWithValue(Object age);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addedToDatabase.
  ///
  /// In en, this message translates to:
  /// **'Added to database'**
  String get addedToDatabase;

  /// No description provided for @withdrawalGuides.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Guides'**
  String get withdrawalGuides;

  /// No description provided for @noAnimalsInWithdrawalPeriod.
  ///
  /// In en, this message translates to:
  /// **'No animals in withdrawal period'**
  String get noAnimalsInWithdrawalPeriod;

  /// No description provided for @allAnimalsSafeForConsumption.
  ///
  /// In en, this message translates to:
  /// **'All your animals are safe for consumption'**
  String get allAnimalsSafeForConsumption;

  /// No description provided for @withdrawalDetails.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Details'**
  String get withdrawalDetails;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @medicineAndWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Medicine & Withdrawal'**
  String get medicineAndWithdrawal;

  /// No description provided for @consultingVet.
  ///
  /// In en, this message translates to:
  /// **'Consulting Vet'**
  String get consultingVet;

  /// No description provided for @noVetAssigned.
  ///
  /// In en, this message translates to:
  /// **'No vet assigned'**
  String get noVetAssigned;

  /// No description provided for @viewMrlGraph.
  ///
  /// In en, this message translates to:
  /// **'View MRL Graph'**
  String get viewMrlGraph;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @qrCodes.
  ///
  /// In en, this message translates to:
  /// **'QR Codes'**
  String get qrCodes;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @blockchain.
  ///
  /// In en, this message translates to:
  /// **'Blockchain'**
  String get blockchain;

  /// No description provided for @noDigitalPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'No Digital Prescriptions'**
  String get noDigitalPrescriptions;

  /// No description provided for @prescriptionsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions will appear here after veterinary consultations'**
  String get prescriptionsWillAppearHere;

  /// No description provided for @prescriptionFor.
  ///
  /// In en, this message translates to:
  /// **'Prescription for'**
  String get prescriptionFor;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @digitalPrescription.
  ///
  /// In en, this message translates to:
  /// **'Digital Prescription'**
  String get digitalPrescription;

  /// No description provided for @prescriptionStatus.
  ///
  /// In en, this message translates to:
  /// **'Prescription Status'**
  String get prescriptionStatus;

  /// No description provided for @activeWithdrawalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Active - Withdrawal Period'**
  String get activeWithdrawalPeriod;

  /// No description provided for @completedSafeToConsume.
  ///
  /// In en, this message translates to:
  /// **'Completed - Safe to Consume'**
  String get completedSafeToConsume;

  /// No description provided for @animalInformation.
  ///
  /// In en, this message translates to:
  /// **'Animal Information'**
  String get animalInformation;

  /// No description provided for @prescriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Prescription Details'**
  String get prescriptionDetails;

  /// No description provided for @prescribedBy.
  ///
  /// In en, this message translates to:
  /// **'Prescribed by'**
  String get prescribedBy;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @qrCertificateGenerator.
  ///
  /// In en, this message translates to:
  /// **'QR Certificate Generator'**
  String get qrCertificateGenerator;

  /// No description provided for @generateQrCodesForAnimalCertificates.
  ///
  /// In en, this message translates to:
  /// **'Generate QR codes for animal certificates with safety status'**
  String get generateQrCodesForAnimalCertificates;

  /// No description provided for @qrGenerationDate.
  ///
  /// In en, this message translates to:
  /// **'QR Generation Date'**
  String get qrGenerationDate;

  /// No description provided for @noAnimalsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Animals Available'**
  String get noAnimalsAvailable;

  /// No description provided for @addAnimalsToGenerateQrCertificates.
  ///
  /// In en, this message translates to:
  /// **'Add animals to generate QR certificates'**
  String get addAnimalsToGenerateQrCertificates;

  /// No description provided for @generateQrCertificate.
  ///
  /// In en, this message translates to:
  /// **'Generate QR Certificate'**
  String get generateQrCertificate;

  /// No description provided for @qrCertificateGenerated.
  ///
  /// In en, this message translates to:
  /// **'QR Certificate Generated'**
  String get qrCertificateGenerated;

  /// No description provided for @animalInWithdrawalNotSafeToConsume.
  ///
  /// In en, this message translates to:
  /// **'ANIMAL IN WITHDRAWAL - NOT SAFE TO CONSUME'**
  String get animalInWithdrawalNotSafeToConsume;

  /// No description provided for @doNotConsumeProducts.
  ///
  /// In en, this message translates to:
  /// **'Do not consume products from this animal until withdrawal period ends.'**
  String get doNotConsumeProducts;

  /// No description provided for @certificateDetails.
  ///
  /// In en, this message translates to:
  /// **'Certificate Details'**
  String get certificateDetails;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get validUntil;

  /// No description provided for @withdrawalEnds.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Ends'**
  String get withdrawalEnds;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @farmAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Farm Analytics'**
  String get farmAnalytics;

  /// No description provided for @animalHealthAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Animal Health Analytics'**
  String get animalHealthAnalytics;

  /// No description provided for @withdrawalPeriodAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Period Analytics'**
  String get withdrawalPeriodAnalytics;

  /// No description provided for @mrlComplianceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'MRL Compliance Analytics'**
  String get mrlComplianceAnalytics;

  /// No description provided for @farmAlerts.
  ///
  /// In en, this message translates to:
  /// **'Farm Alerts'**
  String get farmAlerts;

  /// No description provided for @withdrawalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Alerts'**
  String get withdrawalAlerts;

  /// No description provided for @healthAlerts.
  ///
  /// In en, this message translates to:
  /// **'Health Alerts'**
  String get healthAlerts;

  /// No description provided for @complianceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Compliance Alerts'**
  String get complianceAlerts;

  /// No description provided for @blockchainVerification.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Verification'**
  String get blockchainVerification;

  /// No description provided for @animalRecordsOnBlockchain.
  ///
  /// In en, this message translates to:
  /// **'Animal Records on Blockchain'**
  String get animalRecordsOnBlockchain;

  /// No description provided for @verifyAnimalData.
  ///
  /// In en, this message translates to:
  /// **'Verify Animal Data'**
  String get verifyAnimalData;

  /// No description provided for @blockchainTransactions.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Transactions'**
  String get blockchainTransactions;

  /// No description provided for @aiVetAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Vet Assistant'**
  String get aiVetAssistant;

  /// No description provided for @aiTreatmentRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Treatment Recommendations'**
  String get aiTreatmentRecommendations;

  /// No description provided for @getAiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Get AI Recommendations'**
  String get getAiRecommendations;

  /// No description provided for @aiHealthAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Health Analysis'**
  String get aiHealthAnalysis;

  /// No description provided for @shareWithVet.
  ///
  /// In en, this message translates to:
  /// **'Share with Vet'**
  String get shareWithVet;

  /// No description provided for @digitalCertificate.
  ///
  /// In en, this message translates to:
  /// **'Digital Certificate'**
  String get digitalCertificate;

  /// No description provided for @withdrawalPeriodActive.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Period Active'**
  String get withdrawalPeriodActive;

  /// No description provided for @withdrawalPeriodCompleted.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Period Completed'**
  String get withdrawalPeriodCompleted;

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsOn;

  /// No description provided for @certificateReadyForSharing.
  ///
  /// In en, this message translates to:
  /// **'QR Certificate ready for sharing'**
  String get certificateReadyForSharing;

  /// No description provided for @animalIdentification.
  ///
  /// In en, this message translates to:
  /// **'Animal Identification'**
  String get animalIdentification;

  /// No description provided for @enterUniqueAnimalId.
  ///
  /// In en, this message translates to:
  /// **'Enter unique animal ID'**
  String get enterUniqueAnimalId;

  /// No description provided for @generateId.
  ///
  /// In en, this message translates to:
  /// **'Generate ID'**
  String get generateId;

  /// No description provided for @pleaseEnterAnimalId.
  ///
  /// In en, this message translates to:
  /// **'Please enter an animal ID'**
  String get pleaseEnterAnimalId;

  /// No description provided for @pleaseSelectSpecies.
  ///
  /// In en, this message translates to:
  /// **'Please select a species'**
  String get pleaseSelectSpecies;

  /// No description provided for @breedAgeDetails.
  ///
  /// In en, this message translates to:
  /// **'Breed & Age Details'**
  String get breedAgeDetails;

  /// No description provided for @pleaseEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get pleaseEnterAge;

  /// No description provided for @enterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter valid age (0-50)'**
  String get enterValidAge;

  /// No description provided for @enterCustomBreed.
  ///
  /// In en, this message translates to:
  /// **'Enter Custom Breed'**
  String get enterCustomBreed;

  /// No description provided for @enterBreedName.
  ///
  /// In en, this message translates to:
  /// **'Enter breed name'**
  String get enterBreedName;

  /// No description provided for @pleaseSelectBreed.
  ///
  /// In en, this message translates to:
  /// **'Please select a breed'**
  String get pleaseSelectBreed;

  /// No description provided for @pleaseEnterBreed.
  ///
  /// In en, this message translates to:
  /// **'Please enter breed'**
  String get pleaseEnterBreed;

  /// No description provided for @otherCustom.
  ///
  /// In en, this message translates to:
  /// **'Other (Custom)'**
  String get otherCustom;

  /// No description provided for @selectSpeciesFirst.
  ///
  /// In en, this message translates to:
  /// **'Select species first'**
  String get selectSpeciesFirst;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @animalAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Animal added successfully!'**
  String get animalAddedSuccessfully;

  /// No description provided for @failedToSaveAnimal.
  ///
  /// In en, this message translates to:
  /// **'Failed to save animal. Please try again.'**
  String get failedToSaveAnimal;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @withdrawalWarning.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Warning'**
  String get withdrawalWarning;

  /// No description provided for @withdrawalExpired.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Expired'**
  String get withdrawalExpired;

  /// No description provided for @mrlViolation.
  ///
  /// In en, this message translates to:
  /// **'MRL Violation'**
  String get mrlViolation;

  /// No description provided for @treatmentOverdue.
  ///
  /// In en, this message translates to:
  /// **'Treatment Overdue'**
  String get treatmentOverdue;

  /// No description provided for @complianceRisk.
  ///
  /// In en, this message translates to:
  /// **'Compliance Risk'**
  String get complianceRisk;

  /// No description provided for @allSeverities.
  ///
  /// In en, this message translates to:
  /// **'All Severities'**
  String get allSeverities;

  /// No description provided for @totalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Total Alerts'**
  String get totalAlerts;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @noAlertsFound.
  ///
  /// In en, this message translates to:
  /// **'No alerts found'**
  String get noAlertsFound;

  /// No description provided for @allComplianceChecksPassing.
  ///
  /// In en, this message translates to:
  /// **'All compliance checks are passing'**
  String get allComplianceChecksPassing;

  /// No description provided for @createCustomAlert.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Alert'**
  String get createCustomAlert;

  /// No description provided for @alertTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert Title'**
  String get alertTitle;

  /// No description provided for @alertMessage.
  ///
  /// In en, this message translates to:
  /// **'Alert Message'**
  String get alertMessage;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @alertType.
  ///
  /// In en, this message translates to:
  /// **'Alert Type'**
  String get alertType;

  /// No description provided for @createAlert.
  ///
  /// In en, this message translates to:
  /// **'Create Alert'**
  String get createAlert;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get markAsRead;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @animalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Animal ID: {id}'**
  String animalIdLabel(Object id);

  /// No description provided for @cow.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get cow;

  /// No description provided for @buffalo.
  ///
  /// In en, this message translates to:
  /// **'Buffalo'**
  String get buffalo;

  /// No description provided for @goat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get goat;

  /// No description provided for @sheep.
  ///
  /// In en, this message translates to:
  /// **'Sheep'**
  String get sheep;

  /// No description provided for @pig.
  ///
  /// In en, this message translates to:
  /// **'Pig'**
  String get pig;

  /// No description provided for @poultry.
  ///
  /// In en, this message translates to:
  /// **'Poultry'**
  String get poultry;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @jersey.
  ///
  /// In en, this message translates to:
  /// **'Jersey'**
  String get jersey;

  /// No description provided for @holstein.
  ///
  /// In en, this message translates to:
  /// **'Holstein'**
  String get holstein;

  /// No description provided for @sahiwal.
  ///
  /// In en, this message translates to:
  /// **'Sahiwal'**
  String get sahiwal;

  /// No description provided for @gir.
  ///
  /// In en, this message translates to:
  /// **'Gir'**
  String get gir;

  /// No description provided for @redSindhi.
  ///
  /// In en, this message translates to:
  /// **'Red Sindhi'**
  String get redSindhi;

  /// No description provided for @tharparkar.
  ///
  /// In en, this message translates to:
  /// **'Tharparkar'**
  String get tharparkar;

  /// No description provided for @murrah.
  ///
  /// In en, this message translates to:
  /// **'Murrah'**
  String get murrah;

  /// No description provided for @niliRavi.
  ///
  /// In en, this message translates to:
  /// **'Nili-Ravi'**
  String get niliRavi;

  /// No description provided for @jaffarabadi.
  ///
  /// In en, this message translates to:
  /// **'Jaffarabadi'**
  String get jaffarabadi;

  /// No description provided for @surti.
  ///
  /// In en, this message translates to:
  /// **'Surti'**
  String get surti;

  /// No description provided for @bhadawari.
  ///
  /// In en, this message translates to:
  /// **'Bhadawari'**
  String get bhadawari;

  /// No description provided for @beetal.
  ///
  /// In en, this message translates to:
  /// **'Beetal'**
  String get beetal;

  /// No description provided for @boer.
  ///
  /// In en, this message translates to:
  /// **'Boer'**
  String get boer;

  /// No description provided for @jamunapari.
  ///
  /// In en, this message translates to:
  /// **'Jamunapari'**
  String get jamunapari;

  /// No description provided for @sirohi.
  ///
  /// In en, this message translates to:
  /// **'Sirohi'**
  String get sirohi;

  /// No description provided for @barbari.
  ///
  /// In en, this message translates to:
  /// **'Barbari'**
  String get barbari;

  /// No description provided for @merino.
  ///
  /// In en, this message translates to:
  /// **'Merino'**
  String get merino;

  /// No description provided for @rambouillet.
  ///
  /// In en, this message translates to:
  /// **'Rambouillet'**
  String get rambouillet;

  /// No description provided for @cheviot.
  ///
  /// In en, this message translates to:
  /// **'Cheviot'**
  String get cheviot;

  /// No description provided for @suffolk.
  ///
  /// In en, this message translates to:
  /// **'Suffolk'**
  String get suffolk;

  /// No description provided for @hampshire.
  ///
  /// In en, this message translates to:
  /// **'Hampshire'**
  String get hampshire;

  /// No description provided for @largeWhite.
  ///
  /// In en, this message translates to:
  /// **'Large White'**
  String get largeWhite;

  /// No description provided for @yorkshire.
  ///
  /// In en, this message translates to:
  /// **'Yorkshire'**
  String get yorkshire;

  /// No description provided for @berkshire.
  ///
  /// In en, this message translates to:
  /// **'Berkshire'**
  String get berkshire;

  /// No description provided for @desi.
  ///
  /// In en, this message translates to:
  /// **'Desi'**
  String get desi;

  /// No description provided for @layer.
  ///
  /// In en, this message translates to:
  /// **'Layer'**
  String get layer;

  /// No description provided for @broiler.
  ///
  /// In en, this message translates to:
  /// **'Broiler'**
  String get broiler;

  /// No description provided for @amuAnalyticsDashboard.
  ///
  /// In en, this message translates to:
  /// **'AMU Analytics Dashboard'**
  String get amuAnalyticsDashboard;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @analysisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Analysis Period: {start} to {end}'**
  String analysisPeriod(Object end, Object start);

  /// No description provided for @summaryStatistics.
  ///
  /// In en, this message translates to:
  /// **'Summary Statistics'**
  String get summaryStatistics;

  /// No description provided for @totalAnimals.
  ///
  /// In en, this message translates to:
  /// **'Total Animals'**
  String get totalAnimals;

  /// No description provided for @animalsTreated.
  ///
  /// In en, this message translates to:
  /// **'Animals Treated'**
  String get animalsTreated;

  /// No description provided for @treatmentRate.
  ///
  /// In en, this message translates to:
  /// **'Treatment Rate'**
  String get treatmentRate;

  /// No description provided for @complianceIssues.
  ///
  /// In en, this message translates to:
  /// **'Compliance Issues'**
  String get complianceIssues;

  /// No description provided for @trendAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Trend Analysis'**
  String get trendAnalysis;

  /// No description provided for @trendDirection.
  ///
  /// In en, this message translates to:
  /// **'Trend Direction'**
  String get trendDirection;

  /// No description provided for @volatility.
  ///
  /// In en, this message translates to:
  /// **'Volatility'**
  String get volatility;

  /// No description provided for @seasonalPatterns.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Patterns'**
  String get seasonalPatterns;

  /// No description provided for @noSeasonalPatternsDetected.
  ///
  /// In en, this message translates to:
  /// **'No seasonal patterns detected'**
  String get noSeasonalPatternsDetected;

  /// No description provided for @peakMonths.
  ///
  /// In en, this message translates to:
  /// **'Peak months: {months}'**
  String peakMonths(Object months);

  /// No description provided for @lowMonths.
  ///
  /// In en, this message translates to:
  /// **'Low months: {months}'**
  String lowMonths(Object months);

  /// No description provided for @complianceAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Compliance Analysis'**
  String get complianceAnalysis;

  /// No description provided for @complianceRate.
  ///
  /// In en, this message translates to:
  /// **'Compliance Rate'**
  String get complianceRate;

  /// No description provided for @compliantAnimals.
  ///
  /// In en, this message translates to:
  /// **'Compliant Animals'**
  String get compliantAnimals;

  /// No description provided for @riskFactors.
  ///
  /// In en, this message translates to:
  /// **'Risk Factors'**
  String get riskFactors;

  /// No description provided for @noSignificantRiskFactors.
  ///
  /// In en, this message translates to:
  /// **'No significant risk factors identified'**
  String get noSignificantRiskFactors;

  /// No description provided for @noMedicineUsageData.
  ///
  /// In en, this message translates to:
  /// **'No medicine usage data available'**
  String get noMedicineUsageData;

  /// No description provided for @medicineUsageDistribution.
  ///
  /// In en, this message translates to:
  /// **'Medicine Usage Distribution'**
  String get medicineUsageDistribution;

  /// No description provided for @noRecommendationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recommendations available'**
  String get noRecommendationsAvailable;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @failedToLoadAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics: {error}'**
  String failedToLoadAnalytics(Object error);

  /// No description provided for @addAnimalsFirstAi.
  ///
  /// In en, this message translates to:
  /// **'Add some animals first to get AI recommendations'**
  String get addAnimalsFirstAi;

  /// No description provided for @failedToGetAiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Failed to get AI recommendations: {error}'**
  String failedToGetAiRecommendations(Object error);

  /// No description provided for @noSpecificRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No specific recommendations at this time'**
  String get noSpecificRecommendations;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthScore;

  /// No description provided for @aiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations'**
  String get aiRecommendations;

  /// No description provided for @preventiveCare.
  ///
  /// In en, this message translates to:
  /// **'Preventive Care'**
  String get preventiveCare;

  /// No description provided for @failedToAnalyzeHealth.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze health: {error}'**
  String failedToAnalyzeHealth(Object error);

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @aiTreatmentRecommendationsDesc.
  ///
  /// In en, this message translates to:
  /// **'AI treatment recommendations'**
  String get aiTreatmentRecommendationsDesc;

  /// No description provided for @ageAddedToDatabase.
  ///
  /// In en, this message translates to:
  /// **'Age: {age} • Added to database'**
  String ageAddedToDatabase(Object age);

  /// No description provided for @searchAnimals.
  ///
  /// In en, this message translates to:
  /// **'Search animals'**
  String get searchAnimals;

  /// No description provided for @withdrawalStatus.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawalStatus;

  /// No description provided for @safeStatus.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safeStatus;

  /// No description provided for @inWithdrawalStatus.
  ///
  /// In en, this message translates to:
  /// **'In Withdrawal'**
  String get inWithdrawalStatus;

  /// No description provided for @viewButton.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewButton;

  /// No description provided for @aiButton.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deletedMessage;

  /// No description provided for @prescriptionForSpecies.
  ///
  /// In en, this message translates to:
  /// **'Prescription for {species}'**
  String prescriptionForSpecies(Object species);

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @medicineLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicineLabel;

  /// No description provided for @dosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosageLabel;

  /// No description provided for @withdrawalPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Period'**
  String get withdrawalPeriodLabel;

  /// No description provided for @endsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsLabel;

  /// No description provided for @prescribedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Prescribed by: {vet}'**
  String prescribedByLabel(Object vet);

  /// No description provided for @viewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetailsButton;

  /// No description provided for @digitalPrescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Prescription'**
  String get digitalPrescriptionTitle;

  /// No description provided for @prescriptionStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Prescription Status'**
  String get prescriptionStatusLabel;

  /// No description provided for @activeWithdrawalPeriodStatus.
  ///
  /// In en, this message translates to:
  /// **'Active - Withdrawal Period'**
  String get activeWithdrawalPeriodStatus;

  /// No description provided for @completedSafeToConsumeStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed - Safe to Consume'**
  String get completedSafeToConsumeStatus;

  /// No description provided for @animalInformationSection.
  ///
  /// In en, this message translates to:
  /// **'Animal Information'**
  String get animalInformationSection;

  /// No description provided for @prescriptionDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Prescription Details'**
  String get prescriptionDetailsSection;

  /// No description provided for @speciesAndBreedLabel.
  ///
  /// In en, this message translates to:
  /// **'Species & Breed: {species} - {breed}'**
  String speciesAndBreedLabel(Object breed, Object species);

  /// No description provided for @productTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get productTypeLabel;

  /// No description provided for @prescribedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Prescribed Date: {date}'**
  String prescribedDateLabel(Object date);

  /// No description provided for @withdrawalEndsLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Ends: {date}'**
  String withdrawalEndsLabel(Object date);

  /// No description provided for @mrlStatusSection.
  ///
  /// In en, this message translates to:
  /// **'MRL Status'**
  String get mrlStatusSection;

  /// No description provided for @currentMrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Current MRL: {mrl} units'**
  String currentMrlLabel(Object mrl);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(Object status);

  /// No description provided for @veterinaryInformationSection.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Information'**
  String get veterinaryInformationSection;

  /// No description provided for @consultingVetLabel.
  ///
  /// In en, this message translates to:
  /// **'Consulting Vet: {vet}'**
  String consultingVetLabel(Object vet);

  /// No description provided for @vetIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Vet ID: {id}'**
  String vetIdLabel(Object id);

  /// No description provided for @noVetAssignedMessage.
  ///
  /// In en, this message translates to:
  /// **'No vet assigned'**
  String get noVetAssignedMessage;

  /// No description provided for @viewMrlGraphButton.
  ///
  /// In en, this message translates to:
  /// **'View MRL Graph'**
  String get viewMrlGraphButton;

  /// No description provided for @noAnimalsAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No Animals Available'**
  String get noAnimalsAvailableMessage;

  /// No description provided for @addAnimalsToGenerateQrMessage.
  ///
  /// In en, this message translates to:
  /// **'Add animals to generate QR certificates'**
  String get addAnimalsToGenerateQrMessage;

  /// No description provided for @qrCertificateGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Certificate Generator'**
  String get qrCertificateGeneratorTitle;

  /// No description provided for @generateQrCodesDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate QR codes for animal certificates with safety status'**
  String get generateQrCodesDesc;

  /// No description provided for @qrGenerationDateLabel.
  ///
  /// In en, this message translates to:
  /// **'QR Generation Date: {date}'**
  String qrGenerationDateLabel(Object date);

  /// No description provided for @speciesBreedDisplay.
  ///
  /// In en, this message translates to:
  /// **'{species} - {breed}'**
  String speciesBreedDisplay(Object breed, Object species);

  /// No description provided for @idDisplay.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idDisplay(Object id);

  /// No description provided for @withdrawalPeriodActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Period Active'**
  String get withdrawalPeriodActiveMessage;

  /// No description provided for @withdrawalPeriodCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Period Completed'**
  String get withdrawalPeriodCompletedMessage;

  /// No description provided for @endsDateDisplay.
  ///
  /// In en, this message translates to:
  /// **'Ends: {date}'**
  String endsDateDisplay(Object date);

  /// No description provided for @generateQrCertificateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate QR Certificate'**
  String get generateQrCertificateButton;

  /// No description provided for @generatingQrCertificateMessage.
  ///
  /// In en, this message translates to:
  /// **'Generating QR Certificate...'**
  String get generatingQrCertificateMessage;

  /// No description provided for @qrCertificateGeneratedTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Certificate Generated'**
  String get qrCertificateGeneratedTitle;

  /// No description provided for @animalInWithdrawalWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ ANIMAL IN WITHDRAWAL - NOT SAFE TO CONSUME'**
  String get animalInWithdrawalWarning;

  /// No description provided for @safeToConsumeMessage.
  ///
  /// In en, this message translates to:
  /// **'✅ SAFE TO CONSUME'**
  String get safeToConsumeMessage;

  /// No description provided for @doNotConsumeWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not consume products from this animal until withdrawal period ends.'**
  String get doNotConsumeWarning;

  /// No description provided for @certificateDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Certificate Details'**
  String get certificateDetailsSection;

  /// No description provided for @speciesLabel.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get speciesLabel;

  /// No description provided for @farmerIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Farmer ID: {id}'**
  String farmerIdLabel(Object id);

  /// No description provided for @generatedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Generated Date: {date}'**
  String generatedDateLabel(Object date);

  /// No description provided for @validUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid Until: {date}'**
  String validUntilLabel(Object date);

  /// No description provided for @qrCertificateReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'QR Certificate ready for sharing'**
  String get qrCertificateReadyMessage;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @failedToGenerateQrMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate QR certificate: {error}'**
  String failedToGenerateQrMessage(Object error);

  /// No description provided for @doNotConsumeProductsWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not consume products from this animal until withdrawal period ends.'**
  String get doNotConsumeProductsWarning;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

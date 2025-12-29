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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Digital Farm Biosecurity'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Biosecure Farms — local guard for pig & poultry'**
  String get tagline;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing local database...'**
  String get initializing;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'What is biosecurity?'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Biosecurity protects farms from diseases and threats through preventive measures.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'How the app helps'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Risk checks, training, alerts & offline records for better farm management.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Privacy & local storage'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Data kept on your device; export options available.'**
  String get onboarding3Desc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

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

  /// No description provided for @useDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get useDeviceLanguage;

  /// No description provided for @saveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveContinue;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @veterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get veterinarian;

  /// No description provided for @extensionWorker.
  ///
  /// In en, this message translates to:
  /// **'Extension Worker'**
  String get extensionWorker;

  /// No description provided for @authority.
  ///
  /// In en, this message translates to:
  /// **'Authority'**
  String get authority;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

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

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometrics'**
  String get enableBiometrics;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @startAssessment.
  ///
  /// In en, this message translates to:
  /// **'Start Risk Assessment'**
  String get startAssessment;

  /// No description provided for @recordIncident.
  ///
  /// In en, this message translates to:
  /// **'Record Incident'**
  String get recordIncident;

  /// No description provided for @trainingModules.
  ///
  /// In en, this message translates to:
  /// **'Training Modules'**
  String get trainingModules;

  /// No description provided for @recentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recent Alerts'**
  String get recentAlerts;

  /// No description provided for @lastAssessment.
  ///
  /// In en, this message translates to:
  /// **'Last Assessment'**
  String get lastAssessment;

  /// No description provided for @currentRisk.
  ///
  /// In en, this message translates to:
  /// **'Current Risk'**
  String get currentRisk;

  /// No description provided for @animalsCount.
  ///
  /// In en, this message translates to:
  /// **'Animals Count'**
  String get animalsCount;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get ownerName;

  /// No description provided for @villageTown.
  ///
  /// In en, this message translates to:
  /// **'Village/Town'**
  String get villageTown;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

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

  /// No description provided for @farmSize.
  ///
  /// In en, this message translates to:
  /// **'Farm Size'**
  String get farmSize;

  /// No description provided for @productionSystem.
  ///
  /// In en, this message translates to:
  /// **'Production System'**
  String get productionSystem;

  /// No description provided for @backyard.
  ///
  /// In en, this message translates to:
  /// **'Backyard'**
  String get backyard;

  /// No description provided for @commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get commercial;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get chooseYourLanguage;

  /// No description provided for @selectLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the language you prefer to use in the app'**
  String get selectLanguageDescription;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get enterMobileNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOtp;

  /// No description provided for @otpPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get otpPlaceholder;

  /// No description provided for @pinLogin.
  ///
  /// In en, this message translates to:
  /// **'PIN Login'**
  String get pinLogin;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-6 digit PIN'**
  String get enterPin;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @dataSecurityMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored locally and encrypted for maximum security.'**
  String get dataSecurityMessage;

  /// No description provided for @testCredentials.
  ///
  /// In en, this message translates to:
  /// **'Test Credentials'**
  String get testCredentials;

  /// No description provided for @testMobile.
  ///
  /// In en, this message translates to:
  /// **'Test Mobile'**
  String get testMobile;

  /// No description provided for @otpValue.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otpValue;

  /// No description provided for @registerWithMobile.
  ///
  /// In en, this message translates to:
  /// **'Register with mobile number for OTP login'**
  String get registerWithMobile;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login is successful'**
  String get loginSuccessful;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your mobile number'**
  String get otpSent;

  /// No description provided for @failedToSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get failedToSendOtp;

  /// No description provided for @pleaseEnterMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get pleaseEnterMobile;

  /// No description provided for @pleaseEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter 6-digit OTP'**
  String get pleaseEnterOtp;

  /// No description provided for @mobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get mobileRequired;

  /// No description provided for @validMobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get validMobileRequired;

  /// No description provided for @otpRequired.
  ///
  /// In en, this message translates to:
  /// **'OTP is required'**
  String get otpRequired;

  /// No description provided for @validOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter 6-digit OTP'**
  String get validOtpRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get pinRequired;

  /// No description provided for @pinMinLength.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits'**
  String get pinMinLength;

  /// No description provided for @roleFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get roleFarmer;

  /// No description provided for @roleVeterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get roleVeterinarian;

  /// No description provided for @roleExtensionWorker.
  ///
  /// In en, this message translates to:
  /// **'Extension Worker'**
  String get roleExtensionWorker;

  /// No description provided for @roleAuthority.
  ///
  /// In en, this message translates to:
  /// **'Authority'**
  String get roleAuthority;

  /// No description provided for @farmGuardian.
  ///
  /// In en, this message translates to:
  /// **'Farm Guardian'**
  String get farmGuardian;

  /// No description provided for @healthExpert.
  ///
  /// In en, this message translates to:
  /// **'Health Expert'**
  String get healthExpert;

  /// No description provided for @fieldSupport.
  ///
  /// In en, this message translates to:
  /// **'Field Support'**
  String get fieldSupport;

  /// No description provided for @regulatoryOversight.
  ///
  /// In en, this message translates to:
  /// **'Regulatory Oversight'**
  String get regulatoryOversight;

  /// No description provided for @protectFarm.
  ///
  /// In en, this message translates to:
  /// **'Protect your farm with comprehensive biosecurity measures and track compliance effortlessly.'**
  String get protectFarm;

  /// No description provided for @monitorHealth.
  ///
  /// In en, this message translates to:
  /// **'Monitor animal health, diagnose issues, and ensure optimal biosecurity standards.'**
  String get monitorHealth;

  /// No description provided for @provideGuidance.
  ///
  /// In en, this message translates to:
  /// **'Provide expert guidance, conduct training, and support farmers in their biosecurity journey.'**
  String get provideGuidance;

  /// No description provided for @overseeCompliance.
  ///
  /// In en, this message translates to:
  /// **'Oversee compliance, manage system settings, and ensure regional biosecurity standards.'**
  String get overseeCompliance;

  /// No description provided for @chooseYourRole.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get chooseYourRole;

  /// No description provided for @selectRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the role that best describes your responsibilities'**
  String get selectRoleDescription;

  /// No description provided for @manageFarmBiosecurity.
  ///
  /// In en, this message translates to:
  /// **'Manage farm biosecurity and records.'**
  String get manageFarmBiosecurity;

  /// No description provided for @provideVeterinaryServices.
  ///
  /// In en, this message translates to:
  /// **'Provide veterinary services and monitor health.'**
  String get provideVeterinaryServices;

  /// No description provided for @assistFarmersTraining.
  ///
  /// In en, this message translates to:
  /// **'Assist farmers with training and support.'**
  String get assistFarmersTraining;

  /// No description provided for @overseeComplianceSettings.
  ///
  /// In en, this message translates to:
  /// **'Oversee compliance and manage system settings.'**
  String get overseeComplianceSettings;

  /// No description provided for @riskAssessments.
  ///
  /// In en, this message translates to:
  /// **'Risk Assessments'**
  String get riskAssessments;

  /// No description provided for @complianceTracking.
  ///
  /// In en, this message translates to:
  /// **'Compliance Tracking'**
  String get complianceTracking;

  /// No description provided for @incidentReporting.
  ///
  /// In en, this message translates to:
  /// **'Incident Reporting'**
  String get incidentReporting;

  /// No description provided for @healthMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Health Monitoring'**
  String get healthMonitoring;

  /// No description provided for @diseaseDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Disease Diagnosis'**
  String get diseaseDiagnosis;

  /// No description provided for @treatmentRecords.
  ///
  /// In en, this message translates to:
  /// **'Treatment Records'**
  String get treatmentRecords;

  /// No description provided for @trainingPrograms.
  ///
  /// In en, this message translates to:
  /// **'Training Programs'**
  String get trainingPrograms;

  /// No description provided for @farmVisits.
  ///
  /// In en, this message translates to:
  /// **'Farm Visits'**
  String get farmVisits;

  /// No description provided for @technicalSupport.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get technicalSupport;

  /// No description provided for @systemAdministration.
  ///
  /// In en, this message translates to:
  /// **'System Administration'**
  String get systemAdministration;

  /// No description provided for @complianceOversight.
  ///
  /// In en, this message translates to:
  /// **'Compliance Oversight'**
  String get complianceOversight;

  /// No description provided for @dataAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Data Analytics'**
  String get dataAnalytics;

  /// No description provided for @premiumDashboard.
  ///
  /// In en, this message translates to:
  /// **'Premium Dashboard'**
  String get premiumDashboard;

  /// No description provided for @advancedFarmManagement.
  ///
  /// In en, this message translates to:
  /// **'Advanced farm management system'**
  String get advancedFarmManagement;

  /// No description provided for @noFarmConfigured.
  ///
  /// In en, this message translates to:
  /// **'No Farm Configured'**
  String get noFarmConfigured;

  /// No description provided for @farmerId.
  ///
  /// In en, this message translates to:
  /// **'Farmer ID'**
  String get farmerId;

  /// No description provided for @useIdForConsultations.
  ///
  /// In en, this message translates to:
  /// **'Use this ID for veterinary consultations'**
  String get useIdForConsultations;

  /// No description provided for @farmProfile.
  ///
  /// In en, this message translates to:
  /// **'Farm Profile'**
  String get farmProfile;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @farmDetails.
  ///
  /// In en, this message translates to:
  /// **'Farm Details'**
  String get farmDetails;

  /// No description provided for @livestockInfo.
  ///
  /// In en, this message translates to:
  /// **'Livestock Info'**
  String get livestockInfo;

  /// No description provided for @noAnimalsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No animals registered'**
  String get noAnimalsRegistered;

  /// No description provided for @addAnimalsToTrack.
  ///
  /// In en, this message translates to:
  /// **'Add animals to track inventory'**
  String get addAnimalsToTrack;

  /// No description provided for @farmAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Farm Analytics'**
  String get farmAnalytics;

  /// No description provided for @biosecurityScore.
  ///
  /// In en, this message translates to:
  /// **'Biosecurity Score'**
  String get biosecurityScore;

  /// No description provided for @notAssessed.
  ///
  /// In en, this message translates to:
  /// **'Not Assessed'**
  String get notAssessed;

  /// No description provided for @compliance.
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get compliance;

  /// No description provided for @compliant.
  ///
  /// In en, this message translates to:
  /// **'Compliant'**
  String get compliant;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @healthCheck.
  ///
  /// In en, this message translates to:
  /// **'Health Check'**
  String get healthCheck;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @modules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modules;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @consultationHistory.
  ///
  /// In en, this message translates to:
  /// **'Consultation History'**
  String get consultationHistory;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @disease.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get disease;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile - Coming Soon!'**
  String get profileComingSoon;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings - Coming Soon!'**
  String get settingsComingSoon;

  /// No description provided for @premiumExperience.
  ///
  /// In en, this message translates to:
  /// **'✨ Premium Dashboard Experience!'**
  String get premiumExperience;

  /// No description provided for @digitalRecordKeeping.
  ///
  /// In en, this message translates to:
  /// **'📝 Digital Record Keeping - Farm activity logs and compliance tracking'**
  String get digitalRecordKeeping;

  /// No description provided for @emergencyResponse.
  ///
  /// In en, this message translates to:
  /// **'🚑 Emergency Response - Outbreak protocols and emergency contacts'**
  String get emergencyResponse;

  /// No description provided for @veterinarianDashboard.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Dashboard'**
  String get veterinarianDashboard;

  /// No description provided for @licensedVeterinaryProfessional.
  ///
  /// In en, this message translates to:
  /// **'Licensed Veterinary Professional'**
  String get licensedVeterinaryProfessional;

  /// No description provided for @veterinaryManagementHub.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Management Hub'**
  String get veterinaryManagementHub;

  /// No description provided for @healthMonitoringDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Health Monitoring & Diagnostics'**
  String get healthMonitoringDiagnostics;

  /// No description provided for @diseaseSurveillance.
  ///
  /// In en, this message translates to:
  /// **'Disease Surveillance'**
  String get diseaseSurveillance;

  /// No description provided for @monitorRegionalHealthTrends.
  ///
  /// In en, this message translates to:
  /// **'Monitor regional health trends'**
  String get monitorRegionalHealthTrends;

  /// No description provided for @outbreakResponse.
  ///
  /// In en, this message translates to:
  /// **'Outbreak Response'**
  String get outbreakResponse;

  /// No description provided for @emergencyProtocolsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Emergency protocols & alerts'**
  String get emergencyProtocolsAlerts;

  /// No description provided for @animalConsultation.
  ///
  /// In en, this message translates to:
  /// **'Animal Consultation'**
  String get animalConsultation;

  /// No description provided for @consultAnimals.
  ///
  /// In en, this message translates to:
  /// **'Consult Animals'**
  String get consultAnimals;

  /// No description provided for @examineTreatLivestock.
  ///
  /// In en, this message translates to:
  /// **'Examine and treat livestock by farmer ID'**
  String get examineTreatLivestock;

  /// No description provided for @complianceTraining.
  ///
  /// In en, this message translates to:
  /// **'Compliance & Training'**
  String get complianceTraining;

  /// No description provided for @regulatoryCompliance.
  ///
  /// In en, this message translates to:
  /// **'Regulatory Compliance'**
  String get regulatoryCompliance;

  /// No description provided for @monitorFarmCompliance.
  ///
  /// In en, this message translates to:
  /// **'Monitor farm compliance'**
  String get monitorFarmCompliance;

  /// No description provided for @professionalTraining.
  ///
  /// In en, this message translates to:
  /// **'Professional Training'**
  String get professionalTraining;

  /// No description provided for @continuingEducation.
  ///
  /// In en, this message translates to:
  /// **'Continuing education'**
  String get continuingEducation;

  /// No description provided for @veterinaryOversightSummary.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Oversight Summary'**
  String get veterinaryOversightSummary;

  /// No description provided for @totalFarms.
  ///
  /// In en, this message translates to:
  /// **'Total Farms'**
  String get totalFarms;

  /// No description provided for @highRiskFarms.
  ///
  /// In en, this message translates to:
  /// **'High Risk Farms'**
  String get highRiskFarms;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlerts;

  /// No description provided for @recentVeterinaryActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Veterinary Activities'**
  String get recentVeterinaryActivities;

  /// No description provided for @veterinarianProfileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Profile - Coming Soon!'**
  String get veterinarianProfileComingSoon;

  /// No description provided for @veterinarianSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Settings - Coming Soon!'**
  String get veterinarianSettingsComingSoon;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'ta': return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

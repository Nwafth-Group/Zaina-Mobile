class AppConstants {
  static const String baseUrl = 'http://51.102.241.40/api/v1/';

  // Auth Endpoints
  static const String sendOtp = 'customer/auth/send-otp';
  static const String verifyOtp = 'customer/auth/verify-otp';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String langKey = 'app_language';
}

class AppStrings {
  // General
  static const String appName = 'ZIENA';
  static const String next = 'Next';
  static const String submit = 'Submit';
  static const String done = 'Done';
  static const String logIn = 'Log In';
  static const String getStarted = 'Get Started';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithApple = 'Continue with Apple';
  static const String continueAsGuest = 'Continue as Guest';
  static const String agreeTerms = 'I agree Terms & Conditions';
  static const String orContinueWith = 'or Continue with';

  // Onboarding
  static const String slide1Title = 'Trusted home services,\nwhen you need them';
  static const String slide1Desc =
      'Book cleaning and babysitting easily. Choose your time, location, and pay with clarity.';
  static const String slide2Title = 'Hourly or resident,\nyour choice';
  static const String slide2Desc =
      'Book a single visit or multiple visits to fit your schedule, or subscribe for constant service when needed. Add your address and track your booking online.';
  static const String slide3Title = 'Trusted home services,\nwhen you need them';
  static const String slide3Desc =
      'Book cleaning and babysitting easily. Choose your time, location, and pay with clarity.';

  // Auth
  static const String enterPhone = 'Enter your phone number';
  static const String enterPhoneHint = 'Enter your phone number to log in or create a new account';
  static const String phoneNumber = 'Phone Number';
  static const String verificationCode = 'Verification Code';
  static const String verificationCodeHint =
      'Please enter the verification code sent to your phone number';
  static const String codeSent = 'A code has been sent to your phone';
  static const String resendIn = 'Resend in';
  static const String success = 'Success!';
  static const String successMessage = 'You Have Successfully Registered';

  // Language
  static const String selectLanguage = 'Select Languages';
  static const String selectLanguageHint = 'Please Select the languages you can speak.';
  static const String english = 'English';
  static const String arabic = 'العربية';

  // Terms
  static const String termsAndConditions = 'Terms & Conditions';
}

String lng = 'en';

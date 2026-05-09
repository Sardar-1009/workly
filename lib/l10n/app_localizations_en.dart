// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Workly';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to find your dream job';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerLink => 'Register';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginError => 'Invalid email or password';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join Workly today';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get registerButton => 'Register';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get loginLink => 'Sign In';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get searchHint => 'Search jobs...';

  @override
  String get noJobsFound => 'No jobs found';

  @override
  String appliedTo(String company) {
    return 'Applied to $company';
  }

  @override
  String passedOn(String company) {
    return 'Passed on $company';
  }

  @override
  String get homeTab => 'Home';

  @override
  String get profileTab => 'Profile';

  @override
  String get chatsTab => 'Chats';

  @override
  String get analyticsTab => 'Analytics';

  @override
  String get historyTab => 'History';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileName => 'Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileAbout => 'About';

  @override
  String get profileExperience => 'Experience';

  @override
  String get profileEducation => 'Education';

  @override
  String get profileSkills => 'Skills';

  @override
  String get profileSaved => 'Profile saved!';

  @override
  String get profileSaveError => 'Failed to save profile';

  @override
  String get noSkillsSelected => 'No skills selected';

  @override
  String get maxSkillsReached => 'You can select up to 5 skills';

  @override
  String get aboutMeLabel => 'About me';

  @override
  String get notSet => 'Not set';

  @override
  String get resumeTitle => 'Resume / CV';

  @override
  String get attachResumeLink => 'Attach Resume Link';

  @override
  String get resumeLinkSaved => 'Resume link saved!';

  @override
  String get resumeAvailableToEmployers => 'Available to employers';

  @override
  String get resumeUploaded => 'Resume uploaded';

  @override
  String get editLink => 'Edit';

  @override
  String get deleteResume => 'Delete';

  @override
  String get removeResume => 'Remove Resume?';

  @override
  String get removeResumeConfirm =>
      'Are you sure you want to remove the resume link?';

  @override
  String get resumeRemoved => 'Resume removed.';

  @override
  String get attachResumeLinkTitle => 'Attach Resume Link';

  @override
  String get resumeUrlLabel => 'Resume URL';

  @override
  String get resumeFileNameLabel => 'File name (optional)';

  @override
  String get resumeHint => 'https://drive.google.com/...';

  @override
  String get resumeFileHint => 'My_Resume.pdf';

  @override
  String get saveButton => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get resumeLinkInfo => 'Paste a Google Drive, Dropbox or HH.ru link';

  @override
  String get videoIntroTitle => 'Video Introduction';

  @override
  String get videoIntroSec => '15 sec';

  @override
  String get videoIntroDescription =>
      'Record a short video to introduce yourself to employers and stand out from other candidates.';

  @override
  String get recordVideo => 'Record Video Introduction';

  @override
  String get reRecord => 'Re-record';

  @override
  String get deleteVideo => 'Delete';

  @override
  String get deleteVideoTitle => 'Delete video introduction?';

  @override
  String get deleteVideoConfirm => 'Are you sure you want to delete the video?';

  @override
  String get videoDeleted => 'Video deleted.';

  @override
  String get videoUploaded => 'Video introduction uploaded!';

  @override
  String uploadError(String error) {
    return 'Upload error: $error';
  }

  @override
  String uploadingVideo(int percent) {
    return 'Uploading video... $percent%';
  }

  @override
  String get preparingUpload => 'Preparing upload...';

  @override
  String get recordHint => 'Tap to record your video introduction';

  @override
  String get stopHint => 'Tap to stop';

  @override
  String get maxDuration => 'Max 15 sec';

  @override
  String get preview => 'Preview';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get supportLabel => 'Support Service';

  @override
  String get supportTitle => 'Support Service';

  @override
  String get supportContact => 'Contact us at:';

  @override
  String get logoutButton => 'Logout';

  @override
  String get closeButton => 'Close';

  @override
  String get chatsTitle => 'Messages';

  @override
  String get noChats => 'No messages';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get sendButton => 'Send';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get totalViews => 'Views';

  @override
  String get totalSwipes => 'Swipes';

  @override
  String get totalApplies => 'Applications';

  @override
  String get historyTitle => 'Application History';

  @override
  String get noHistory => 'No history yet';

  @override
  String get applied => 'Applied';

  @override
  String get skipped => 'Skipped';

  @override
  String get filterTitle => 'Filters';

  @override
  String get workFormat => 'Work Format';

  @override
  String get workRemote => 'Remote';

  @override
  String get workOffice => 'Office';

  @override
  String get workHybrid => 'Hybrid';

  @override
  String get applyFilters => 'Apply';

  @override
  String get resetFilters => 'Reset';

  @override
  String get onboardingExperience => 'Your Experience';

  @override
  String get onboardingSkills => 'Your Skills';

  @override
  String get onboardingEducation => 'Education';

  @override
  String get onboardingAbout => 'About You';

  @override
  String get onboardingResume => 'Resume';

  @override
  String get continueButton => 'Continue';

  @override
  String get skipButton => 'Skip';

  @override
  String get errorGeneral => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';
}

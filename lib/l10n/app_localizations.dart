import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ru')
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Workly'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы найти работу мечты'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerLink;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPassword;

  /// No description provided for @loginError.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль'**
  String get loginError;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Присоединяйтесь к Workly'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Полное имя'**
  String get fullNameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get confirmPasswordLabel;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerButton;

  /// No description provided for @hasAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get hasAccount;

  /// No description provided for @loginLink.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginLink;

  /// No description provided for @passwordMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordMismatch;

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск вакансий...'**
  String get searchHint;

  /// No description provided for @noJobsFound.
  ///
  /// In ru, this message translates to:
  /// **'Вакансии не найдены'**
  String get noJobsFound;

  /// No description provided for @appliedTo.
  ///
  /// In ru, this message translates to:
  /// **'Отклик отправлен в {company}'**
  String appliedTo(String company);

  /// No description provided for @passedOn.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено: {company}'**
  String passedOn(String company);

  /// No description provided for @homeTab.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homeTab;

  /// No description provided for @profileTab.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTab;

  /// No description provided for @chatsTab.
  ///
  /// In ru, this message translates to:
  /// **'Чаты'**
  String get chatsTab;

  /// No description provided for @analyticsTab.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get analyticsTab;

  /// No description provided for @historyTab.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get historyTab;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileAbout.
  ///
  /// In ru, this message translates to:
  /// **'О себе'**
  String get profileAbout;

  /// No description provided for @profileExperience.
  ///
  /// In ru, this message translates to:
  /// **'Опыт'**
  String get profileExperience;

  /// No description provided for @profileEducation.
  ///
  /// In ru, this message translates to:
  /// **'Образование'**
  String get profileEducation;

  /// No description provided for @profileSkills.
  ///
  /// In ru, this message translates to:
  /// **'Навыки'**
  String get profileSkills;

  /// No description provided for @profileSaved.
  ///
  /// In ru, this message translates to:
  /// **'Профиль сохранён!'**
  String get profileSaved;

  /// No description provided for @profileSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить профиль'**
  String get profileSaveError;

  /// No description provided for @noSkillsSelected.
  ///
  /// In ru, this message translates to:
  /// **'Навыки не выбраны'**
  String get noSkillsSelected;

  /// No description provided for @maxSkillsReached.
  ///
  /// In ru, this message translates to:
  /// **'Можно выбрать не более 5 навыков'**
  String get maxSkillsReached;

  /// No description provided for @aboutMeLabel.
  ///
  /// In ru, this message translates to:
  /// **'О себе'**
  String get aboutMeLabel;

  /// No description provided for @notSet.
  ///
  /// In ru, this message translates to:
  /// **'Не указано'**
  String get notSet;

  /// No description provided for @resumeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Резюме / CV'**
  String get resumeTitle;

  /// No description provided for @attachResumeLink.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить ссылку на резюме'**
  String get attachResumeLink;

  /// No description provided for @resumeLinkSaved.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка на резюме сохранена!'**
  String get resumeLinkSaved;

  /// No description provided for @resumeAvailableToEmployers.
  ///
  /// In ru, this message translates to:
  /// **'Доступно работодателям'**
  String get resumeAvailableToEmployers;

  /// No description provided for @resumeUploaded.
  ///
  /// In ru, this message translates to:
  /// **'Резюме загружено'**
  String get resumeUploaded;

  /// No description provided for @editLink.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get editLink;

  /// No description provided for @deleteResume.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteResume;

  /// No description provided for @removeResume.
  ///
  /// In ru, this message translates to:
  /// **'Удалить резюме?'**
  String get removeResume;

  /// No description provided for @removeResumeConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить ссылку на резюме?'**
  String get removeResumeConfirm;

  /// No description provided for @resumeRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Резюме удалено.'**
  String get resumeRemoved;

  /// No description provided for @attachResumeLinkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить ссылку на резюме'**
  String get attachResumeLinkTitle;

  /// No description provided for @resumeUrlLabel.
  ///
  /// In ru, this message translates to:
  /// **'URL резюме'**
  String get resumeUrlLabel;

  /// No description provided for @resumeFileNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название файла (необязательно)'**
  String get resumeFileNameLabel;

  /// No description provided for @resumeHint.
  ///
  /// In ru, this message translates to:
  /// **'https://drive.google.com/...'**
  String get resumeHint;

  /// No description provided for @resumeFileHint.
  ///
  /// In ru, this message translates to:
  /// **'My_Resume.pdf'**
  String get resumeFileHint;

  /// No description provided for @saveButton.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get saveButton;

  /// No description provided for @cancelButton.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancelButton;

  /// No description provided for @resumeLinkInfo.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте ссылку на Google Диск, Dropbox или HH.ru'**
  String get resumeLinkInfo;

  /// No description provided for @videoIntroTitle.
  ///
  /// In ru, this message translates to:
  /// **'Видео-визитка'**
  String get videoIntroTitle;

  /// No description provided for @videoIntroSec.
  ///
  /// In ru, this message translates to:
  /// **'15 сек'**
  String get videoIntroSec;

  /// No description provided for @videoIntroDescription.
  ///
  /// In ru, this message translates to:
  /// **'Запишите короткое видео, чтобы представиться работодателю и выделиться среди других кандидатов.'**
  String get videoIntroDescription;

  /// No description provided for @recordVideo.
  ///
  /// In ru, this message translates to:
  /// **'Записать видео-визитку'**
  String get recordVideo;

  /// No description provided for @reRecord.
  ///
  /// In ru, this message translates to:
  /// **'Перезаписать'**
  String get reRecord;

  /// No description provided for @deleteVideo.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteVideo;

  /// No description provided for @deleteVideoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить видео-визитку?'**
  String get deleteVideoTitle;

  /// No description provided for @deleteVideoConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить видео?'**
  String get deleteVideoConfirm;

  /// No description provided for @videoDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Видео удалено.'**
  String get videoDeleted;

  /// No description provided for @videoUploaded.
  ///
  /// In ru, this message translates to:
  /// **'Видео-визитка загружена!'**
  String get videoUploaded;

  /// No description provided for @uploadError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки: {error}'**
  String uploadError(String error);

  /// No description provided for @uploadingVideo.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка видео... {percent}%'**
  String uploadingVideo(int percent);

  /// No description provided for @preparingUpload.
  ///
  /// In ru, this message translates to:
  /// **'Подготовка к загрузке...'**
  String get preparingUpload;

  /// No description provided for @recordHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите для записи видео-визитки'**
  String get recordHint;

  /// No description provided for @stopHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите для остановки'**
  String get stopHint;

  /// No description provided for @maxDuration.
  ///
  /// In ru, this message translates to:
  /// **'Макс. 15 сек'**
  String get maxDuration;

  /// No description provided for @preview.
  ///
  /// In ru, this message translates to:
  /// **'Предпросмотр'**
  String get preview;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get languageLabel;

  /// No description provided for @themeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @supportLabel.
  ///
  /// In ru, this message translates to:
  /// **'Служба поддержки'**
  String get supportLabel;

  /// No description provided for @supportTitle.
  ///
  /// In ru, this message translates to:
  /// **'Служба поддержки'**
  String get supportTitle;

  /// No description provided for @supportContact.
  ///
  /// In ru, this message translates to:
  /// **'Свяжитесь с нами:'**
  String get supportContact;

  /// No description provided for @logoutButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logoutButton;

  /// No description provided for @closeButton.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get closeButton;

  /// No description provided for @chatsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения'**
  String get chatsTitle;

  /// No description provided for @noChats.
  ///
  /// In ru, this message translates to:
  /// **'Нет сообщений'**
  String get noChats;

  /// No description provided for @typeMessage.
  ///
  /// In ru, this message translates to:
  /// **'Введите сообщение...'**
  String get typeMessage;

  /// No description provided for @sendButton.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get sendButton;

  /// No description provided for @analyticsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get analyticsTitle;

  /// No description provided for @totalViews.
  ///
  /// In ru, this message translates to:
  /// **'Просмотры'**
  String get totalViews;

  /// No description provided for @totalSwipes.
  ///
  /// In ru, this message translates to:
  /// **'Свайпы'**
  String get totalSwipes;

  /// No description provided for @totalApplies.
  ///
  /// In ru, this message translates to:
  /// **'Отклики'**
  String get totalApplies;

  /// No description provided for @historyTitle.
  ///
  /// In ru, this message translates to:
  /// **'История откликов'**
  String get historyTitle;

  /// No description provided for @noHistory.
  ///
  /// In ru, this message translates to:
  /// **'История пуста'**
  String get noHistory;

  /// No description provided for @applied.
  ///
  /// In ru, this message translates to:
  /// **'Откликнулись'**
  String get applied;

  /// No description provided for @skipped.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено'**
  String get skipped;

  /// No description provided for @filterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filterTitle;

  /// No description provided for @workFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат работы'**
  String get workFormat;

  /// No description provided for @workRemote.
  ///
  /// In ru, this message translates to:
  /// **'Удалённо'**
  String get workRemote;

  /// No description provided for @workOffice.
  ///
  /// In ru, this message translates to:
  /// **'Офис'**
  String get workOffice;

  /// No description provided for @workHybrid.
  ///
  /// In ru, this message translates to:
  /// **'Гибрид'**
  String get workHybrid;

  /// No description provided for @applyFilters.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get resetFilters;

  /// No description provided for @onboardingExperience.
  ///
  /// In ru, this message translates to:
  /// **'Ваш опыт'**
  String get onboardingExperience;

  /// No description provided for @onboardingSkills.
  ///
  /// In ru, this message translates to:
  /// **'Ваши навыки'**
  String get onboardingSkills;

  /// No description provided for @onboardingEducation.
  ///
  /// In ru, this message translates to:
  /// **'Образование'**
  String get onboardingEducation;

  /// No description provided for @onboardingAbout.
  ///
  /// In ru, this message translates to:
  /// **'О себе'**
  String get onboardingAbout;

  /// No description provided for @onboardingResume.
  ///
  /// In ru, this message translates to:
  /// **'Резюме'**
  String get onboardingResume;

  /// No description provided for @continueButton.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueButton;

  /// No description provided for @skipButton.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skipButton;

  /// No description provided for @errorGeneral.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка'**
  String get errorGeneral;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

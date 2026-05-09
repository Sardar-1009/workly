// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Workly';

  @override
  String get loginTitle => 'Добро пожаловать';

  @override
  String get loginSubtitle => 'Войдите, чтобы найти работу мечты';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get registerLink => 'Зарегистрироваться';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get loginError => 'Неверный email или пароль';

  @override
  String get registerTitle => 'Создать аккаунт';

  @override
  String get registerSubtitle => 'Присоединяйтесь к Workly';

  @override
  String get fullNameLabel => 'Полное имя';

  @override
  String get confirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get hasAccount => 'Уже есть аккаунт?';

  @override
  String get loginLink => 'Войти';

  @override
  String get passwordMismatch => 'Пароли не совпадают';

  @override
  String get searchHint => 'Поиск вакансий...';

  @override
  String get noJobsFound => 'Вакансии не найдены';

  @override
  String appliedTo(String company) {
    return 'Отклик отправлен в $company';
  }

  @override
  String passedOn(String company) {
    return 'Пропущено: $company';
  }

  @override
  String get homeTab => 'Главная';

  @override
  String get profileTab => 'Профиль';

  @override
  String get chatsTab => 'Чаты';

  @override
  String get analyticsTab => 'Аналитика';

  @override
  String get historyTab => 'История';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileName => 'Имя';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileAbout => 'О себе';

  @override
  String get profileExperience => 'Опыт';

  @override
  String get profileEducation => 'Образование';

  @override
  String get profileSkills => 'Навыки';

  @override
  String get profileSaved => 'Профиль сохранён!';

  @override
  String get profileSaveError => 'Не удалось сохранить профиль';

  @override
  String get noSkillsSelected => 'Навыки не выбраны';

  @override
  String get maxSkillsReached => 'Можно выбрать не более 5 навыков';

  @override
  String get aboutMeLabel => 'О себе';

  @override
  String get notSet => 'Не указано';

  @override
  String get resumeTitle => 'Резюме / CV';

  @override
  String get attachResumeLink => 'Прикрепить ссылку на резюме';

  @override
  String get resumeLinkSaved => 'Ссылка на резюме сохранена!';

  @override
  String get resumeAvailableToEmployers => 'Доступно работодателям';

  @override
  String get resumeUploaded => 'Резюме загружено';

  @override
  String get editLink => 'Редактировать';

  @override
  String get deleteResume => 'Удалить';

  @override
  String get removeResume => 'Удалить резюме?';

  @override
  String get removeResumeConfirm =>
      'Вы уверены, что хотите удалить ссылку на резюме?';

  @override
  String get resumeRemoved => 'Резюме удалено.';

  @override
  String get attachResumeLinkTitle => 'Прикрепить ссылку на резюме';

  @override
  String get resumeUrlLabel => 'URL резюме';

  @override
  String get resumeFileNameLabel => 'Название файла (необязательно)';

  @override
  String get resumeHint => 'https://drive.google.com/...';

  @override
  String get resumeFileHint => 'My_Resume.pdf';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get resumeLinkInfo =>
      'Вставьте ссылку на Google Диск, Dropbox или HH.ru';

  @override
  String get videoIntroTitle => 'Видео-визитка';

  @override
  String get videoIntroSec => '15 сек';

  @override
  String get videoIntroDescription =>
      'Запишите короткое видео, чтобы представиться работодателю и выделиться среди других кандидатов.';

  @override
  String get recordVideo => 'Записать видео-визитку';

  @override
  String get reRecord => 'Перезаписать';

  @override
  String get deleteVideo => 'Удалить';

  @override
  String get deleteVideoTitle => 'Удалить видео-визитку?';

  @override
  String get deleteVideoConfirm => 'Вы уверены, что хотите удалить видео?';

  @override
  String get videoDeleted => 'Видео удалено.';

  @override
  String get videoUploaded => 'Видео-визитка загружена!';

  @override
  String uploadError(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String uploadingVideo(int percent) {
    return 'Загрузка видео... $percent%';
  }

  @override
  String get preparingUpload => 'Подготовка к загрузке...';

  @override
  String get recordHint => 'Нажмите для записи видео-визитки';

  @override
  String get stopHint => 'Нажмите для остановки';

  @override
  String get maxDuration => 'Макс. 15 сек';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get languageLabel => 'Язык';

  @override
  String get themeLabel => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get supportLabel => 'Служба поддержки';

  @override
  String get supportTitle => 'Служба поддержки';

  @override
  String get supportContact => 'Свяжитесь с нами:';

  @override
  String get logoutButton => 'Выйти';

  @override
  String get closeButton => 'Закрыть';

  @override
  String get chatsTitle => 'Сообщения';

  @override
  String get noChats => 'Нет сообщений';

  @override
  String get typeMessage => 'Введите сообщение...';

  @override
  String get sendButton => 'Отправить';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get totalViews => 'Просмотры';

  @override
  String get totalSwipes => 'Свайпы';

  @override
  String get totalApplies => 'Отклики';

  @override
  String get historyTitle => 'История откликов';

  @override
  String get noHistory => 'История пуста';

  @override
  String get applied => 'Откликнулись';

  @override
  String get skipped => 'Пропущено';

  @override
  String get filterTitle => 'Фильтры';

  @override
  String get workFormat => 'Формат работы';

  @override
  String get workRemote => 'Удалённо';

  @override
  String get workOffice => 'Офис';

  @override
  String get workHybrid => 'Гибрид';

  @override
  String get applyFilters => 'Применить';

  @override
  String get resetFilters => 'Сбросить';

  @override
  String get onboardingExperience => 'Ваш опыт';

  @override
  String get onboardingSkills => 'Ваши навыки';

  @override
  String get onboardingEducation => 'Образование';

  @override
  String get onboardingAbout => 'О себе';

  @override
  String get onboardingResume => 'Резюме';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get skipButton => 'Пропустить';

  @override
  String get errorGeneral => 'Произошла ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get loading => 'Загрузка...';
}

import 'models.dart';

/// All installer text, in English and Arabic.
class S {
  const S(this.language);

  final AppLanguage language;

  bool get isArabic => language == AppLanguage.ar;

  String _t(String key) {
    final table = isArabic ? _ar : _en;
    return table[key] ?? _en[key] ?? key;
  }

  // Steps
  String get stepWelcome => _t('stepWelcome');
  String get stepView => _t('stepView');
  String get stepDisk => _t('stepDisk');
  String get stepAccount => _t('stepAccount');
  String get stepCompany => _t('stepCompany');
  String get stepSummary => _t('stepSummary');
  String get stepInstall => _t('stepInstall');

  // Navigation
  String get back => _t('back');
  String get next => _t('next');
  String get install => _t('install');
  String get restart => _t('restart');
  String get retry => _t('retry');

  // Welcome
  String get welcomeTitle => _t('welcomeTitle');
  String get tagline => _t('tagline');
  String get welcomeBody => _t('welcomeBody');
  String get chooseLanguage => _t('chooseLanguage');
  String get editionLabel => _t('editionLabel');
  String get dryRunBanner => _t('dryRunBanner');

  // View
  String get viewTitle => _t('viewTitle');
  String get viewBody => _t('viewBody');
  String viewName(DesktopView v) => _t('view_${v.id}');
  String viewDescription(DesktopView v) => _t('viewDesc_${v.id}');

  // Disk
  String get diskTitle => _t('diskTitle');
  String get diskBody => _t('diskBody');
  String get diskWarning => _t('diskWarning');
  String get diskNone => _t('diskNone');
  String get diskTooSmall => _t('diskTooSmall');
  String get diskRemovable => _t('diskRemovable');
  String get diskRefresh => _t('diskRefresh');
  String get encryptTitle => _t('encryptTitle');
  String get encryptBody => _t('encryptBody');
  String get encryptNoTpm => _t('encryptNoTpm');

  // Account
  String get accountTitle => _t('accountTitle');
  String get accountBody => _t('accountBody');
  String get fullName => _t('fullName');
  String get username => _t('username');
  String get usernameHint => _t('usernameHint');
  String get password => _t('password');
  String get confirmPassword => _t('confirmPassword');
  String get computerName => _t('computerName');
  String get timezone => _t('timezone');
  String get errUsernameInvalid => _t('errUsernameInvalid');
  String get errUsernameReserved => _t('errUsernameReserved');
  String get errPasswordShort => _t('errPasswordShort');
  String get errPasswordMismatch => _t('errPasswordMismatch');
  String get errHostname => _t('errHostname');
  String get errFullName => _t('errFullName');

  // Company
  String get companyTitle => _t('companyTitle');
  String get companyBody => _t('companyBody');
  String get companyToggle => _t('companyToggle');
  String get companyConfig => _t('companyConfig');
  String get companyConfigHint => _t('companyConfigHint');
  String get companyProfile => _t('companyProfile');
  String get companyProfileHint => _t('companyProfileHint');
  String get companyOtp => _t('companyOtp');
  String get companyOtpHint => _t('companyOtpHint');
  String get companyLater => _t('companyLater');
  String get errCompanyConfig => _t('errCompanyConfig');

  // Summary
  String get summaryTitle => _t('summaryTitle');
  String get summaryBody => _t('summaryBody');
  String get summaryDisk => _t('summaryDisk');
  String get summaryEncryption => _t('summaryEncryption');
  String get summaryView => _t('summaryView');
  String get summaryAccount => _t('summaryAccount');
  String get summaryLanguage => _t('summaryLanguage');
  String get summaryCompany => _t('summaryCompany');
  String get summaryCompanyNone => _t('summaryCompanyNone');
  String get yes => _t('yes');
  String get no => _t('no');
  String get languageName => _t('languageName');
  String get eraseConfirm => _t('eraseConfirm');

  // Progress
  String get installingTitle => _t('installingTitle');
  String get phasePrepare => _t('phasePrepare');
  String get phaseDownload => _t('phaseDownload');
  String get phaseInstall => _t('phaseInstall');
  String get phaseSettings => _t('phaseSettings');
  String get phaseDone => _t('phaseDone');
  String get showDetails => _t('showDetails');
  String get hideDetails => _t('hideDetails');
  String get installFailed => _t('installFailed');
  String get doneTitle => _t('doneTitle');
  String get doneBody => _t('doneBody');
  String get doneDryRun => _t('doneDryRun');

  String editionName(String edition) {
    final key = 'edition_$edition';
    final value = _t(key);
    return value == key ? 'FalakOS' : value;
  }
}

const Map<String, String> _en = {
  'stepWelcome': 'Welcome',
  'stepView': 'Desktop',
  'stepDisk': 'Disk',
  'stepAccount': 'Your account',
  'stepCompany': 'Company',
  'stepSummary': 'Review',
  'stepInstall': 'Install',
  'back': 'Back',
  'next': 'Next',
  'install': 'Install FalakOS',
  'restart': 'Restart now',
  'retry': 'Try again',
  'welcomeTitle': 'Welcome to FalakOS',
  'tagline': 'All in an orbit are swimming.',
  'welcomeBody': 'This installer puts FalakOS on this computer. It takes about 15 minutes and needs an internet connection.',
  'chooseLanguage': 'Language',
  'editionLabel': 'Edition',
  'dryRunBanner': 'Practice mode: nothing will be written to any disk.',
  'viewTitle': 'Choose how your desktop looks',
  'viewBody': 'You can switch any time later from "Desktop View" in the menu.',
  'view_falak': 'Falak',
  'view_mac': 'Mac-like',
  'view_windows': 'Windows-like',
  'viewDesc_falak': 'FalakOS\'s own floating bar',
  'viewDesc_mac': 'Top bar and a dock',
  'viewDesc_windows': 'Taskbar and a Start menu',
  'diskTitle': 'Where should FalakOS go?',
  'diskBody': 'Pick the disk to install on.',
  'diskWarning': 'Everything on the selected disk will be erased.',
  'diskNone': 'No suitable disk was found. Connect a disk of at least 32 GB, then refresh.',
  'diskTooSmall': 'Too small (needs 32 GB)',
  'diskRemovable': 'Removable',
  'diskRefresh': 'Refresh',
  'encryptTitle': 'Encrypt the disk',
  'encryptBody': 'Protects your data if the computer is lost or stolen. Unlocks automatically with this computer\'s security chip (TPM).',
  'encryptNoTpm': 'Not available: this computer has no TPM security chip.',
  'accountTitle': 'Create your account',
  'accountBody': 'This account can install apps and change settings.',
  'fullName': 'Full name',
  'username': 'Username',
  'usernameHint': 'Lowercase letters, numbers, - and _',
  'password': 'Password',
  'confirmPassword': 'Confirm password',
  'computerName': 'Computer name',
  'timezone': 'Time zone',
  'errUsernameInvalid': 'Use lowercase English letters, numbers, - or _, starting with a letter.',
  'errUsernameReserved': 'This name is reserved by the system. Pick another.',
  'errPasswordShort': 'Use at least 8 characters.',
  'errPasswordMismatch': 'The passwords don\'t match.',
  'errHostname': 'Use lowercase English letters, numbers and -.',
  'errFullName': 'Enter your name.',
  'companyTitle': 'Join your company',
  'companyBody': 'Connect this computer to your company now, so colleagues can sign in with their work accounts from the first boot.',
  'companyToggle': 'Join a company on first boot',
  'companyConfig': 'Company setup link',
  'companyConfigHint': 'https://it.example.com/falak.json (from your IT team)',
  'companyProfile': 'Profile',
  'companyProfileHint': 'For example: standard or management',
  'companyOtp': 'One-time join code (optional)',
  'companyOtpHint': 'From your IT team',
  'companyLater': 'You can also do this later with falak-enroll.',
  'errCompanyConfig': 'Enter the https:// link and a profile.',
  'summaryTitle': 'Ready to install',
  'summaryBody': 'Check everything below, then start the install.',
  'summaryDisk': 'Disk',
  'summaryEncryption': 'Encryption',
  'summaryView': 'Desktop',
  'summaryAccount': 'Account',
  'summaryLanguage': 'Language',
  'summaryCompany': 'Company',
  'summaryCompanyNone': 'Not now',
  'yes': 'On',
  'no': 'Off',
  'languageName': 'English',
  'eraseConfirm': 'I understand that everything on this disk will be erased.',
  'installingTitle': 'Installing FalakOS',
  'phasePrepare': 'Getting ready',
  'phaseDownload': 'Downloading FalakOS',
  'phaseInstall': 'Installing to the disk',
  'phaseSettings': 'Saving your settings',
  'phaseDone': 'Done',
  'showDetails': 'Show details',
  'hideDetails': 'Hide details',
  'installFailed': 'The install didn\'t finish.',
  'doneTitle': 'FalakOS is installed',
  'doneBody': 'Remove the USB stick, then restart. Your settings are applied on the first start.',
  'doneDryRun': 'Practice run finished. Nothing was written to disk.',
  'edition_business': 'FalakOS Business',
  'edition_corporate': 'FalakOS Corporate',
  'edition_free': 'FalakOS Free',
  'edition_gaming': 'FalakOS Gaming',
  'edition_gaming-nvidia': 'FalakOS Gaming',
  'edition_full': 'FalakOS Full',
  'edition_full-nvidia': 'FalakOS Full',
};

const Map<String, String> _ar = {
  'stepWelcome': 'مرحبًا',
  'stepView': 'سطح المكتب',
  'stepDisk': 'القرص',
  'stepAccount': 'حسابك',
  'stepCompany': 'الشركة',
  'stepSummary': 'المراجعة',
  'stepInstall': 'التثبيت',
  'back': 'رجوع',
  'next': 'التالي',
  'install': 'تثبيت FalakOS',
  'restart': 'إعادة التشغيل الآن',
  'retry': 'حاول مرة أخرى',
  'welcomeTitle': 'مرحبًا بك في FalakOS',
  'tagline': 'كُلٌّ فِي فَلَكٍ يَسْبَحُونَ',
  'welcomeBody': 'هذا المثبّت يضع FalakOS على هذا الكمبيوتر. يستغرق نحو 15 دقيقة ويحتاج إلى اتصال بالإنترنت.',
  'chooseLanguage': 'اللغة',
  'editionLabel': 'الإصدار',
  'dryRunBanner': 'وضع التجربة: لن يُكتب أي شيء على أي قرص.',
  'viewTitle': 'اختر شكل سطح المكتب',
  'viewBody': 'يمكنك تغييره في أي وقت من «شكل سطح المكتب» في القائمة.',
  'view_falak': 'فلك',
  'view_mac': 'على طريقة ماك',
  'view_windows': 'على طريقة ويندوز',
  'viewDesc_falak': 'الشريط العائم الخاص بـ FalakOS',
  'viewDesc_mac': 'شريط علوي ورصيف تطبيقات',
  'viewDesc_windows': 'شريط مهام وقائمة ابدأ',
  'diskTitle': 'أين تريد تثبيت FalakOS؟',
  'diskBody': 'اختر القرص الذي سيُثبَّت عليه النظام.',
  'diskWarning': 'سيتم مسح كل ما على القرص المختار.',
  'diskNone': 'لم يُعثر على قرص مناسب. وصّل قرصًا بسعة 32 جيجابايت على الأقل ثم حدّث القائمة.',
  'diskTooSmall': 'صغير جدًا (يحتاج 32 جيجابايت)',
  'diskRemovable': 'قابل للإزالة',
  'diskRefresh': 'تحديث',
  'encryptTitle': 'تشفير القرص',
  'encryptBody': 'يحمي بياناتك إذا فُقد الكمبيوتر أو سُرق. يُفتح تلقائيًا بشريحة الأمان في هذا الكمبيوتر (TPM).',
  'encryptNoTpm': 'غير متاح: هذا الكمبيوتر لا يحتوي على شريحة أمان TPM.',
  'accountTitle': 'أنشئ حسابك',
  'accountBody': 'هذا الحساب يستطيع تثبيت التطبيقات وتغيير الإعدادات.',
  'fullName': 'الاسم الكامل',
  'username': 'اسم المستخدم',
  'usernameHint': 'حروف إنجليزية صغيرة وأرقام و- و_',
  'password': 'كلمة المرور',
  'confirmPassword': 'تأكيد كلمة المرور',
  'computerName': 'اسم الكمبيوتر',
  'timezone': 'المنطقة الزمنية',
  'errUsernameInvalid': 'استخدم حروفًا إنجليزية صغيرة وأرقامًا و- أو _، ويبدأ بحرف.',
  'errUsernameReserved': 'هذا الاسم محجوز للنظام. اختر اسمًا آخر.',
  'errPasswordShort': 'استخدم 8 أحرف على الأقل.',
  'errPasswordMismatch': 'كلمتا المرور غير متطابقتين.',
  'errHostname': 'استخدم حروفًا إنجليزية صغيرة وأرقامًا و-.',
  'errFullName': 'اكتب اسمك.',
  'companyTitle': 'الانضمام إلى شركتك',
  'companyBody': 'اربط هذا الكمبيوتر بشركتك الآن، ليتمكن زملاؤك من الدخول بحسابات العمل من أول تشغيل.',
  'companyToggle': 'الانضمام إلى شركة عند أول تشغيل',
  'companyConfig': 'رابط إعداد الشركة',
  'companyConfigHint': 'https://it.example.com/falak.json (من فريق تقنية المعلومات)',
  'companyProfile': 'الملف التعريفي',
  'companyProfileHint': 'مثلًا: standard أو management',
  'companyOtp': 'رمز الانضمام لمرة واحدة (اختياري)',
  'companyOtpHint': 'من فريق تقنية المعلومات',
  'companyLater': 'يمكنك أيضًا فعل ذلك لاحقًا باستخدام falak-enroll.',
  'errCompanyConfig': 'اكتب رابط https:// واسم الملف التعريفي.',
  'summaryTitle': 'جاهز للتثبيت',
  'summaryBody': 'راجع كل شيء بالأسفل ثم ابدأ التثبيت.',
  'summaryDisk': 'القرص',
  'summaryEncryption': 'التشفير',
  'summaryView': 'سطح المكتب',
  'summaryAccount': 'الحساب',
  'summaryLanguage': 'اللغة',
  'summaryCompany': 'الشركة',
  'summaryCompanyNone': 'ليس الآن',
  'yes': 'مفعّل',
  'no': 'غير مفعّل',
  'languageName': 'العربية',
  'eraseConfirm': 'أفهم أن كل ما على هذا القرص سيتم مسحه.',
  'installingTitle': 'جارٍ تثبيت FalakOS',
  'phasePrepare': 'التجهيز',
  'phaseDownload': 'تنزيل FalakOS',
  'phaseInstall': 'التثبيت على القرص',
  'phaseSettings': 'حفظ إعداداتك',
  'phaseDone': 'تم',
  'showDetails': 'عرض التفاصيل',
  'hideDetails': 'إخفاء التفاصيل',
  'installFailed': 'لم يكتمل التثبيت.',
  'doneTitle': 'تم تثبيت FalakOS',
  'doneBody': 'انزع وحدة USB ثم أعد التشغيل. ستُطبَّق إعداداتك عند أول تشغيل.',
  'doneDryRun': 'انتهت التجربة. لم يُكتب أي شيء على القرص.',
  'edition_business': 'FalakOS للأعمال',
  'edition_corporate': 'FalakOS للشركات',
  'edition_free': 'FalakOS المجاني',
  'edition_gaming': 'FalakOS للألعاب',
  'edition_gaming-nvidia': 'FalakOS للألعاب',
  'edition_full': 'FalakOS الكامل',
  'edition_full-nvidia': 'FalakOS الكامل',
};

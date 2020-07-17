class LocalizationService {
  static const LocalizationsDelegate<LocalizationService> delegate =
      const _LocalizationServiceDelegate();

  LocalizationService(this.locale);

  final Locale locale;

  static LocalizationService of(BuildContext context) =>
      Localizations.of<LocalizationService>(context, LocalizationService);

  Map<String, String> _localizedStrings;

  Future<bool> load() async {
    final String jsonString =
        await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  String translate(String key) => _localizedStrings[key];
}

class _LocalizationServiceDelegate
    extends LocalizationsDelegate<LocalizationService> {
  const _LocalizationServiceDelegate();

  // TODO: add new lang in array
  @override
  bool isSupported(Locale locale) => ['de'].contains(locale.languageCode);

  @override
  Future<LocalizationService> load(Locale locale) async {
    final LocalizationService localizations = new LocalizationService(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_LocalizationServiceDelegate old) => false;
}
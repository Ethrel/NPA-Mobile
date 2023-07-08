import 'package:shared_preferences/shared_preferences.dart';

enum _PreferenceKeys {
  lastVisitedURI("lastVisitedURI"),
  npaInjectUri("npaInjectURI"),
  ;

  final String key;
  const _PreferenceKeys(this.key);
}

class Preferences {
  late SharedPreferences _prefs;
  static Preferences? _instance;

  Preferences._();

  Future _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<Preferences> _create() async {
    Preferences pref = Preferences._();
    await pref._init();
    return pref;
  }

  static Future<Preferences> getInstance() async {
    _instance ??= await _create();
    return _instance as Preferences;
  }

  String? _getString(_PreferenceKeys key) {
    return _prefs.getString(key.key);
  }

  void _setString(_PreferenceKeys key, String? value) {
    if (value == null) {
      _prefs.remove(key.key);
      return;
    }
    _prefs.setString(key.key, value);
  }

  String get lastVisitedURI => _getString(_PreferenceKeys.lastVisitedURI) ?? "https://np.ironhelmet.com";
  set lastVisitedURI(String? uri) => _setString(_PreferenceKeys.lastVisitedURI, uri);

  String get npaInjectURI => _getString(_PreferenceKeys.npaInjectUri) ?? "https://bitbucket.org/osrictheknight/iosnpagent/raw/HEAD/";
  set npaInjectURI(String? uri) => _setString(_PreferenceKeys.npaInjectUri, uri);
}

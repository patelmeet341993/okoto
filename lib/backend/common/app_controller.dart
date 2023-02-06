//To Store Some Important App related Variables
class AppController {
  static AppController? _instance;

  factory AppController() {
    _instance ??= AppController._();
    return _instance!;
  }

  AppController._();

  static bool _isDev = true;

  static bool get isDev => _isDev;

  static set isDev(bool value) {
    _isDev = value;
  }
}
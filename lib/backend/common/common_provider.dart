import 'package:flutter/foundation.dart';

class CommonProvider extends ChangeNotifier {
  void notify({bool isNotify = true}) {
    if(isNotify) notifyListeners();
  }
}
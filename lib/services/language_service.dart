import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  bool _isTamil = false;

  bool get isTamil => _isTamil;

  void toggle() {
    _isTamil = !_isTamil;
    notifyListeners();
  }

  String t(String en, String ta) {
    return _isTamil ? ta : en;
  }
}
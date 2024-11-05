import 'dart:async';

import 'package:flutter/material.dart';

class ApplicationController {
  ApplicationController._privateConstructor();

  static final ApplicationController _instance =
      ApplicationController._privateConstructor();

  factory ApplicationController() {
    return _instance;
  }

  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  ValueNotifier<bool> get isLoading => _isLoading;

  Timer? _timerLoading;

  void showLoading() {
    _timerLoading?.cancel();
    _instance._isLoading.value = true;
    _timerLoading = Timer(const Duration(seconds: 10), () {
      hideLoading();
    });
  }

  void hideLoading() {
    _instance._isLoading.value = false;
    _timerLoading?.cancel();
  }
}

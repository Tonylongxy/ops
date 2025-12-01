import 'package:flutter/foundation.dart';

import '../../models/login_response.dart';

class AppSession {
  AppSession._internal();

  static final AppSession _instance = AppSession._internal();

  static AppSession get instance => _instance;

  final ValueNotifier<LoginResponse?> currentUser =
      ValueNotifier<LoginResponse?>(null);

  void update(LoginResponse? response) {
    currentUser.value = response;
  }
}


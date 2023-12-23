
import 'package:flutter/material.dart';

@immutable
class Routes {
  const Routes._();

  // BASE
  static const String AppStartupScreenRoute = '/';
  //LOGIN
  static const String LoginScreenRoute = 'login';
  static const String SignUpScreenRoute = 'login/signup';

  //HOME
  static const String MainScreenRoute = 'main';

  //SHARED PAYMENT
  static const String SharedPaymentSelectContacsScreen = 'main/shared_payment/contacts';
  static const String ConfigurationScreenRoute = 'main/configuration';
  static const String AddContactsScreenRoute = 'main/add_contacts';
}

enum RouteNames {
  AppStartupScreenRoute,
  LoginScreenRoute,
  SignUpScreenRoute,
  MainScreenRoute,
  SharedPaymentSelectContacsScreenRoute,
  ConfigurationScreenRoute,
  AddContactsScreenRoute
}



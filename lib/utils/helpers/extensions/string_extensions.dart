import 'package:flutter/material.dart';

import '../../app_colors.dart';




extension StringParsing on String {


  double parseToDouble() {
    try {
      return double.parse(this);
    } catch (exception) {
      return 0.0;
    }
  }
}

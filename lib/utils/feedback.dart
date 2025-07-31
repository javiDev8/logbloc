import 'package:flutter/material.dart';
import 'package:logize/main.dart';

feedback(String msg) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(msg)),
  );
}

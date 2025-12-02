import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void show(String msg, {BuildContext? context}) {
    if (kIsWeb) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      } else {
        print('Toast: $msg'); // fallback
      }
    } else {
      Fluttertoast.showToast(msg: msg);
    }
  }
}

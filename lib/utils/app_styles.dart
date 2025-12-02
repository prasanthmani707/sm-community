import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // ----------- TEXT STYLES -----------
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
static const TextStyle bodyGrey = TextStyle(
  fontSize: 15,
  color: AppColors.grey,
);

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textGrey,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textDark,
  );

  static const TextStyle messageText = TextStyle(
    fontSize: 16,
    height: 1.3,
    color: AppColors.textDark,
  );

  static const TextStyle messageTextWhite = TextStyle(
    fontSize: 16,
    height: 1.3,
    color: Colors.white,
  );

  static const TextStyle smallText = TextStyle(
    fontSize: 13,
    color: AppColors.textGrey,
  );

  // ⭐ Add this for buttons
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  // ----------- INPUT DECORATION -----------
  static InputDecoration inputField({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 255, 98), width: 2),
      ),
    );
  }

  // ----------- CARD / BUBBLE STYLE -----------
  static BoxDecoration rounded({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    );
  }
}

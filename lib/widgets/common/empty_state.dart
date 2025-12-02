import 'package:flutter/material.dart';
import '../../utils/app_styles.dart';
import '../../utils/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.chat_bubble_outline,
    this.iconSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: AppColors.grey),
          const SizedBox(height: 10),
          Text(message, style: AppStyles.bodyGrey),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ScrollToBottomButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const ScrollToBottomButton({
    super.key,
    required this.visible,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink(); // hide if not visible

    return Positioned(
      right: 20,
      bottom: 80,
      child: FloatingActionButton(
        mini: true,
        onPressed: onPressed,
        child: const Icon(Icons.arrow_downward),
      ),
    );
  }
}

// onboarding_button.dart
import 'package:flutter/material.dart';

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OnboardingButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        width: 140,
        height: 45,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E676), // Màu xanh lá mạ chuẩn Figma
            foregroundColor: Colors.white,
            elevation: 0, // Thiết kế phẳng không bóng đổ
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bo góc nút
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
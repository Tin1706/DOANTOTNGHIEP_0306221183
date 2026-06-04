// selection_title.dart
import 'package:flutter/material.dart';

class SelectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SelectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), // Khoảng cách từ tiêu đề xuống danh sách bên dưới
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái giống Figma
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8), // Khoảng cách giữa tiêu đề và phụ đề
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black.withOpacity(0.6), // Màu chữ xám nhẹ
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductFlag extends StatelessWidget {
  final String text;
  final FlagType type;

  const ProductFlag({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (type) {
      FlagType.special => (const Color(0xFFCA2222), Colors.white),
      FlagType.tryIt => (const Color(0xFF458500), Colors.white),
      FlagType.saveInCart => (const Color(0xFFFFF3E2), const Color(0xFF333333)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 16 / 12,
          color: textColor,
        ),
      ),
    );
  }
}

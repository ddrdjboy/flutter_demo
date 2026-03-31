import 'package:flutter/material.dart';

class CategoryNav extends StatelessWidget {
  const CategoryNav({super.key});

  static const _categories = [
    (Icons.local_offer, 'Deals'),
    (Icons.favorite, 'Wellness'),
    (Icons.spa, 'Beauty'),
    (Icons.child_care, 'Baby'),
    (Icons.sports_gymnastics, 'Sports'),
    (Icons.pets, 'Pets'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final (icon, label) = _categories[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(icon, color: colorScheme.onSecondaryContainer),
              ),
              const SizedBox(height: 4),
              Text(label, style: textTheme.labelSmall),
            ],
          );
        },
      ),
    );
  }
}

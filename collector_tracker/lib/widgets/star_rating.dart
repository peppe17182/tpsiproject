import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final double size;
  final bool readOnly;

  const StarRating({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 32,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        final isFilled = starIndex <= rating;
        return GestureDetector(
          onTap: readOnly ? null : () => onChanged(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: isFilled
                  ? const Color(0xFFF59E0B)
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        );
      }),
    );
  }
}

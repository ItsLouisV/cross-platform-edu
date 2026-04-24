import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 14.0,
    this.color = const Color(0xFFFB923C),
    this.showLabel = true,
  });

  final double rating;
  final double size;
  final Color color;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final isFilled = index < rating.floor();
          final isHalf = !isFilled && index < rating && (rating - index) >= 0.3;
          return Padding(
            padding: EdgeInsets.only(right: index < 4 ? 1 : 0),
            child: Icon(
              isFilled
                  ? Icons.star_rounded
                  : isHalf
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: size,
              color: isFilled || isHalf ? color : const Color(0xFFD1D5DB),
            ),
          );
        }),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size - 2,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}

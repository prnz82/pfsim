import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerLoading.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  });

  const ShimmerLoading.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    // Detect theme brightness for appropriate shimmer colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase;
    final highlightColor = isDark ? AppColors.darkShimmerHighlight : AppColors.shimmerHighlight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: baseColor,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class StockListShimmer extends StatelessWidget {
  const StockListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 6,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Row(
        children: [
          const ShimmerLoading.circular(width: 48, height: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading.rectangular(height: 16, width: 100),
                const SizedBox(height: 8),
                const ShimmerLoading.rectangular(height: 12, width: 80),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const ShimmerLoading.rectangular(height: 16, width: 80),
              const SizedBox(height: 8),
              const ShimmerLoading.rectangular(height: 12, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

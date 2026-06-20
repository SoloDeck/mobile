import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solodesk_mobile/core/theme/app_semantic_colors.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key, this.itemCount = 4});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    return Shimmer.fromColors(
      baseColor: semantic.shimmerBase,
      highlightColor: semantic.shimmerHighlight,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (_, __) => const _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    // Shimmer.fromColors paints these blocks; the block color only needs to be
    // opaque so the gradient shows through — use the base shimmer tone.
    final block = context.semanticColors.shimmerBase;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: block,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 16, color: block),
          const SizedBox(height: 12),
          Container(width: 200, height: 12, color: block),
          const SizedBox(height: 8),
          Container(width: 120, height: 12, color: block),
        ],
      ),
    );
  }
}

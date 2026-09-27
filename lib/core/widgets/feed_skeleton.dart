import 'package:flutter/material.dart';

class FeedSkeleton extends StatefulWidget {
  const FeedSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  State<FeedSkeleton> createState() => _FeedSkeletonState();
}

class _FeedSkeletonState extends State<FeedSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.4,
    upperBound: 0.9,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      label: 'Loading stories',
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _controller,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: widget.itemCount,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, _) => _SkeletonCard(color: color),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget box(double height, {double? width}) => Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            box(160, width: double.infinity),
            const SizedBox(height: 12),
            box(14, width: 120),
            const SizedBox(height: 8),
            box(18, width: double.infinity),
            const SizedBox(height: 6),
            box(18, width: 220),
          ],
        ),
      ),
    );
  }
}

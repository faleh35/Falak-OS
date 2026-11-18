import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Night-sky background with stars and a faint orbit, matching the FalakOS wallpaper.
class NightSky extends StatelessWidget {
  const NightSky({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _NightSkyPainter(), child: SizedBox.expand());
  }
}

class _NightSkyPainter extends CustomPainter {
  const _NightSkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [FalakColors.night, FalakColors.nightDeep],
        ).createShader(rect),
    );

    final random = math.Random(7);
    final star = Paint();
    for (var i = 0; i < 160; i++) {
      final opacity = 0.25 + random.nextDouble() * 0.55;
      star.color = Color.fromRGBO(255, 255, 255, opacity);
      final r = 0.5 + random.nextDouble() * 1.2;
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), r, star);
    }

    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x33F5B942);
    canvas.save();
    canvas.translate(size.width * 0.82, size.height * 0.88);
    canvas.rotate(-0.32);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: size.width * 0.9, height: size.height * 0.28), orbit);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rounded panel the pages sit on.
class FalakPanel extends StatelessWidget {
  const FalakPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xE6141A3A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FalakColors.panelBorder),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }
}

/// Big page title with an optional subtitle.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: theme.textTheme.bodyLarge?.copyWith(color: FalakColors.muted)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

/// A selectable card with a gold outline when selected.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.enabled = true,
  });

  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: selected ? const Color(0xFF1E2760) : const Color(0xFF171E45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? FalakColors.gold : FalakColors.panelBorder, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: enabled ? onTap : null, child: child),
      ),
    );
  }
}

/// Rounded card for list tiles and switches (a Material, so ink splashes show).
class FalakCard extends StatelessWidget {
  const FalakCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF171E45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: FalakColors.panelBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Amber notice row.
class WarningNote extends StatelessWidget {
  const WarningNote({super.key, required this.text, this.color = FalakColors.gold});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
      ],
    );
  }
}

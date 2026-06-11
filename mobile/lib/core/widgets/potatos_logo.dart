import 'package:flutter/material.dart';

import '../theme/potatos_theme.dart';

class PotatosLogo extends StatelessWidget {
  const PotatosLogo({
    required this.height,
    this.width = 150,
    this.showTagline = false,
    super.key,
  });

  final double height;
  final double width;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final blockSize = height * 0.2;
    final blockSpacing = height * 0.06;
    final logo = SizedBox(
      height: height,
      width: width,
      child: Row(
        children: [
          SizedBox(
            width: height * 1.14,
            height: height,
            child: Wrap(
              spacing: blockSpacing,
              runSpacing: blockSpacing,
              children: [
                _LogoBlock(
                  color: PotatosColors.racingOrange,
                  size: blockSize,
                ),
                _LogoBlock(
                  color: PotatosColors.racingOrange,
                  size: blockSize,
                ),
                _LogoBlock(color: PotatosColors.gridLine, size: blockSize),
                _LogoBlock(
                  color: PotatosColors.racingOrange,
                  size: blockSize,
                ),
                _LogoBlock(color: PotatosColors.gridLine, size: blockSize),
                _LogoBlock(
                  color: PotatosColors.racingOrange,
                  size: blockSize,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              child: Text(
                'POTATOS',
                style: TextStyle(
                  color: PotatosColors.racingOrange,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!showTagline) return logo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(height: 4),
        Text(
          'RACERSIM',
          style: TextStyle(
            color: PotatosColors.flagWhite.withValues(alpha: 0.72),
            fontSize: height * 0.18,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

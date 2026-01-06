import 'package:flutter/material.dart';

import 'damu_colors.dart';

class DamuPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final double height;
  final double radius;

  const DamuPillButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.height = 58,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        child: Text(text),
      ),
    );
  }
}

class DamuTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;

  const DamuTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
  });

  @override
  State<DamuTextField> createState() => _DamuTextFieldState();
}

class _DamuTextFieldState extends State<DamuTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DamuColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: DamuColors.shadow, blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: Icon(widget.prefixIcon, color: DamuColors.textMuted),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.obscure)
                IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: DamuColors.textMuted),
                ),
              IconButton(
                onPressed: widget.controller.text.isEmpty
                    ? null
                    : () {
                        widget.controller.clear();
                        setState(() {});
                      },
                icon: const Icon(Icons.delete_outline, color: DamuColors.textMuted),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}

class DamuCatImage extends StatelessWidget {
  final double size;
  const DamuCatImage({super.key, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/котик.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.pets, size: 64, color: Colors.white),
          );
        },
      ),
    );
  }
}

class DamuWaterTank extends StatelessWidget {
  final double size;
  final int percent;
  const DamuWaterTank({super.key, this.size = 240, required this.percent});

  @override
  Widget build(BuildContext context) {
    final fill = (percent / 100).clamp(0.0, 1.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEAF6FF), Color(0xFFD4ECFF)],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fill,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8EDBFF), Color(0xFF2BA0B9)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _TankGlossPainter(fill: fill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TankGlossPainter extends CustomPainter {
  final double fill;
  _TankGlossPainter({required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final gloss = Paint()..color = Colors.white.withValues(alpha: 0.25);
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.06);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, 16, 26, size.height - 32),
        const Radius.circular(18),
      ),
      gloss,
    );

    final waterlineY = size.height * (1 - fill);
    canvas.drawRect(Rect.fromLTWH(0, waterlineY - 1, size.width, 2), shadow);
  }

  @override
  bool shouldRepaint(covariant _TankGlossPainter oldDelegate) => oldDelegate.fill != fill;
}

class DamuAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double size;
  final VoidCallback? onTap;

  const DamuAvatar({super.key, this.url, this.name, this.size = 48, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (url != null && url!.isNotEmpty) {
      inner = ClipOval(
        child: Image.network(
          url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _fallback();
          },
        ),
      );
    } else {
      inner = _fallback();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: const [BoxShadow(color: DamuColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: ClipOval(child: inner),
      ),
    );
  }

  Widget _fallback() {
    final initial = (name?.trim().isNotEmpty ?? false) ? name!.trim().characters.first.toUpperCase() : '?';
    return Container(
      color: const Color(0xFFE6EEF6),
      alignment: Alignment.center,
      child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF4B647F))),
    );
  }
}

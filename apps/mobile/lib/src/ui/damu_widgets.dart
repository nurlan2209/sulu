import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';

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
          elevation: 8,
          shadowColor: background.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.4),
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
        gradient: DamuGradients.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: const [BoxShadow(color: DamuColors.shadow, blurRadius: 14, offset: Offset(0, 8))],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: DamuColors.textMuted),
          prefixIcon: Icon(widget.prefixIcon, color: DamuColors.accent),
          suffixIcon: (widget.obscure || widget.controller.text.isNotEmpty)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.obscure)
                      IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: DamuColors.textMuted),
                      ),
                    if (widget.controller.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close, color: DamuColors.textMuted),
                      ),
                  ],
                )
              : null,
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
    final rawFill = (percent / 100).clamp(0.0, 1.0);
    final fill = rawFill;
    const catAspect = _CatBowlMask.viewBoxWidth / _CatBowlMask.viewBoxHeight;
    final height = size;
    final width = size * catAspect;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const _CatBowlFillPainter(),
            ),
          ),
          Positioned.fill(
            child: _CatWaterOverlay(fill),
          ),
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/котикаа.svg',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatBowlFillPainter extends CustomPainter {
  const _CatBowlFillPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bowl = _CatBowlMask.bowlForSize(size);
    final rect = bowl.bounds;
    if (rect.isEmpty) return;

    canvas.save();
    canvas.clipPath(bowl.path);

    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEAF6FF), Color(0xFFD5F0FF)],
      ).createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CatBowlFillPainter oldDelegate) => false;
}

class _CatWaterOverlay extends StatelessWidget {
  final double fill;
  const _CatWaterOverlay(this.fill);

  @override
  Widget build(BuildContext context) {
    if (fill <= 0) return const SizedBox.shrink();
    return ClipRect(
      clipper: _WaterClipper(fill),
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF9DE0FF).withValues(alpha: 0.7),
            const Color(0xFF2BA0B9).withValues(alpha: 0.9),
          ],
        ).createShader(rect),
        child: SvgPicture.asset(
          'assets/images/маска.svg',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _WaterClipper extends CustomClipper<Rect> {
  final double fill;
  const _WaterClipper(this.fill);

  @override
  Rect getClip(Size size) {
    final clamped = fill.clamp(0.0, 1.0);
    final height = size.height * clamped;
    return Rect.fromLTWH(0, size.height - height, size.width, height);
  }

  @override
  bool shouldReclip(covariant _WaterClipper oldDelegate) => oldDelegate.fill != fill;
}

class _CatBowlMask {
  static const double viewBoxWidth = 8803.79;
  static const double viewBoxHeight = 7101.21;
  static const Size _viewBox = Size(viewBoxWidth, viewBoxHeight);
  static const String _rimPathData =
      'M1130.73 3560.01c12.48,24.86 -1.14,10.6 27.9,35.37 11.87,10.13 19.35,12.32 34.82,24.08l227.5 135.56c90.72,43.96 252.44,95.04 356.1,124.65 258.29,73.79 527.58,120.64 797.67,162.88 1151.77,180.1 2487.94,166.42 3641.2,41.16 289.38,-31.43 1343.89,-220.5 1536.48,-393.73l-14.47 -67.41c-68.92,16.69 -157.47,71.27 -238.03,102.23 -80.75,31.03 -172.4,58.87 -256.59,83.21 -179.83,51.99 -373.56,99.22 -564.16,127.53 -51.42,21.76 -479.32,80.6 -520.7,69.65 -101.61,42.77 -979.56,87.82 -1154.99,88.96 -825.81,5.33 -1508.71,0.95 -2330.46,-116.38 -499.07,-71.26 -537.56,-91.76 -1001.18,-210.67 -106.4,-41.52 -208.08,-75.1 -303.91,-123.86 -47.18,-24 -90.86,-55.05 -128.99,-81.55 -65.59,-45.58 -59.92,-42.6 -102.71,-109.1 -9.8,13.94 -7.56,-0.46 -17.9,35.02 -6.46,22.19 -4.34,2.56 -2.86,25.7 1.8,28.19 7.67,7.91 15.28,46.71z';
  static const String _bottomPathData =
      'M2565.64 6072.81c21.49,2.41 326.57,138.09 394.17,163.79 139.84,53.17 291.59,90.31 439.5,122.82 887.53,195.03 1887.46,154.49 2745.75,-144.41 76.14,-26.52 142.95,-64.3 217.48,-84.24 64.2,-51.6 554.26,-255.08 898.09,-640.45 285.25,-319.73 392.79,-433.27 594.17,-941.55 73.39,-185.26 193.77,-636.41 183.37,-839.79l3.75 -49.93c-37.99,32.72 -8.4,3.46 -45.19,25.32 -40.22,23.9 -22.65,1.53 -29.26,29.39l-70.21 435.93c-123.96,478.26 -325.77,922.01 -674.98,1266.93 -90.92,89.8 -127.43,142.11 -233.31,223.88 -23.04,17.79 -28,17.09 -54.67,39.44 -67.05,56.18 -191.3,148.94 -270.06,189.44 -64.98,43.57 -134.08,81.85 -207.57,119.18 -119.23,104.26 -619.96,242.83 -812.67,296.19 -84.69,29.9 -324.45,57.79 -429.3,70.57 -152.44,18.57 -306.63,26.7 -462.18,31.93 -107.73,4.41 -758.08,11.01 -881.41,-32.15 -2.24,-0.78 -7.14,-0.41 -8.72,-4.26 -1.56,-3.8 -5.83,-2.69 -8.43,-4.54 -90.97,13.32 -204.72,-23.6 -297.94,-36.65 -81.03,-11.34 -219.51,-23.07 -275.69,-68.54 -152.67,6.35 -581.8,-201.41 -693.82,-258.72 -58.66,-23.12 -253.14,-136.48 -275.74,-173.67 -58.82,-24.53 -141.89,-95.18 -202.6,-138.83l-116.67 -105.38c-60.22,-55.17 -90.87,-65.22 -167.4,-149.06l-197.13 -236.66c-73.07,-101.63 -107.3,-171.51 -168.96,-271.65 -179.12,-321.38 -332.53,-800.71 -353.63,-1192.98l-73.15 -63.61c-9.42,506.68 245.47,1176.99 481.4,1501.78l164.3 210.51c29.21,37.15 26.34,27.82 58.02,58.93 43.8,43.01 70.77,84.25 118.51,128.14l264.25 228.04c110.47,85.24 434.39,278.59 447.95,294.89z';

  static final Path _baseBowlPath = _buildBasePath();

  static _BowlPath bowlForSize(Size size) {
    final scaleX = size.width / _viewBox.width;
    final scaleY = size.height / _viewBox.height;
    final scaled = _baseBowlPath.transform((Matrix4.identity()..scale(scaleX, scaleY)).storage);
    return _BowlPath(scaled, scaled.getBounds());
  }

  static Path _buildBasePath() {
    final rim = parseSvgPathData(_rimPathData);
    final bottom = parseSvgPathData(_bottomPathData);
    final rimPoints = _samplePath(rim, 160);
    final bottomPoints = _samplePath(bottom, 200);
    if (rimPoints.isEmpty || bottomPoints.isEmpty) {
      return Path();
    }

    final rimLeft = _indexOfMinX(rimPoints);
    final rimRight = _indexOfMaxX(rimPoints);
    final bottomLeft = _indexOfMinX(bottomPoints);
    final bottomRight = _indexOfMaxX(bottomPoints);

    final rimChain = _chain(rimPoints, rimLeft, rimRight);
    final bottomChain = _chain(bottomPoints, bottomRight, bottomLeft);
    final points = [...rimChain, ...bottomChain];

    final bowlPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      bowlPath.lineTo(point.dx, point.dy);
    }
    bowlPath
      ..close()
      ..fillType = PathFillType.nonZero;
    return bowlPath;
  }

  static List<Offset> _samplePath(Path path, int count) {
    if (count <= 0) return const [];
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return const [];
    final totalLength = metrics.fold<double>(0, (sum, metric) => sum + metric.length);
    if (totalLength == 0) return const [];

    final points = <Offset>[];
    for (var i = 0; i <= count; i++) {
      final distance = totalLength * (i / count);
      var remaining = distance;
      for (final metric in metrics) {
        if (remaining <= metric.length) {
          final tangent = metric.getTangentForOffset(remaining);
          if (tangent != null) {
            points.add(tangent.position);
          }
          break;
        }
        remaining -= metric.length;
      }
    }
    return points;
  }

  static int _indexOfMinX(List<Offset> points) {
    var minX = double.infinity;
    var index = 0;
    for (var i = 0; i < points.length; i++) {
      if (points[i].dx < minX) {
        minX = points[i].dx;
        index = i;
      }
    }
    return index;
  }

  static int _indexOfMaxX(List<Offset> points) {
    var maxX = -double.infinity;
    var index = 0;
    for (var i = 0; i < points.length; i++) {
      if (points[i].dx > maxX) {
        maxX = points[i].dx;
        index = i;
      }
    }
    return index;
  }

  static List<Offset> _chain(List<Offset> points, int start, int end) {
    if (points.isEmpty) return const [];
    if (start <= end) return points.sublist(start, end + 1);
    return [...points.sublist(start), ...points.sublist(0, end + 1)];
  }
}

class _BowlPath {
  final Path path;
  final Rect bounds;
  const _BowlPath(this.path, this.bounds);
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

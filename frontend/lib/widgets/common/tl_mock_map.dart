import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TLMockMap extends StatefulWidget {
  final double? height;
  final double? width;
  final bool showZoomControls;
  final double initialZoom;
  final double latitude;
  final double longitude;

  const TLMockMap({
    super.key,
    this.height,
    this.width,
    this.showZoomControls = true,
    this.initialZoom = 1.0,
    this.latitude = 47.6062,
    this.longitude = -122.3321,
  });

  @override
  State<TLMockMap> createState() => _TLMockMapState();
}

class _TLMockMapState extends State<TLMockMap> with SingleTickerProviderStateMixin {
  late Offset _offset;
  late double _zoom;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _offset = Offset.zero;
    _zoom = widget.initialZoom;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 4.0, end: 18.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _zoom = math.min(_zoom + 0.25, 2.5);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = math.max(_zoom - 0.25, 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: const Color(0xFFF4F3F0), // Beautiful warm map canvas color
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Gesture Detector for Interactive Map Panning ────────────────
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // Adjust pan sensitivity based on zoom level
                _offset += details.delta / _zoom;
              });
            },
            child: ClipRect(
              child: CustomPaint(
                size: Size.infinite,
                painter: _MapPainter(
                  offset: _offset,
                  zoom: _zoom,
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                ),
              ),
            ),
          ),

          // ── Pulsing User Location Marker at Map Center ──────────────────
          Center(
            child: Transform.translate(
              offset: _offset * _zoom,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing outer shadow ring
                      Container(
                        width: _pulseAnimation.value * 2.5,
                        height: _pulseAnimation.value * 2.5,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Steady inner ring
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Core blue dot
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      // White border ring for contrast
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Glassmorphic Zoom Controls ─────────────────────────────────
          if (widget.showZoomControls)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_rounded, color: AppColors.primary, size: w * 0.05),
                      onPressed: _zoomIn,
                      tooltip: 'Zoom In',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(10),
                    ),
                    Container(height: 1, width: 24, color: AppColors.border),
                    IconButton(
                      icon: Icon(Icons.remove_rounded, color: AppColors.primary, size: w * 0.05),
                      onPressed: _zoomOut,
                      tooltip: 'Zoom Out',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(10),
                    ),
                  ],
                ),
              ),
            ),

          // ── Map Badge Label ("Offline Map Mode") ───────────────────────
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    'Preview Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.026,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Offset offset;
  final double zoom;
  final double latitude;
  final double longitude;

  _MapPainter({
    required this.offset,
    required this.zoom,
    required this.latitude,
    required this.longitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Apply scaling and translation for the map elements
    canvas.save();
    canvas.translate(center.dx + offset.dx * zoom, center.dy + offset.dy * zoom);
    canvas.scale(zoom);

    final Paint waterPaint = Paint()..color = const Color(0xFFA5C9EB);
    final Paint parkPaint = Paint()..color = const Color(0xFFC2E2B8);
    final Paint buildingPaint = Paint()..color = const Color(0xFFEBE9E4);
    final Paint highwayPaint = Paint()
      ..color = const Color(0xFFFFFDF2)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint highwayBorderPaint = Paint()
      ..color = const Color(0xFFE5D5C5)
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint streetBorderPaint = Paint()
      ..color = const Color(0xFFE2DFD8)
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // ── 1. Draw Green Parks (Background details) ───────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-300, -250, 160, 220),
        const Radius.circular(20),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(180, 100, 200, 180),
        const Radius.circular(20),
      ),
      parkPaint,
    );
    canvas.drawOval(
      const Rect.fromLTWH(-400, 200, 250, 150),
      parkPaint,
    );

    // ── 2. Draw Water Bodies (Lake/River) ──────────────────────────
    final Path riverPath = Path()
      ..moveTo(-500, -350)
      ..cubicTo(-200, -300, -100, -100, -250, 100)
      ..cubicTo(-350, 250, -200, 400, -100, 500);
    canvas.drawPath(
      riverPath,
      Paint()
        ..color = const Color(0xFFA5C9EB)
        ..strokeWidth = 55.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Also draw a nice round lake connected to it
    canvas.drawCircle(const Offset(-200, -200), 75, waterPaint);

    // ── 3. Draw Building Blocks (Simulated build environment) ─────
    final List<Rect> buildingRects = [
      const Rect.fromLTWH(60, -120, 45, 35),
      const Rect.fromLTWH(120, -130, 40, 50),
      const Rect.fromLTWH(60, -60, 50, 40),
      const Rect.fromLTWH(130, -50, 35, 30),
      const Rect.fromLTWH(80, 60, 45, 45),
      const Rect.fromLTWH(140, 70, 50, 35),
      const Rect.fromLTWH(-80, -80, 40, 40),
      const Rect.fromLTWH(-130, -70, 30, 50),
      const Rect.fromLTWH(-120, 120, 50, 40),
    ];

    for (var rect in buildingRects) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        buildingPaint,
      );
    }

    // ── 4. Draw Streets & Highways (Grid network) ─────────────────
    // Diagonal Highway
    final Path highwayPath = Path()
      ..moveTo(-600, -200)
      ..lineTo(600, 400);

    canvas.drawPath(highwayPath, highwayBorderPaint);
    canvas.drawPath(highwayPath, highwayPaint);

    // Secondary vertical & horizontal streets
    final List<Path> streetPaths = [
      // Vertical streets
      Path()..moveTo(-50, -500)..lineTo(-50, 500),
      Path()..moveTo(200, -500)..lineTo(200, 500),
      Path()..moveTo(-250, -500)..lineTo(-250, 500),
      // Horizontal streets
      Path()..moveTo(-600, -150)..lineTo(600, -150),
      Path()..moveTo(-600, 150)..lineTo(600, 150),
      Path()..moveTo(-600, -10)..lineTo(600, -10),
    ];

    for (var path in streetPaths) {
      canvas.drawPath(path, streetBorderPaint);
      canvas.drawPath(path, streetPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.zoom != zoom ||
        oldDelegate.latitude != latitude ||
        oldDelegate.longitude != longitude;
  }
}

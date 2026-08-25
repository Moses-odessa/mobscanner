import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../scanner/data/image_processor.dart' as proc;

/// Arguments for the isolate performing the perspective warp.
class _WarpArgs {
  _WarpArgs(this.bytes, this.corners);
  final Uint8List bytes;
  final List<Offset> corners; // in image pixel coordinates, TL TR BR BL
}

Uint8List _warpInIsolate(_WarpArgs args) {
  const processor = proc.ImageProcessor();
  final image = processor.decode(args.bytes);
  final q = proc.Quad(
    proc.Point(args.corners[0].dx, args.corners[0].dy),
    proc.Point(args.corners[1].dx, args.corners[1].dy),
    proc.Point(args.corners[2].dx, args.corners[2].dy),
    proc.Point(args.corners[3].dx, args.corners[3].dy),
  );
  final warped = processor.perspectiveWarp(image, q);
  return processor.encodeJpg(warped, quality: 92);
}

/// Manual perspective-crop editor: the user drags four corner handles over the
/// page photo; Done warps the enclosed quad to a flat rectangle.
class CropScreen extends StatefulWidget {
  const CropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  /// Returns the warped JPEG bytes, or null if cancelled.
  static Future<Uint8List?> open(BuildContext context, Uint8List imageBytes) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => CropScreen(imageBytes: imageBytes)),
    );
  }

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  ui.Image? _image;
  // Corner positions in image pixel coordinates: TL, TR, BR, BL.
  late List<Offset> _corners;
  int? _dragIndex;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final w = image.width.toDouble();
    final h = image.height.toDouble();
    // Start with a small inset so all four handles are visible and grabbable.
    final inset = 0.06;
    setState(() {
      _image = image;
      _corners = [
        Offset(w * inset, h * inset),
        Offset(w * (1 - inset), h * inset),
        Offset(w * (1 - inset), h * (1 - inset)),
        Offset(w * inset, h * (1 - inset)),
      ];
    });
  }

  Future<void> _apply() async {
    setState(() => _busy = true);
    final result = await compute(_warpInIsolate, _WarpArgs(widget.imageBytes, _corners));
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.actionCrop),
        actions: [
          TextButton(
            onPressed: _busy || _image == null ? null : _apply,
            child: Text(l10n.actionDone,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _image == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fitted = _fit(constraints.biggest);
                      return GestureDetector(
                        onPanStart: (d) => _onPanStart(d.localPosition, fitted),
                        onPanUpdate: (d) => _onPanUpdate(d.localPosition, fitted),
                        onPanEnd: (_) => _dragIndex = null,
                        child: CustomPaint(
                          painter: _CropPainter(
                            image: _image!,
                            corners: _corners,
                            fitted: fitted,
                          ),
                          size: constraints.biggest,
                        ),
                      );
                    },
                  ),
                ),
                if (_busy)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black54,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
    );
  }

  /// Compute how the image maps into the available canvas (contain fit).
  _FittedBox _fit(Size canvas) {
    final iw = _image!.width.toDouble();
    final ih = _image!.height.toDouble();
    final scale = (canvas.width / iw).clamp(0.0, canvas.height / ih);
    final w = iw * scale;
    final h = ih * scale;
    final offset = Offset((canvas.width - w) / 2, (canvas.height - h) / 2);
    return _FittedBox(scale: scale, offset: offset);
  }

  void _onPanStart(Offset local, _FittedBox fitted) {
    // Grab the nearest handle within a 32 px (screen) radius.
    const grabRadius = 32.0;
    double best = double.infinity;
    int? bestIndex;
    for (var i = 0; i < 4; i++) {
      final screen = fitted.toScreen(_corners[i]);
      final d = (screen - local).distance;
      if (d < grabRadius && d < best) {
        best = d;
        bestIndex = i;
      }
    }
    _dragIndex = bestIndex;
  }

  void _onPanUpdate(Offset local, _FittedBox fitted) {
    final index = _dragIndex;
    if (index == null) return;
    final imagePoint = fitted.toImage(local);
    final clamped = Offset(
      imagePoint.dx.clamp(0, _image!.width.toDouble()),
      imagePoint.dy.clamp(0, _image!.height.toDouble()),
    );
    setState(() => _corners[index] = clamped);
  }
}

class _FittedBox {
  _FittedBox({required this.scale, required this.offset});
  final double scale;
  final Offset offset;

  Offset toScreen(Offset imagePoint) => imagePoint * scale + offset;
  Offset toImage(Offset screenPoint) => (screenPoint - offset) / scale;
}

class _CropPainter extends CustomPainter {
  _CropPainter({
    required this.image,
    required this.corners,
    required this.fitted,
  });

  final ui.Image image;
  final List<Offset> corners;
  final _FittedBox fitted;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the photo.
    final src = Rect.fromLTWH(
        0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromLTWH(
      fitted.offset.dx,
      fitted.offset.dy,
      image.width * fitted.scale,
      image.height * fitted.scale,
    );
    canvas.drawImageRect(image, src, dst, Paint());

    final screenCorners = corners.map(fitted.toScreen).toList();

    // Dim everything outside the selected quad.
    final overlay = Path()
      ..addRect(Offset.zero & size)
      ..addPolygon(screenCorners, true)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlay, Paint()..color = Colors.black.withValues(alpha: 0.45));

    // Quad outline.
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.lightGreenAccent;
    canvas.drawPath(Path()..addPolygon(screenCorners, true), line);

    // Corner handles.
    final handleFill = Paint()..color = Colors.white;
    final handleRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.lightGreenAccent;
    for (final c in screenCorners) {
      canvas.drawCircle(c, 10, handleFill);
      canvas.drawCircle(c, 10, handleRing);
    }
  }

  @override
  bool shouldRepaint(_CropPainter oldDelegate) =>
      oldDelegate.corners != corners ||
      oldDelegate.image != image ||
      oldDelegate.fitted.scale != fitted.scale;
}

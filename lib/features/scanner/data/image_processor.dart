import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../../core/constants.dart';

/// A quadrilateral in image pixel coordinates, ordered
/// top-left, top-right, bottom-right, bottom-left.
class Quad {
  const Quad(this.tl, this.tr, this.br, this.bl);
  final Point tl, tr, br, bl;

  List<Point> get points => [tl, tr, br, bl];
}

class Point {
  const Point(this.x, this.y);
  final double x, y;
}

/// Pure-Dart image pipeline: filters, thumbnails, perspective warp and
/// downscaling. Runs off the platform's native camera output so it works
/// identically on every platform (no native CV dependency).
///
/// Heavy calls are intended to be dispatched through `compute`/isolates by the
/// caller; the methods themselves are synchronous and side-effect free.
class ImageProcessor {
  const ImageProcessor();

  img.Image decode(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Unable to decode image');
    }
    return decoded;
  }

  Uint8List encodeJpg(img.Image image, {int quality = 85}) =>
      Uint8List.fromList(img.encodeJpg(image, quality: quality));

  /// Downscale so the largest side is <= [maxDimension], preserving aspect.
  img.Image clampSize(img.Image src, int maxDimension) {
    final longest = math.max(src.width, src.height);
    if (longest <= maxDimension) return src;
    final scale = maxDimension / longest;
    return img.copyResize(
      src,
      width: (src.width * scale).round(),
      height: (src.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
  }

  img.Image makeThumbnail(img.Image src, {int size = 320}) {
    return img.copyResize(
      src,
      width: src.width >= src.height ? size : null,
      height: src.height > src.width ? size : null,
      interpolation: img.Interpolation.average,
    );
  }

  /// Apply a named [ScanFilter] to an image.
  img.Image applyFilter(img.Image src, ScanFilter filter) {
    switch (filter) {
      case ScanFilter.original:
        return src;
      case ScanFilter.grayscale:
        return img.grayscale(src.clone());
      case ScanFilter.magic:
        return _magicColor(src.clone());
      case ScanFilter.blackWhite:
        return _adaptiveThreshold(img.grayscale(src.clone()));
    }
  }

  /// "Magic color": boost contrast & saturation and lift the white point, the
  /// signature look of document scanners for colored originals.
  img.Image _magicColor(img.Image src) {
    var out = img.adjustColor(
      src,
      contrast: 1.25,
      saturation: 1.15,
      brightness: 1.05,
    );
    out = img.normalize(out, min: 0, max: 255);
    return out;
  }

  /// Adaptive (local mean) threshold that turns a grayscale scan into crisp
  /// black text on a clean white background, tolerant of uneven lighting.
  img.Image _adaptiveThreshold(
    img.Image gray, {
    int window = 15,
    int c = 10,
  }) {
    final w = gray.width;
    final h = gray.height;
    // Build an integral image for O(1) window means.
    final integral = List<int>.filled((w + 1) * (h + 1), 0);
    int lum(int x, int y) => img.getLuminance(gray.getPixel(x, y)).round();
    for (var y = 0; y < h; y++) {
      var rowSum = 0;
      for (var x = 0; x < w; x++) {
        rowSum += lum(x, y);
        integral[(y + 1) * (w + 1) + (x + 1)] =
            integral[y * (w + 1) + (x + 1)] + rowSum;
      }
    }
    final radius = window ~/ 2;
    final out = img.Image(width: w, height: h);
    for (var y = 0; y < h; y++) {
      final y0 = math.max(0, y - radius);
      final y1 = math.min(h - 1, y + radius);
      for (var x = 0; x < w; x++) {
        final x0 = math.max(0, x - radius);
        final x1 = math.min(w - 1, x + radius);
        final count = (x1 - x0 + 1) * (y1 - y0 + 1);
        final sum = integral[(y1 + 1) * (w + 1) + (x1 + 1)] -
            integral[y0 * (w + 1) + (x1 + 1)] -
            integral[(y1 + 1) * (w + 1) + x0] +
            integral[y0 * (w + 1) + x0];
        final mean = sum / count;
        final value = lum(x, y);
        final on = value > (mean - c) ? 255 : 0;
        out.setPixelRgb(x, y, on, on, on);
      }
    }
    return out;
  }

  /// Warp the quadrilateral [quad] region of [src] to a rectangle of the given
  /// output size via inverse bilinear mapping — used for manual perspective
  /// correction after the user adjusts the corners.
  img.Image perspectiveWarp(img.Image src, Quad quad, {int? outWidth, int? outHeight}) {
    double dist(Point a, Point b) =>
        math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));
    final w = outWidth ??
        ((dist(quad.tl, quad.tr) + dist(quad.bl, quad.br)) / 2).round();
    final h = outHeight ??
        ((dist(quad.tl, quad.bl) + dist(quad.tr, quad.br)) / 2).round();
    final out = img.Image(width: math.max(1, w), height: math.max(1, h));

    for (var y = 0; y < h; y++) {
      final v = y / (h - 1);
      for (var x = 0; x < w; x++) {
        final u = x / (w - 1);
        // Bilinear interpolation of the four source corners.
        final sx = _lerp2(quad.tl.x, quad.tr.x, quad.bl.x, quad.br.x, u, v);
        final sy = _lerp2(quad.tl.y, quad.tr.y, quad.bl.y, quad.br.y, u, v);
        final pixel = _sampleBilinear(src, sx, sy);
        out.setPixel(x, y, pixel);
      }
    }
    return out;
  }

  double _lerp2(double a, double b, double c, double d, double u, double v) {
    final top = a + (b - a) * u;
    final bottom = c + (d - c) * u;
    return top + (bottom - top) * v;
  }

  img.Pixel _sampleBilinear(img.Image src, double x, double y) {
    final cx = x.clamp(0, src.width - 1).round();
    final cy = y.clamp(0, src.height - 1).round();
    return src.getPixel(cx, cy);
  }
}

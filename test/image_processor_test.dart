import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mobscanner/core/constants.dart';
import 'package:mobscanner/features/scanner/data/image_processor.dart';

void main() {
  const processor = ImageProcessor();

  img.Image sample({int w = 200, int h = 300}) {
    final image = img.Image(width: w, height: h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        image.setPixelRgb(x, y, (x % 256), (y % 256), 128);
      }
    }
    return image;
  }

  test('clampSize downscales oversized images preserving aspect', () {
    final src = sample(w: 4000, h: 2000);
    final out = processor.clampSize(src, 1000);
    expect(out.width, 1000);
    expect(out.height, 500);
  });

  test('clampSize leaves small images untouched', () {
    final src = sample(w: 100, h: 100);
    final out = processor.clampSize(src, 1000);
    expect(out.width, 100);
    expect(out.height, 100);
  });

  test('blackWhite filter yields a single-channel-like binary image', () {
    final out = processor.applyFilter(sample(), ScanFilter.blackWhite);
    final pixel = out.getPixel(10, 10);
    final lum = img.getLuminance(pixel);
    expect(lum == 0 || lum == 255, isTrue);
  });

  test('grayscale filter produces equal RGB channels', () {
    final out = processor.applyFilter(sample(), ScanFilter.grayscale);
    final p = out.getPixel(50, 50);
    expect(p.r, p.g);
    expect(p.g, p.b);
  });

  test('perspectiveWarp of full-frame quad returns requested size', () {
    final src = sample(w: 200, h: 300);
    final quad = Quad(
      const Point(0, 0),
      Point(src.width - 1, 0),
      Point(src.width - 1, src.height - 1),
      Point(0, src.height - 1),
    );
    final out = processor.perspectiveWarp(src, quad, outWidth: 100, outHeight: 150);
    expect(out.width, 100);
    expect(out.height, 150);
  });

  test('encodeJpg produces decodable bytes', () {
    final bytes = processor.encodeJpg(sample(), quality: 80);
    expect(bytes.isNotEmpty, isTrue);
    final decoded = img.decodeImage(bytes);
    expect(decoded, isNotNull);
  });
}

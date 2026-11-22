import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// Converts a CameraImage (Android YUV420 or iOS BGRA8888) into a small upright JPEG.
class FrameEncoder {
  /// [rotation] is the sensor orientation in degrees (0, 90, 180, 270).
  static Uint8List toJpeg(CameraImage frame, {int rotation = 0, int step = 2, int quality = 70}) {
    final w = frame.width ~/ step;
    final h = frame.height ~/ step;
    var out = img.Image(width: w, height: h);

    if (frame.format.group == ImageFormatGroup.bgra8888) {
      final plane = frame.planes[0];
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final i = (y * step) * plane.bytesPerRow + (x * step) * 4;
          out.setPixelRgb(x, y, plane.bytes[i + 2], plane.bytes[i + 1], plane.bytes[i]);
        }
      }
    } else {
      final yP = frame.planes[0], uP = frame.planes[1], vP = frame.planes[2];
      final uvRow = uP.bytesPerRow, uvPix = uP.bytesPerPixel ?? 1;
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final sx = x * step, sy = y * step;
          final yy = yP.bytes[sy * yP.bytesPerRow + sx];
          final uvIndex = (sy ~/ 2) * uvRow + (sx ~/ 2) * uvPix;
          final u = uP.bytes[uvIndex] - 128;
          final v = vP.bytes[uvIndex] - 128;
          final r = (yy + 1.402 * v).round().clamp(0, 255);
          final g = (yy - 0.344136 * u - 0.714136 * v).round().clamp(0, 255);
          final b = (yy + 1.772 * u).round().clamp(0, 255);
          out.setPixelRgb(x, y, r, g, b);
        }
      }
    }
    if (rotation != 0) out = img.copyRotate(out, angle: rotation);
    return Uint8List.fromList(img.encodeJpg(out, quality: quality));
  }
}

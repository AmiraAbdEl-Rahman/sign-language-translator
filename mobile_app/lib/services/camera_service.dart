import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  int _lastMs = 0;

  bool get ready => controller?.value.isInitialized ?? false;
  int get sensorOrientation => controller?.description.sensorOrientation ?? 0;

  Future<void> initialize() async {
    final cams = await availableCameras();
    if (cams.isEmpty) throw StateError('No camera found on this device.');
    final cam = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cams.first);
    controller = CameraController(cam, ResolutionPreset.low, enableAudio: false);
    await controller!.initialize();
  }

  /// Calls [onFrame] at most [fps] times per second.
  Future<void> startStream(void Function(CameraImage) onFrame, {int fps = 10}) async {
    final gap = 1000 ~/ fps;
    await controller!.startImageStream((img) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastMs >= gap) {
        _lastMs = now;
        onFrame(img);
      }
    });
  }

  Future<void> stopStream() async {
    if (controller?.value.isStreamingImages ?? false) await controller!.stopImageStream();
  }

  Future<void> dispose() async {
    await stopStream();
    await controller?.dispose();
    controller = null;
  }
}

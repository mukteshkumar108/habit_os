import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WebcamCaptureView extends StatefulWidget {
  final ValueChanged<String> onCaptured;
  final ValueChanged<String> onError;

  const WebcamCaptureView({
    super.key,
    required this.onCaptured,
    required this.onError,
  });

  @override
  State<WebcamCaptureView> createState() => _WebcamCaptureViewState();
}

class _WebcamCaptureViewState extends State<WebcamCaptureView> {
  web.HTMLVideoElement? _videoElement;
  web.MediaStream? _mediaStream;
  bool _isReady = false;

  Future<void> _initializeCamera(Object element) async {
    final videoElement = element as web.HTMLVideoElement;
    _videoElement = videoElement;
    videoElement.autoplay = true;
    videoElement.muted = true;
    videoElement.playsInline = true;
    videoElement.style
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'cover'
      ..borderRadius = '16px';

    try {
      final constraints = web.MediaStreamConstraints(
        video: true.toJS,
        audio: false.toJS,
      );
      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(constraints)
          .toDart;
      _mediaStream = stream;
      videoElement.srcObject = stream;
      await videoElement.play().toDart;
      if (mounted) setState(() => _isReady = true);
    } catch (_) {
      widget.onError('Camera permission is needed to add daily proof.');
    }
  }

  void _capture() {
    final videoElement = _videoElement;
    if (!_isReady || videoElement == null) return;
    final width = videoElement.videoWidth;
    final height = videoElement.videoHeight;
    if (width == 0 || height == 0) {
      widget.onError('Webcam is unavailable. Use file upload instead.');
      return;
    }

    final canvas = web.HTMLCanvasElement()
      ..width = width
      ..height = height;
    final context = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    context.drawImage(videoElement, 0, 0, width, height);
    widget.onCaptured(canvas.toDataURL('image/jpeg', 0.82.toJS));
  }

  @override
  void dispose() {
    final stream = _mediaStream;
    if (stream != null) {
      for (final track in stream.getTracks().toDart) {
        track.stop();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                HtmlElementView.fromTagName(
                  tagName: 'video',
                  onElementCreated: _initializeCamera,
                ),
                if (!_isReady)
                  ColoredBox(
                    color: AppColors.surfaceContainerHigh,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isReady ? _capture : null,
            icon: const Icon(Icons.camera_alt_rounded),
            label: Text('Capture Proof', style: AppTypography.headlineMd),
          ),
        ),
      ],
    );
  }
}

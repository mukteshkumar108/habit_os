import 'package:flutter/material.dart';

class WebcamCaptureView extends StatelessWidget {
  final ValueChanged<String> onCaptured;
  final ValueChanged<String> onError;

  const WebcamCaptureView({
    super.key,
    required this.onCaptured,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

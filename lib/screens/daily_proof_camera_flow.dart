import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/proof_memory_model.dart';
import '../services/proof_image_storage.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/animated_create_task_button.dart';
import '../widgets/proof_image.dart';
import '../widgets/webcam_capture_view.dart';

class DailyProofCameraFlow extends StatefulWidget {
  final String projectId;
  final String projectName;

  const DailyProofCameraFlow({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<DailyProofCameraFlow> createState() => _DailyProofCameraFlowState();
}

class _DailyProofCameraFlowState extends State<DailyProofCameraFlow> {
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String? _imageReference;
  ProofSourceType? _sourceType;
  String? _errorMessage;
  bool _isOpeningCamera = false;
  bool _isSaving = false;
  bool _showSuccess = false;
  bool _proofCommitted = false;
  bool _availabilityChecked = false;
  bool _alreadyHasProofToday = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareProofFlow());
  }

  Future<void> _prepareProofFlow() async {
    if (!mounted) return;
    final alreadyAdded = context.read<AppState>().hasProofToday(
      widget.projectId,
    );
    setState(() {
      _availabilityChecked = true;
      _alreadyHasProofToday = alreadyAdded;
    });
    if (!alreadyAdded && !kIsWeb) await _captureFromCamera();
  }

  @override
  void dispose() {
    final imageReference = _imageReference;
    if (!_proofCommitted && imageReference != null) {
      unawaited(ProofImageStorage.deleteReference(imageReference));
    }
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    if (_isOpeningCamera) return;
    if (context.read<AppState>().hasProofToday(widget.projectId)) {
      await _blockDuplicateProof();
      return;
    }
    setState(() {
      _isOpeningCamera = true;
      _errorMessage = null;
    });
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 82,
      );
      if (image != null) {
        await _storePickedImage(image, ProofSourceType.camera);
      }
    } on PlatformException catch (error) {
      _handleCameraError(error);
    } catch (_) {
      _setError('Camera permission is needed to add daily proof.');
    } finally {
      if (mounted) setState(() => _isOpeningCamera = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (context.read<AppState>().hasProofToday(widget.projectId)) {
      await _blockDuplicateProof();
      return;
    }
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 82,
      );
      if (image != null) {
        await _storePickedImage(
          image,
          kIsWeb ? ProofSourceType.fileUpload : ProofSourceType.gallery,
        );
      }
    } catch (_) {
      _setError('Unable to open photo upload. Please try again.');
    }
  }

  Future<void> _storePickedImage(
    XFile image,
    ProofSourceType sourceType,
  ) async {
    final oldReference = _imageReference;
    final storedReference = await ProofImageStorage.persistXFile(image);
    if (oldReference != null) {
      unawaited(ProofImageStorage.deleteReference(oldReference));
    }
    if (!mounted) {
      await ProofImageStorage.deleteReference(storedReference);
      return;
    }
    setState(() {
      _imageReference = storedReference;
      _sourceType = sourceType;
      _errorMessage = null;
    });
  }

  void _handleWebCapture(String dataUrl) {
    if (context.read<AppState>().hasProofToday(widget.projectId)) {
      unawaited(_blockDuplicateProof());
      return;
    }
    setState(() {
      _imageReference = dataUrl;
      _sourceType = ProofSourceType.webcam;
      _errorMessage = null;
    });
  }

  void _handleCameraError(PlatformException error) {
    final permissionDenied =
        error.code.contains('denied') || error.code.contains('access');
    _setError(
      permissionDenied
          ? 'Camera permission is needed to add daily proof.'
          : 'Camera is unavailable. Use photo upload instead.',
    );
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
  }

  Future<void> _retake() async {
    if (_alreadyHasProofToday) return;
    final oldReference = _imageReference;
    if (oldReference != null) {
      await ProofImageStorage.deleteReference(oldReference);
    }
    if (!mounted) return;
    setState(() {
      _imageReference = null;
      _sourceType = null;
      _errorMessage = null;
    });
    if (!kIsWeb) await _captureFromCamera();
  }

  Future<void> _saveProof() async {
    final reference = _imageReference;
    final sourceType = _sourceType;
    if (reference == null || sourceType == null || _isSaving) return;
    if (context.read<AppState>().hasProofToday(widget.projectId)) {
      await _blockDuplicateProof();
      return;
    }
    setState(() => _isSaving = true);
    final now = DateTime.now();
    try {
      final saved = await context.read<AppState>().addProofMemory(
        ProofMemoryModel(
          proofId: now.microsecondsSinceEpoch.toString(),
          projectId: widget.projectId,
          projectName: widget.projectName,
          imageReference: reference,
          note: _noteController.text.trim(),
          createdAt: now,
          sourceType: sourceType,
        ),
      );
      if (!saved) {
        await _blockDuplicateProof();
        return;
      }
      _proofCommitted = true;
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Unable to save proof. Please try again.';
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _showSuccess = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _blockDuplicateProof() async {
    final pendingReference = _proofCommitted ? null : _imageReference;
    if (pendingReference != null) {
      await ProofImageStorage.deleteReference(pendingReference);
    }
    if (!mounted) return;
    setState(() {
      _availabilityChecked = true;
      _alreadyHasProofToday = true;
      _imageReference = null;
      _sourceType = null;
      _isOpeningCamera = false;
      _isSaving = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Daily Proof', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          child: !_availabilityChecked
              ? const Center(
                  key: ValueKey('proof-availability'),
                  child: CircularProgressIndicator(),
                )
              : _alreadyHasProofToday
              ? _buildAlreadyAddedState()
              : _showSuccess
              ? _buildSuccessState()
              : SingleChildScrollView(
                  key: const ValueKey('proof-form'),
                  padding: const EdgeInsets.all(AppSpacing.containerMargin),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.projectName,
                            style: AppTypography.headlineLg,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add visible proof of the work you did today.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_imageReference != null)
                            _buildCapturedPreview()
                          else if (kIsWeb)
                            WebcamCaptureView(
                              onCaptured: _handleWebCapture,
                              onError: _setError,
                            )
                          else
                            _buildNativeCameraState(),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.errorRed,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _pickFromGallery,
                            icon: const Icon(Icons.upload_file_rounded),
                            label: Text(
                              kIsWeb
                                  ? 'Upload Proof Photo'
                                  : 'Choose from Gallery',
                            ),
                          ),
                          if (_imageReference != null) ...[
                            const SizedBox(height: 22),
                            TextField(
                              controller: _noteController,
                              maxLength: 180,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Short note (optional)',
                                hintText: 'What did you work on?',
                              ),
                            ),
                            const SizedBox(height: 18),
                            AnimatedCreateTaskButton(
                              enabled: !_isSaving,
                              label: 'Save Daily Proof',
                              onPressed: _saveProof,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNativeCameraState() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Center(
        child: _isOpeningCamera
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _captureFromCamera,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Open Camera'),
              ),
      ),
    );
  }

  Widget _buildCapturedPreview() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ProofImage(imageReference: _imageReference!),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _retake,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retake'),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Center(
      key: const ValueKey('proof-success'),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.7, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.warningYellow.withAlpha(60),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.warningYellow,
                size: 52,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Proof saved. Keep the streak alive.',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyAddedState() {
    return Center(
      key: const ValueKey('proof-already-added'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceVariant, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 58,
              ),
              const SizedBox(height: 16),
              Text('Proof added today', style: AppTypography.headlineMd),
              const SizedBox(height: 8),
              Text(
                '${widget.projectName} already has today\'s proof. You can add another proof tomorrow.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/video_intro_service.dart';

/// Full-screen camera + recorder for a 15-second video introduction.
/// After recording the user can preview, re-record, or upload.
class VideoRecordScreen extends StatefulWidget {
  const VideoRecordScreen({super.key});

  @override
  State<VideoRecordScreen> createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen>
    with WidgetsBindingObserver {
  // Camera
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0; // 0 = front by default if available
  bool _isCameraInitialized = false;

  // Recording
  bool _isRecording = false;
  int _remainingSeconds = 15;
  Timer? _countdownTimer;

  // Preview
  XFile? _recordedFile;
  Uint8List? _recordedBytes;
  VideoPlayerController? _previewController;
  bool _isPreviewReady = false;

  // Upload
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release camera when app goes to background
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_cameras[_selectedCameraIndex]);
    }
  }

  // ─── Camera Init ──────────────────────────────────────────────────────────

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Камера не найдена')),
          );
        }
        return;
      }
      // Prefer front camera
      _selectedCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (_selectedCameraIndex < 0) _selectedCameraIndex = 0;

      await _initCamera(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка камеры: $e')),
        );
      }
    }
  }

  Future<void> _initCamera(CameraDescription cameraDescription) async {
    _cameraController?.dispose();
    final controller = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.low : ResolutionPreset.medium,
      enableAudio: true,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _initCamera(_cameras[_selectedCameraIndex]);
  }

  // ─── Recording ────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    if (_cameraController == null || _isRecording) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _remainingSeconds = 15;
      });
      _startCountdown();
    } catch (e) {
      debugPrint('Start recording error: $e');
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _stopRecording();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _stopRecording() async {
    _countdownTimer?.cancel();
    if (_cameraController == null ||
        !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final file = await _cameraController!.stopVideoRecording();
      final bytes = await file.readAsBytes();
      setState(() {
        _isRecording = false;
        _recordedFile = file;
        _recordedBytes = bytes;
      });
      await _initPreview();
    } catch (e) {
      debugPrint('Stop recording error: $e');
      setState(() => _isRecording = false);
    }
  }

  // ─── Preview ──────────────────────────────────────────────────────────────

  Future<void> _initPreview() async {
    _previewController?.dispose();

    VideoPlayerController controller;
    if (kIsWeb) {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(_recordedFile!.path),
      );
    } else {
      controller = VideoPlayerController.file(File(_recordedFile!.path));
    }

    await controller.initialize();
    controller.setLooping(true);
    await controller.play();

    if (mounted) {
      setState(() {
        _previewController = controller;
        _isPreviewReady = true;
      });
    }
  }

  void _discardAndReRecord() {
    _previewController?.dispose();
    setState(() {
      _recordedFile = null;
      _recordedBytes = null;
      _previewController = null;
      _isPreviewReady = false;
      _remainingSeconds = 15;
    });
  }

  // ─── Upload ───────────────────────────────────────────────────────────────

  Future<void> _uploadVideo() async {
    if (_recordedBytes == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      debugPrint('Starting upload, video size: ${(_recordedBytes!.length / 1024 / 1024).toStringAsFixed(2)} MB');

      final url = await VideoIntroService().uploadIntroVideo(
        _recordedBytes!,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _uploadProgress = progress);
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Видео-визитка загружена!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(url);
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _recordedFile != null ? _buildPreviewView() : _buildCameraView(),
      ),
    );
  }

  // ── Camera view ───────────────────────────────────────────────────────────

  Widget _buildCameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        if (_isCameraInitialized && _cameraController != null)
          Center(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),

        // Top bar: close + flip + timer
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                // Timer badge
                if (_isRecording)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Макс. 15 сек',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                // Flip camera
                IconButton(
                  icon: const Icon(Icons.cameraswitch_rounded,
                      color: Colors.white, size: 28),
                  onPressed: _cameras.length > 1 ? _switchCamera : null,
                ),
              ],
            ),
          ),
        ),

        // Bottom: record button + hint
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(bottom: 32, top: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isRecording)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Нажмите для записи видео-визитки',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                // Record / Stop button
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isRecording ? 30 : 64,
                        height: _isRecording ? 30 : 64,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                              _isRecording ? 6 : 32),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isRecording)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Нажмите для остановки',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Preview view ──────────────────────────────────────────────────────────

  Widget _buildPreviewView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video preview
        if (_isPreviewReady && _previewController != null)
          Center(
            child: AspectRatio(
              aspectRatio: _previewController!.value.aspectRatio,
              child: VideoPlayer(_previewController!),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),

        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'Предпросмотр',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),

        // Bottom actions: Re-record / Upload
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: _isUploading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: _uploadProgress > 0 ? _uploadProgress : null,
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                            if (_uploadProgress > 0)
                              Text(
                                '${(_uploadProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _uploadProgress > 0
                              ? 'Загрузка видео... ${(_uploadProgress * 100).toInt()}%'
                              : 'Подготовка к загрузке...',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      // Re-record
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _discardAndReRecord,
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white),
                          label: const Text('Перезаписать',
                              style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Upload
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _uploadVideo,
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: const Text('Сохранить'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

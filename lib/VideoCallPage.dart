import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  final String contactName;

  const VideoCallPage({super.key, required this.contactName, required String phoneNumber});

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isCameraFront = true;
  bool _isVideoOn = true;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[_isCameraFront ? 1 : 0], // Front camera is index 1
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _cameraController.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _flipCamera() async {
    _isCameraFront = !_isCameraFront;
    await _initializeCamera();
  }

  void _toggleVideo() {
    setState(() {
      _isVideoOn = !_isVideoOn;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call with ${widget.contactName}'),
      ),
      body: _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      if (_isVideoOn)
                        CameraPreview(_cameraController), // Show camera feed
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.switch_camera),
                                onPressed: _flipCamera,
                              ),
                              IconButton(
                                icon: Icon(_isVideoOn
                                    ? Icons.videocam
                                    : Icons.videocam_off),
                                onPressed: _toggleVideo,
                              ),
                              IconButton(
                                icon: Icon(
                                  _isMuted ? Icons.mic_off : Icons.mic,
                                ),
                                onPressed: _toggleMute,
                              ),
                              IconButton(
                                icon: const Icon(Icons.call_end,
                                    color: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context); // End call
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}

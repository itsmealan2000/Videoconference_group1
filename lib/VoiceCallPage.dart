import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videoconference/VideoCallPage.dart';
import 'VideoCallPage.dart'; // Import your VideoCallPage here

class VoiceCallPage extends StatefulWidget {
  final String contactName;

  const VoiceCallPage({super.key, required this.contactName, required String phoneNumber});

  @override
  _VoiceCallPageState createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  bool _isMuted = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  Future<void> _startVideoCall() async {
    // Request camera and microphone permissions
    var cameraStatus = await Permission.camera.request();
    var micStatus = await Permission.microphone.request();

    // Check if both permissions are granted
    if (cameraStatus.isGranted && micStatus.isGranted) {
      // Navigate to VideoCallPage if permissions are granted
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallPage(contactName: widget.contactName, phoneNumber: '',),
        ),
      );
    } else {
      // Show a message if permissions are not granted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Camera and microphone permissions are required.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Call with ${widget.contactName}'),
      ),
      body: Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Voice calling ${widget.contactName}...',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                      onPressed: _toggleMute,
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam), // Camera button
                      onPressed: _startVideoCall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context); // End call
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

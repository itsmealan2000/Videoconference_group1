import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:videoconference/auth/meeting_service.dart'; // Import the MeetingService

class JoinMeeting extends StatefulWidget {
  final String username;
  final String email;

  const JoinMeeting({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  JoinMeetingState createState() => JoinMeetingState();
}

class JoinMeetingState extends State<JoinMeeting> {
  final MeetingService meetingService = MeetingService();
  final TextEditingController _roomCodeController = TextEditingController();
  bool isAudioMuted = true;
  bool isVideoMuted = true;

  Future<void> _joinMeeting() async {
    String roomCode = _roomCodeController.text.trim();

    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room code')),
      );
      return;
    }

    // Validate the room code in Firestore
    bool roomExists = await _validateRoomCode(roomCode);
    if (!roomExists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
       const  SnackBar(content: Text('Meeting does not exist')),
      );
      return;
    }

    try {
      await meetingService.createMeeting(
        roomCode: roomCode,
        username: widget.username,
        email: widget.email,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join meeting: $e')),
      );
    }
  }

  Future<bool> _validateRoomCode(String roomCode) async {
    try {
      // Reference to Firestore
      CollectionReference meetings =
          FirebaseFirestore.instance.collection('meetings');

      // Query to check if the room code exists
      QuerySnapshot querySnapshot =
          await meetings.where('roomCode', isEqualTo: roomCode).get();

      // Return true if the room code exists
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw ("Error validating room code: $e");
    }
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: const Text('Join Meeting')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _roomCodeController,
              decoration: const InputDecoration(labelText: 'Room Code'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    isAudioMuted ? Icons.mic_off : Icons.mic,
                    color: isAudioMuted ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      isAudioMuted = !isAudioMuted;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    isVideoMuted ? Icons.videocam_off : Icons.videocam,
                    color: isVideoMuted ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      isVideoMuted = !isVideoMuted;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinMeeting,
              child: const Text('Join Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}

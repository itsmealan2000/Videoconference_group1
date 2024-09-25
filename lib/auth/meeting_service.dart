import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingService {
  final CollectionReference meetingCollection = FirebaseFirestore.instance.collection('meetings');

  // Create a new meeting
  Future<void> createMeeting({
    required String roomCode,
    required String username,
    required String email,
  }) async {
    try {
      var jitsiMeet = JitsiMeet();
      var options = JitsiMeetConferenceOptions(
        serverURL: "https://jitsi.rptu.de/",
        room: roomCode,
        configOverrides: {
          'startWithAudioMuted': true,
          'startWithVideoMuted': true,
        },
        featureFlags: {
          FeatureFlags.welcomePageEnabled: false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: username,
          email: email,
        ),
      );

      // Save the meeting details before joining
      await saveMeeting(roomCode, email, username);

      // Join the meeting
      await jitsiMeet.join(options);
    } catch (error) {
      throw Exception('Error starting the meeting: $error');
    }
  }

  // Save meeting details to Firestore
  Future<void> saveMeeting(String roomCode, String email, String username) async {
    try {
      await meetingCollection.add({
        'roomCode': roomCode,
        'email': email,
        'username': username,
        'createdAt': Timestamp.now(),
      });
    } catch (error) {
      throw Exception('Error saving meeting: $error');
    }
  }

  // Fetch meeting history for a specific user
  Stream<QuerySnapshot> getMeetingHistory(String email) {
    return meetingCollection.where('email', isEqualTo: email).snapshots();
  }
}

import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingService {
  // Create a new meeting
  Future<void> createMeeting(
      {required String roomCode, required String username}) async {
    try {
        var jitsiMeet = JitsiMeet();
        var options = JitsiMeetConferenceOptions(room: roomCode);
        jitsiMeet.join(options);
    } catch (error) {
      throw Exception('Error starting the meeting: $error');
    }
  }

  final CollectionReference meetingCollection = FirebaseFirestore.instance.collection('meetings');

  // Save meeting to Firestore
  Future<void> saveMeeting(String roomCode, String userId, String fullName) async {
    await meetingCollection.add({
      'roomCode': roomCode,
      'userId': userId,
      'username': fullName,
      'createdAt': Timestamp.now(),
    });
  }

  // Fetch meeting history
  Stream<QuerySnapshot> getMeetingHistory(String userId) {
    return meetingCollection.where('userId', isEqualTo: userId).snapshots();
  }
}

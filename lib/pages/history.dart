import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:videoconference/components/bottomnavbar.dart'; // Import BottomNavBar

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  User? user;
  String? username; // Variable to store username
  late Future<List<Map<String, dynamic>>> _meetings;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetch current user
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _meetings = _fetchUserDetails(); // Initialize _meetings directly
    } else {
      // Handle case when user is not logged in
      _meetings = Future.value([]);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserDetails() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          setState(() {
            username =
                userDoc['fullName'] ?? user!.email; // Get full name or email
          });
          return await _fetchMeetings(); // Fetch meetings after getting username
        }
      } catch (e) {
        throw ('Error fetching user details: $e');
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchMeetings() async {
    // Ensure user is not null
    if (user == null || username == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('meetings')
          .where('username', isEqualTo: username) // Use fetched username for filtering
          .get();

      // Group meetings by roomCode and track earliest timestamp and username
      Map<String, Map<String, dynamic>> meetingsMap = {};

      for (var doc in snapshot.docs) {
        String roomCode = doc['roomCode'];
        Timestamp createdAt = doc['createdAt'];
        String meetingUsername = doc['username'];

        // Convert createdAt to DateTime for comparison
        DateTime createdAtDateTime = createdAt.toDate();

        // If roomCode is not already in the map, or if this timestamp is earlier
        if (!meetingsMap.containsKey(roomCode) ||
            (meetingsMap[roomCode]!['createdAt'] as Timestamp).toDate().isAfter(createdAtDateTime)) {
          meetingsMap[roomCode] = {
            'createdAt': createdAt,
            'username': meetingUsername,
          };
        }
      }

      // Convert the map back to a list
      List<Map<String, dynamic>> meetings = meetingsMap.entries.map((entry) {
        return {
          'roomCode': entry.key,
          'createdAt': entry.value['createdAt'],
          'username': entry.value['username'],
        };
      }).toList();

      // Sort the meetings by createdAt in descending order
      meetings.sort(
          (a, b) => (b['createdAt'] as Timestamp).compareTo(a['createdAt']));

      return meetings;
    } catch (e) {
      throw ('Error fetching meetings: $e');
    }
  }

  // Format the date manually
  String formatDate(DateTime date) {
    String hour = date.hour % 12 == 0
        ? '12'
        : (date.hour % 12).toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    String period = date.hour < 12 ? 'AM' : 'PM';

    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year} $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _meetings, // Use FutureBuilder to wait for meetings
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meeting history found.'));
          }

          final meetings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              final createdAt = (meeting['createdAt'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: ListTile(
                  leading:
                      const Icon(Icons.video_call, color: Colors.blueAccent),
                  title: Text(
                    meeting['roomCode'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    '${meeting['username']} - ${formatDate(createdAt.toLocal())}', // Display formatted meeting details
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createUser(String name, String email) async {
    try {
      DocumentReference ref = await _firestore.collection('users').add({
        'name': name,
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage(String userId, String messageText,
      {bool fromChatbot = false}) async {
        await _firestore
        .collection('user_chats')
        .doc(userId)
        .collection('messages')
        .add({
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'fromChatbot': fromChatbot,
    });
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Stream<List<DocumentSnapshot>> messagesStream(String userId,
      {int limit = 20}) {
    return _firestore
        .collection('user_chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}

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

  Future<void> sendMessage(String userId, String messageText) async {
    await _firestore
        .collection('user_chats')
        .doc(userId)
        .collection('messages')
        .add({
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });
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

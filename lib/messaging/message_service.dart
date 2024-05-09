import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingService {
  // Fetch messages between two users
  Stream<QuerySnapshot> getMessages({
    required String senderUserId,
    required String receiverUserId,
  }) {
    try {
      String conversationId =
          generateConversationId(senderUserId, receiverUserId);
      // Fetch messages from the Messages subcollection under the conversation document
      return FirebaseFirestore.instance
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting messages: $e');
      throw e;
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String senderUserId,
    required String receiverUserId,
    required String message,
  }) async {
    try {
      String conversationId =
          generateConversationId(senderUserId, receiverUserId);
      await FirebaseFirestore.instance
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .add({
        'senderUserId': senderUserId,
        'receiverUserId': receiverUserId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'seen':false
      });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(receiverUserId)
          .collection('Conversations')
          .doc(conversationId)
          .set({
        'conversationId': conversationId,
        'receiverUserId': receiverUserId,
        'senderUserId': senderUserId,
      });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(senderUserId)
          .collection('Conversations')
          .doc(conversationId)
          .set({
        'conversationId': conversationId,
        'receiverUserId': receiverUserId,
        'senderUserId': senderUserId, // Add sender's ID
      });
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  // Generate conversation ID
  String generateConversationId(String senderUserId, String receiverUserId) {
    List<String> userIds = [senderUserId, receiverUserId]..sort();
    return '${userIds[0]}_${userIds[1]}';
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch messages between two users
  Stream<QuerySnapshot> getMessages({
    required String senderUserId,
    required String receiverUserId,
  }) {
    try {
      String conversationId =
          generateConversationId(senderUserId, receiverUserId);
      // Fetch messages from the Messages subcollection under the conversation document
      return _firestore
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .orderBy('timestamp', descending: false)
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

      // Check if sender is allowed to send a message
      bool CanSendMessage = await canSendMessage(senderUserId, receiverUserId);

      if (!CanSendMessage) {
        throw Exception("You can't send more than one message until you are followed.");
      }

      await _firestore
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .add({
        'senderUserId': senderUserId,
        'receiverUserId': receiverUserId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
      });

      await _firestore
          .collection('Users')
          .doc(receiverUserId)
          .collection('Conversations')
          .doc(conversationId)
          .set({
        'conversationId': conversationId,
        'receiverUserId': receiverUserId,
        'senderUserId': senderUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('Users')
          .doc(senderUserId)
          .collection('Conversations')
          .doc(conversationId)
          .set({
        'conversationId': conversationId,
        'receiverUserId': receiverUserId,
        'senderUserId': senderUserId,
        'timestamp': FieldValue.serverTimestamp(), // Add sender's ID
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

  // Check if sender is followed by receiver
  Future<bool> isFollowing(String senderUserId, String receiverUserId) async {
    final doc = await _firestore
        .collection('Users')
        .doc(receiverUserId)
        .collection('Supportings')
        .doc(senderUserId)
        .get();
    return doc.exists;
  }

  // Count messages sent by sender to receiver
  Future<int> countMessages(String senderUserId, String receiverUserId) async {
    String conversationId = generateConversationId(senderUserId, receiverUserId);
    final querySnapshot = await _firestore
        .collection('Conversations')
        .doc(conversationId)
        .collection('Messages')
        .where('senderUserId', isEqualTo: senderUserId)
        .get();
    return querySnapshot.docs.length;
  }

  // Check if sender can send a message
  Future<bool> canSendMessage(String senderUserId, String receiverUserId) async {
    bool isFollowed = await isFollowing(senderUserId, receiverUserId);
    if (isFollowed) {
      return true;
    } else {
      int messageCount = await countMessages(senderUserId, receiverUserId);
      return messageCount < 1;
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId, String conversationId) async {
    try {
      await _firestore
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
      throw e;
    }
  }
}

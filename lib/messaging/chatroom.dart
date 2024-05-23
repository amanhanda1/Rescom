import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resapp/messaging/message_service.dart';
import 'package:resapp/pages/Profile_page.dart';

class ChatRoomPage extends StatefulWidget {
  final String senderUserId;
  final String receiverUserId;

  const ChatRoomPage({
    Key? key,
    required this.senderUserId,
    required this.receiverUserId,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  String _receiverUsername = '';
  bool _isHovering = false;
  bool _canSendMessage = true;
  final MessagingService _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    _fetchReceiverUsername();
    _checkMessagePermission();
  }

  Future<void> _fetchReceiverUsername() async {
    final DocumentSnapshot receiverSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.receiverUserId)
        .get();

    if (receiverSnapshot.exists) {
      setState(() {
        _receiverUsername = receiverSnapshot['username'];
      });
    }
  }

  Future<void> _checkMessagePermission() async {
    try {
      bool canSendMessage = await _messagingService.canSendMessage(
          widget.senderUserId, widget.receiverUserId);
      setState(() {
        _canSendMessage = canSendMessage;
      });
    } catch (e) {
      print('Error checking message permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    void navigateToEventPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: widget.receiverUserId),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,color: const Color.fromARGB(255, 255, 240, 223),),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _isHovering
                      ? Colors.orange
                      : Color.fromARGB(0, 250, 248, 248),
                  borderRadius:
                      BorderRadius.circular(8.0), // adjust the radius as needed
                ),
                child: ElevatedButton(
                  onPressed: navigateToEventPage,
                  onHover: (isHovering) {
                    setState(() {
                      _isHovering = isHovering;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isHovering
                        ? Colors.orange
                        : Color.fromARGB(0, 250, 248,
                            248), // set the button background to transparent
                    elevation: 0, // Remove elevation
                  ),
                  child: Text(
                    _receiverUsername.toUpperCase() + ' >',
                    style: const TextStyle(fontSize: 22, color: const Color.fromARGB(255, 255, 240, 223)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagingService.getMessages(
                senderUserId: widget.senderUserId,
                receiverUserId: widget.receiverUserId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final String message = messageData['message'];
                    final String senderUserId = messageData['senderUserId'];

                    // Determine if the message is from the sender or receiver
                    final bool isSenderMessage =
                        senderUserId == widget.senderUserId;

                    return ListTile(
                      title: Align(
                        alignment: isSenderMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSenderMessage ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: GestureDetector(
                            onLongPress: () {},
                            child: Text(
                              message,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _canSendMessage
                          ? 'Type your message...'
                          : 'You can only send one message before they follow you',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 240, 223),
                      ),
                    ),
                    style: const TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
                    enabled: _canSendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,color: const Color.fromARGB(255, 255, 240, 223)),
                  onPressed: _canSendMessage
                      ? () async {
                          final String message = _messageController.text.trim();
                          if (message.isNotEmpty) {
                            try {
                              await _messagingService.sendMessage(
                                senderUserId: widget.senderUserId,
                                receiverUserId: widget.receiverUserId,
                                message: message,
                              );
                              _messageController.clear();
                              _checkMessagePermission(); // Recheck permission after sending message
                            } catch (e) {
                              print('Error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error: You can\'t send more than one message until you are followed.'),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

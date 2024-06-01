import 'package:flutter/material.dart';

class cNavigationBar extends StatefulWidget {
  final VoidCallback onProfileIconPressed;
  final VoidCallback onHomePressed;
  final VoidCallback onAdduserPressed;
  final VoidCallback onChatPressed;

  const cNavigationBar({
    Key? key,
    required this.onProfileIconPressed,
    required this.onHomePressed,
    required this.onAdduserPressed,
    required this.onChatPressed,
  }) : super(key: key);

  @override
  cNavigationBarState createState() => cNavigationBarState();
}

class cNavigationBarState extends State<cNavigationBar> {
  bool _hasNewMessage = false; // Track if there is a new message

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 200,
      color: const Color.fromARGB(255, 26, 24, 46),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.home_filled,
                color: Color.fromARGB(255, 255, 240, 223)),
            onPressed: widget.onHomePressed,
          ),
          IconButton(
            icon: const Icon(Icons.group_add_outlined,
                color: Color.fromARGB(255, 255, 240, 223)),
            onPressed: widget.onAdduserPressed,
          ),
          Stack(
            children: [
              IconButton(
                onPressed: widget.onChatPressed,
                icon: const Icon(Icons.message_outlined,
                    color: Color.fromARGB(255, 255, 240, 223)),
              ),
              if (_hasNewMessage)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person,
                color: Color.fromARGB(255, 255, 240, 223)),
            onPressed: widget.onProfileIconPressed,
          ),
        ],
      ),
    );
  }

  void setNewMessageStatus(bool hasNewMessage) {
    setState(() {
      _hasNewMessage = hasNewMessage;
    });
  }
}

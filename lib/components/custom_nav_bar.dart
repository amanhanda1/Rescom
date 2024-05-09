import 'package:flutter/material.dart';

class cNavigationBar extends StatelessWidget {
  final VoidCallback onProfileIconPressed;
  final VoidCallback onHomePressed;
  final VoidCallback onAdduserPressed;
  final VoidCallback onChatPressed;

  cNavigationBar({
    required this.onProfileIconPressed,
    required this.onHomePressed,
    required this.onAdduserPressed,
    required this.onChatPressed,
  });

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
            icon: const Icon(Icons.home_filled,color: Color.fromARGB(255, 255, 240, 223)),
                onPressed: onHomePressed,
          ),
          IconButton(
            icon: const Icon(Icons.group_add_outlined,color: Color.fromARGB(255, 255, 240, 223)),
            onPressed: onAdduserPressed,
          ),
          IconButton(
            onPressed: onChatPressed,
            icon: Icon(Icons.message_outlined,color: Color.fromARGB(255, 255, 240, 223)),
          ),
          IconButton(
            icon: const Icon(Icons.person,color: Color.fromARGB(255, 255, 240, 223)),
            onPressed: onProfileIconPressed,
          ),
        ],
      ),
    );
  }
}
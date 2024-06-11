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

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 200,
      color: const Color.fromARGB(255, 26, 24, 46),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
  Tooltip(
    message: 'Home',
    child: IconButton(
      icon: const Icon(Icons.home_filled,
          color: Color.fromARGB(255, 255, 240, 223)),
      onPressed: widget.onHomePressed,
    ),
  ),
  Tooltip(
    message: 'Find User',
    child: IconButton(
      icon: const Icon(Icons.group_add_outlined,
          color: Color.fromARGB(255, 255, 240, 223)),
      onPressed: widget.onAdduserPressed,
    ),
  ),
  Tooltip(
    message: 'Chat',
    child: IconButton(
      icon: const Icon(Icons.message_outlined,
          color: Color.fromARGB(255, 255, 240, 223)),
      onPressed: widget.onChatPressed,
    ),
  ),
  Tooltip(
    message: 'Profile',
    child: IconButton(
      icon: const Icon(Icons.person,
          color: Color.fromARGB(255, 255, 240, 223)),
      onPressed: widget.onProfileIconPressed,
    ),
  ),
],
      ),
    );
  }
}

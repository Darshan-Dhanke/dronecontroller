import 'package:flutter/material.dart';

class WifiStatusIcon extends StatelessWidget {
  final bool connected;
  final VoidCallback onTap;
  const WifiStatusIcon({super.key, required this.connected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.wifi,
        color: connected ? Colors.green : Colors.red,
      ),
      onPressed: onTap,
    );
  }
}
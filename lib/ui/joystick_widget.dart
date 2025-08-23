import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class JoystickWidget extends StatelessWidget {
  final Function(double, double) onChanged;
  const JoystickWidget({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Joystick(
      mode: JoystickMode.all,
      listener: (details) {
        if (!details.x.isNaN && !details.y.isNaN) {
          onChanged(details.x, details.y);
        }
      },
      base: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[400],
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
        ),
      ),
      stick: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue[400],
        ),
      ),
    );
  }
}
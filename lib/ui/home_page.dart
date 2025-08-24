import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import '../services/connectivity_service.dart';
import '../services/udp_service.dart';
import 'wifi_status_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool wifiConnected = false;

  // Joystick state (kept locally as well; UdpService sends periodically)
  double leftX = 0.0, leftY = 0.0, rightX = 0.0, rightY = 0.0;

  StreamSubscription<bool>? _wifiSub;
  late final UdpService _udpService;

  @override
  void initState() {
    super.initState();

    // Configure the UDP service once
    _udpService = UdpService(
      targetIp: '192.168.4.1', // ESP32 AP IP
      targetPort: 4210,
      period: const Duration(milliseconds: 100), // adjust rate as needed
    );

    // Listen to Wi-Fi connectivity and start/stop sending accordingly
    _wifiSub = ConnectivityService().wifiConnectedStream().listen((connected) async {
      if (!mounted) return;
      setState(() => wifiConnected = connected);

      if (connected) {
        _udpService.stop();
        await _udpService.init();
        _udpService.start();
      } else {
        _udpService.stop();
      }
    });
  }

  @override
  void dispose() {
    _wifiSub?.cancel();
    _udpService.dispose();
    super.dispose();
  }

  Future<void> _checkWifi() async {
    final connected = await ConnectivityService().isWifiConnected();
    if (!mounted) return;
    setState(() => wifiConnected = connected);

    if (connected) {
      _udpService.stop();
      await _udpService.init();
      _udpService.start();
    } else {
      _udpService.stop();
    }
  }

  void _onLeftJoystickMove(double x, double y) {
    if (x.isNaN || y.isNaN) return;
    leftX = x;
    leftY = y;
    _udpService.updateLeft(x, y); // feed the service
  }

  void _onRightJoystickMove(double x, double y) {
    if (x.isNaN || y.isNaN) return;
    rightX = x;
    rightY = y;
    _udpService.updateRight(x, y); // feed the service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18161D),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  const Text(
                    'Drone Controller',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  WifiStatusIcon(
                    connected: wifiConnected,
                    onTap: _checkWifi, // manual re-check
                  ),
                ],
              ),
            ),

            // Two joysticks
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Joystick(
                      mode: JoystickMode.all,
                      listener: (details) {
                        if (!details.x.isNaN && !details.y.isNaN) {
                          _onLeftJoystickMove(details.x, details.y);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Joystick(
                      mode: JoystickMode.all,
                      listener: (details) {
                        if (!details.x.isNaN && !details.y.isNaN) {
                          _onRightJoystickMove(details.x, details.y);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

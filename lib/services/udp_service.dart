import 'dart:async';
import 'dart:typed_data';
import 'package:udp/udp.dart';
import 'dart:io';

class UdpService {
  UDP? _udp;
  Timer? _timer;

  String _targetIp;
  int _targetPort;
  Duration _period;

  // latest joystick state
  double _leftX = 0.0, _leftY = 0.0, _rightX = 0.0, _rightY = 0.0;

  bool get isRunning => _timer != null;
  bool get isReady => _udp != null;

  UdpService({
    String targetIp = '192.168.4.1',
    int targetPort = 4210,
    Duration period = const Duration(milliseconds: 100),
  })  : _targetIp = targetIp,
        _targetPort = targetPort,
        _period = period;

  Future<void> init() async {
    if (_udp != null) return;
    _udp = await UDP.bind(Endpoint.any(port: Port(4210)));
  }

  Future<void> dispose() async {
    stop();
  }

  void start() {
    if (_udp == null) {
      init();
    }
    _timer ??= Timer.periodic(_period, (_) => _sendNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    try {
      _udp?.close();
    } catch (_) {}
    _udp = null;
  }

  void setTarget({required String ip, required int port}) {
    _targetIp = ip;
    _targetPort = port;
  }

  void setRate(Duration period) {
    _period = period;
    if (isRunning) {
      stop();
      start();
    }
  }

  void updateLeft(double x, double y) {
    _leftX = x;
    _leftY = y;
  }

  void updateRight(double x, double y) {
    _rightX = x;
    _rightY = y;
  }

  void _sendNow() {
    if (_udp == null) return;

    final msg =
        'x=${_leftX.toStringAsFixed(2)},y=${_leftY.toStringAsFixed(2)},'
        'z=${_rightY.toStringAsFixed(2)},w=${_rightX.toStringAsFixed(2)}';

    final bytes = Uint8List.fromList(msg.codeUnits);

    _udp!.send(
      bytes,
      Endpoint.unicast(
        InternetAddress(_targetIp),
        port: Port(_targetPort),
      ),
    );
    // print('Sent: $msg');
  }
}

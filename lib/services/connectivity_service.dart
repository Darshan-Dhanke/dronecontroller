import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Returns true if device is connected to Wi-Fi.
  /// Uses connectivity_plus first, then falls back to checking for a Wi-Fi IP.
  Future<bool> isWifiConnected() async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.wifi) return true;

    // Fallback: some Android versions report NONE for local-only Wi-Fi
    try {
      final ip = await _networkInfo.getWifiIP();
      return ip != null && ip.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Emits true/false whenever connectivity changes.
  Stream<bool> wifiConnectedStream() async* {
    // emit current state first
    yield await isWifiConnected();

    await for (final result in _connectivity.onConnectivityChanged) {
      if (result == ConnectivityResult.wifi) {
        yield true;
      } else {
        // Fallback to Wi-Fi IP check for local APs
        try {
          final ip = await _networkInfo.getWifiIP();
          yield ip != null && ip.isNotEmpty;
        } catch (_) {
          yield false;
        }
      }
    }
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:metaverse_client/core/event_bus/app_event_bus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  void handleNetworkChange(bool isConnected);
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  void handleNetworkChange(bool isConnected) {
    // 处理网络变化事件
    AppEventBus().emit(NetworkChangedEvent(isConnected));
  }
}

class NetworkChangedEvent extends AppEvent {
  final bool isConnected;

  NetworkChangedEvent(this.isConnected);
}

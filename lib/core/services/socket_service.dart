import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? socket;

  void connect(String deviceId) {
    if (socket?.connected == true) return;

    socket = io.io(ApiConstants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('Connected to Socket.io server');
      socket!.emit('join_device', deviceId);
    });

    socket!.onDisconnect((_) => print('Disconnected from Socket.io server'));
  }

  void on(String event, Function(dynamic) handler) {
    socket?.on(event, handler);
  }

  void off(String event) {
    socket?.off(event);
  }

  void disconnect() {
    socket?.disconnect();
  }
}

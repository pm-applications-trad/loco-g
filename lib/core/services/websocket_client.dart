import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:locogames/core/constants/app_constants.dart';

typedef WsMessageHandler = void Function(Map<String, dynamic> message);

class WebSocketClient {
  WebSocketChannel? _channel;
  WsMessageHandler? _onMessage;
  StreamSubscription? _subscription;

  bool get isConnected => _channel != null;

  void connect(String gameType, String roomId, String playerId, String playerName) {
    final uri = Uri.parse('${AppConstants.wsBaseUrl}/$gameType/$roomId');
    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(
      (data) {
        try {
          final decoded = jsonDecode(data as String);
          if (decoded is Map<String, dynamic>) {
            _onMessage?.call(decoded);
          }
        } catch (_) {
          _onMessage?.call({'type': 'error', 'message': 'malformed_message'});
        }
      },
      onError: (error) {
        _onMessage?.call({'type': 'error', 'message': error.toString()});
      },
      onDone: () {
        _channel = null;
        _onMessage?.call({'type': 'disconnected'});
      },
    );

    send({
      'type': 'join',
      'playerId': playerId,
      'playerName': playerName,
    });
  }

  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void onMessage(WsMessageHandler handler) {
    _onMessage = handler;
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}

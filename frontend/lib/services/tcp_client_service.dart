import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class TcpClientService {
  static const String _serverIp = '192.168.0.58';
  static const int _serverPort = 8081;
  Socket? _socket;
  Function(Map<String, dynamic>)? onMessageReceived;

  Future<bool> connect() async {
    try {
      _socket = await Socket.connect(_serverIp, _serverPort, timeout: const Duration(seconds: 5));
      debugPrint("Conectado ao Servidor TCP (Seguro)");

      _socket!.listen(
        (List<int> data) {
          final response = utf8.decode(data);
          try {
            final json = jsonDecode(response);
            if (onMessageReceived != null) {
              onMessageReceived!(json);
            }
          } catch (e) {
            debugPrint("TCP JSON parsing error: $e");
          }
        },
        onError: (error) {
          debugPrint("TCP Error: $error");
          disconnect();
        },
        onDone: () {
          debugPrint("Servidor TCP encerrou a conexão");
          disconnect();
        },
      );
      return true;
    } catch (e) {
      debugPrint("TCP Connect Error: $e");
      return false;
    }
  }

  void sendLogin(String identifier, String password) {
    if (_socket == null) return;
    
    final payload = {
      "action": "LOGIN",
      "identifier": identifier,
      "senha": password,
    };
    
    _socket!.write('${jsonEncode(payload)}\n');
  }

  void sendSync() {
    if (_socket == null) return;
    
    final payload = {
      "action": "SYNC",
    };
    
    _socket!.write('${jsonEncode(payload)}\n');
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }
}

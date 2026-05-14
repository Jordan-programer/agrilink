import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class UdpClientService {
  static const String _serverIp = '192.168.0.58'; // IP do Backend
  static const int _serverPort = 9090;

  static Future<Map<String, dynamic>?> fetchMarketPrices() async {
    RawDatagramSocket? socket;
    try {
      // Abre um socket na porta local aleatória (0)
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      
      final serverAddress = InternetAddress(_serverIp);
      final payload = utf8.encode('GET_PRICES');
      
      // Envia o ping UDP (sem confirmação de entrega) - RSC06
      socket.send(payload, serverAddress, _serverPort);

      // Espera pela resposta (timeout muito curto, porque UDP é rápido ou não chega)
      final Datagram? response = await _receiveWithTimeout(socket, const Duration(milliseconds: 1500));
      
      if (response != null) {
        final dataStr = utf8.decode(response.data);
        return jsonDecode(dataStr);
      }
    } catch (e) {
      debugPrint("Erro no UDP: $e");
    } finally {
      socket?.close();
    }
    return null;
  }

  static Future<Datagram?> _receiveWithTimeout(RawDatagramSocket socket, Duration timeout) async {
    try {
      await for (RawSocketEvent event in socket.timeout(timeout)) {
        if (event == RawSocketEvent.read) {
          return socket.receive();
        }
      }
    } catch (e) {
      // Timeout atingido
    }
    return null;
  }
}

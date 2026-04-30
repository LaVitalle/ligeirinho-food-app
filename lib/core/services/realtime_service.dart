import 'dart:async';

class RealtimeService {
  // Placeholder stream to integrate with WebSocket/SSE provider.
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void emit(Map<String, dynamic> event) {
    _controller.add(event);
  }

  Future<void> connect() async {
    // TODO: connect to backend WebSocket/SSE endpoint when available.
  }

  Future<void> disconnect() async {
    // TODO: close real connection when implemented.
  }

  void dispose() {
    _controller.close();
  }
}

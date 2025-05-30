import 'dart:async';

class AppEvent {}

class AppEventBus {
  final _eventController = StreamController<AppEvent>.broadcast();

  Stream<T> on<T extends AppEvent>() {
    return _eventController.stream.where((event) => event is T).cast<T>();
  }

  void emit(AppEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

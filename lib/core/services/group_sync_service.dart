import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupSyncServiceProvider = Provider<GroupSyncService>((ref) {
  return GroupSyncService();
});

class GroupSyncService {
  final _controller = StreamController<String>.broadcast();
  Stream<String> get syncStream => _controller.stream;

  void sendPlaybackEvent(String eventType, String songId, int positionMs) {
    _controller.add('$eventType:$songId:$positionMs');
  }

  void dispose() {
    _controller.close();
  }
}

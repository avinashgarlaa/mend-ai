// lib/viewmodels/chat_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/services/mend_ws.dart';

final chatViewModelProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

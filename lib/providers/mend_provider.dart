import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/services/mend_service.dart';

final mendServiceProvider = Provider<MendService>((ref) {
  return MendService();
});

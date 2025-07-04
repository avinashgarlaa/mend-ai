import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/services/mend_api_service.dart';

final mendApiServiceProvider = Provider<MendApiService>((ref) {
  return MendApiService(baseUrl: 'https://mend-backend-j0qd.onrender.com/');
});

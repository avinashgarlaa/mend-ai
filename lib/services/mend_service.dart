import 'package:dio/dio.dart';

class MendService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://mend-backend-j0qd.onrender.com/api",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  // 👤 User
  Future<Response> registerUser(Map<String, dynamic> data) =>
      _dio.post('/register', data: data);

  Future<Response> loginWithCredentials(String email, String password) =>
      _dio.post('/login', data: {'email': email, 'password': password});

  Future<Response> getUser(String userId) => _dio.get('/user/$userId');

  Future<Response> invitePartner(Map<String, dynamic> data) =>
      _dio.post('/invite', data: data);

  Future<Response> acceptInvite(Map<String, dynamic> data) =>
      _dio.post('/accept-invite', data: data);

  // 📝 Onboarding
  Future<Response> submitOnboarding(Map<String, dynamic> data) =>
      _dio.post('/onboarding', data: data);

  // 🎤 Voice Session
  Future<Response> startSession(Map<String, dynamic> data) =>
      _dio.post('/session', data: data);

  Future<Response> getActiveSession(String userId) =>
      _dio.get('/session/active/$userId');

  Future<Response> endSession(String sessionId) =>
      _dio.patch('/session/end/$sessionId');

  // 🧘 Post-session
  Future<Response> submitReflection(Map<String, dynamic> data) =>
      _dio.post('/reflection', data: data);

  Future<Response> submitPostResolution(Map<String, dynamic> data) =>
      _dio.post('/post-resolution', data: data);

  Future<Response> submitScore(Map<String, dynamic> data) =>
      _dio.post('/score', data: data);

  // 📊 Insights Dashboard
  Future<Response> getInsights(String userId) => _dio.get('/insights/$userId');
}

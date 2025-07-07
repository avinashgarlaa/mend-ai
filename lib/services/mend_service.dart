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

  Future<Response> login(String email) =>
      _dio.post('/login', data: {'email': email});

  Future<Response> getUser(String userId) => _dio.get('/user/$userId');

  Future<Response> invitePartner(Map<String, dynamic> data) =>
      _dio.post('/invite', data: data);

  // 📝 Onboarding
  Future<Response> submitOnboarding(Map<String, dynamic> data) =>
      _dio.post('/onboarding', data: data);

  // 🎤 Session & Chat
  Future<Response> startSession(Map<String, dynamic> data) =>
      _dio.post('/session', data: data);

  Future<Response> moderate(Map<String, dynamic> data) =>
      _dio.post('/moderate', data: data);

  // 💬 Post-session
  Future<Response> submitReflection(Map<String, dynamic> data) =>
      _dio.post('/reflection', data: data);

  Future<Response> submitPostResolution(Map<String, dynamic> data) =>
      _dio.post('/post-resolution', data: data);

  Future<Response> submitScore(Map<String, dynamic> data) =>
      _dio.post('/score', data: data);

  // 📊 Insights
  Future<Response> getInsights(String userId) => _dio.get('/insights/$userId');
}

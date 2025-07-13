import 'package:dio/dio.dart';

class MendService {
  // Singleton
  static final MendService _instance = MendService._internal();
  factory MendService() => _instance;
  MendService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://mend-backend-j0qd.onrender.com/api",
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  Dio get client => _dio;

  // ─────────────────────────────────────────────
  // 🔐 AUTHENTICATION
  // ─────────────────────────────────────────────
  Future<Response> registerUser(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/register', data: data, cancelToken: cancelToken);

  Future<Response> loginWithCredentials(
    String email,
    String password, {
    CancelToken? cancelToken,
  }) => _dio.post(
    '/login',
    data: {'email': email, 'password': password},
    cancelToken: cancelToken,
  );

  Future<Response> loginWithGoogle(
    Map<String, dynamic> payload, {
    CancelToken? cancelToken,
  }) => _dio.post('/login/google/', data: payload, cancelToken: cancelToken);

  Future<Response> getUser(String userId, {CancelToken? cancelToken}) =>
      _dio.get('/user/$userId', cancelToken: cancelToken);

  // ─────────────────────────────────────────────
  // ❤️ PARTNER RELATIONSHIP
  // ─────────────────────────────────────────────
  Future<Response> invitePartner(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/invite', data: data, cancelToken: cancelToken);

  Future<Response> acceptInvite(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/accept-invite', data: data, cancelToken: cancelToken);

  // ─────────────────────────────────────────────
  // 🌱 ONBOARDING
  // ─────────────────────────────────────────────
  Future<Response> submitOnboarding(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/onboarding', data: data, cancelToken: cancelToken);

  // ─────────────────────────────────────────────
  // 🗣️ SESSION MANAGEMENT
  // ─────────────────────────────────────────────
  Future<Response> startSession(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/session', data: data, cancelToken: cancelToken);

  Future<Response> getActiveSession(
    String userId, {
    CancelToken? cancelToken,
  }) => _dio.get('/session/active/$userId', cancelToken: cancelToken);

  Future<Response> getSession(String sessionId, {CancelToken? cancelToken}) =>
      _dio.get(
        '/session/$sessionId',
        cancelToken: cancelToken,
      ); // <-- useful for score screen

  Future<Response> endSession(String sessionId, {CancelToken? cancelToken}) =>
      _dio.patch(
        '/session/end/$sessionId',
        cancelToken: cancelToken,
      ); // <-- triggers AI scoring

  // ─────────────────────────────────────────────
  // 🧠 AI MODERATION
  // ─────────────────────────────────────────────
  Future<Response> moderateChat(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/moderate', data: data, cancelToken: cancelToken);

  // ─────────────────────────────────────────────
  // 🪞 POST-SESSION REFLECTION
  // ─────────────────────────────────────────────
  Future<Response> submitReflection(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/reflection', data: data, cancelToken: cancelToken);

  Future<Response> getReflection(
    String userId,
    String sessionId, {
    CancelToken? cancelToken,
  }) => _dio.get('/reflection/$userId/$sessionId', cancelToken: cancelToken);

  Future<Response> submitPostResolution(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/post-resolution', data: data, cancelToken: cancelToken);

  Future<Response> getSessionScore(
    String sessionId, {
    CancelToken? cancelToken,
  }) => _dio.get('/session/score/$sessionId', cancelToken: cancelToken);

  // ─────────────────────────────────────────────
  // 📊 SCORE & INSIGHTS
  // ─────────────────────────────────────────────
  Future<Response> submitScore(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) => _dio.post('/score', data: data, cancelToken: cancelToken);

  Future<Response> getInsights(String userId, {CancelToken? cancelToken}) =>
      _dio.get('/insights/$userId', cancelToken: cancelToken);
}

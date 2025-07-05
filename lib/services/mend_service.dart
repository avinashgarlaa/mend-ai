import 'package:dio/dio.dart';

class MendService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://mend-backend.onrender.com/api"),
  );

  Future<Response> registerUser(Map<String, dynamic> data) =>
      _dio.post('/register', data: data);

  Future<Response> invitePartner(Map<String, dynamic> data) =>
      _dio.post('/invite', data: data);

  Future<Response> submitOnboarding(Map<String, dynamic> data) =>
      _dio.post('/onboarding', data: data);

  Future<Response> login(String id) => _dio.post('/login', data: {'id': id});

  Future<Response> startSession(Map<String, dynamic> data) =>
      _dio.post('/session', data: data);

  Future<Response> moderate(Map<String, dynamic> data) =>
      _dio.post('/moderate', data: data);

  Future<Response> submitReflection(Map<String, dynamic> data) =>
      _dio.post('/reflection', data: data);

  Future<Response> submitPostResolution(Map<String, dynamic> data) =>
      _dio.post('/post-resolution', data: data);

  Future<Response> submitScore(Map<String, dynamic> data) =>
      _dio.post('/score', data: data);

  Future<Response> getInsights(String userId) => _dio.get('/insights/$userId');

  Future<Response> getUser(String userId) => _dio.get('/user/$userId');
}

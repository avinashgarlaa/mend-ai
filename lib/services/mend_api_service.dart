import 'package:http/http.dart' as http;
import 'package:mend_ai/models/reflection.dart';
import 'dart:convert';
import 'package:mend_ai/models/session.dart';
import 'package:mend_ai/models/user.dart';

class MendApiService {
  final String baseUrl;

  MendApiService({required this.baseUrl});

  Future<Session> startSession(Map<String, dynamic> sessionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/session'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sessionData),
    );

    if (response.statusCode == 201) {
      return Session.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to start session');
    }
  }

  Future<Map<String, dynamic>> moderateChat(
    Map<String, String> chatData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/moderate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(chatData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to moderate chat');
    }
  }

  Future<Reflection> saveReflection(Map<String, dynamic> reflectionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/reflection'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reflectionData),
    );

    if (response.statusCode == 201) {
      return Reflection.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save reflection');
    }
  }

  Future<Map<String, dynamic>> getInsights(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/insights/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get insights');
    }
  }

  Future<User> registerUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<bool> invitePartner(String yourId, String partnerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/invite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'yourId': yourId, 'partnerId': partnerId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}

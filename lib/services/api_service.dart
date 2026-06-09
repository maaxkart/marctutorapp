import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
class ApiService {
  static const String baseUrl = 'https://tictechnologies.in/stage/marcappbackend/tutor-admin/public/api';

  // ── Auth headers (with token) ──────────────────────────
  static Future<Map<String, String>> authHeaders() async {
    String? token = await getToken();
    return {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ── Public headers (no token) ──────────────────────────
  static Map<String, String> headers() {
    return {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
    };
  }

  // ── Token management ───────────────────────────────────
  static Future<void> saveToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString("token", token);
  }

  static Future<String?> getToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString("token");
  }

  static Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  // ── Auth ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: headers(),
      body: {"email": email, "password": password},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 &&
        data["status"] == true) {

      await saveToken(data["token"]);

      final pref =
      await SharedPreferences.getInstance();

      // 🔥 SAVE USER ID
      await pref.setInt(
        "user_id",
        data["user"]["id"],
      );

      // 🔥 SAVE NAME
      await pref.setString(
        "name",
        data["user"]["name"] ?? "",
      );

      // 🔥 SAVE EMAIL
      await pref.setString(
        "email",
        data["user"]["email"] ?? "",
      );
    }
    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: headers(),
      body: {"name": name, "email": email, "password": password},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> profile() async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: await authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ── General ────────────────────────────────────────────
  static Future<List<dynamic>> banners() async {
    final response = await http.get(
        Uri.parse("$baseUrl/banners"), headers: headers());
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> categories() async {
    final response = await http.get(
        Uri.parse("$baseUrl/categories"), headers: headers());
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> courses() async {
    final response = await http.get(
        Uri.parse("$baseUrl/courses"), headers: headers());
    return jsonDecode(response.body);
  }

  // ── Live Sessions ──────────────────────────────────────

  // All sessions
  static Future<List<dynamic>> liveSessions() async {
    final response = await http.get(
      Uri.parse("$baseUrl/live-sessions"),
      headers: await authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ✅ FIXED: /live-sessions/current
  static Future<dynamic> currentLive() async {
    final response = await http.get(
      Uri.parse("$baseUrl/live-sessions/current"),
      headers: await authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ✅ Upcoming with auth
  static Future<List<dynamic>> upcomingLive() async {
    final response = await http.get(
      Uri.parse("$baseUrl/live-sessions/upcoming"),
      headers: await authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ✅ FIXED: /live-sessions/recordings (not /completed)
  static Future<List<dynamic>> recordings() async {
    final response = await http.get(
      Uri.parse("$baseUrl/live-sessions/recordings"),
      headers: await authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Single session detail
  static Future<dynamic> liveDetails(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/live-sessions/$id"),
      headers: await authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ✅ Recording status polling
  static Future<Map<String, dynamic>> recordingStatus(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/live-sessions/$id/recording-status"),
      headers: await authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ── START CLASS → returns { room_id, host_token } ─────
  static Future<Map<String, dynamic>> startClass(int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/live-sessions/$id/start"),
      headers: await authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ── END CLASS ──────────────────────────────────────────
  static Future<Map<String, dynamic>> endClass(int id) async {
    debugPrint('🔴 endClass API called for id=$id');
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/live-sessions/$id/end"),
        headers: await authHeaders(),
      ).timeout(const Duration(seconds: 30)); // ✅ add timeout

      debugPrint('🔴 endClass status: ${response.statusCode}');
      debugPrint('🔴 endClass body: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('🔴 endClass exception: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> scheduleSession(
      Map<String, dynamic> data) async {

    final baseHeaders = await authHeaders();

    final res = await http.post(
      Uri.parse('$baseUrl/live-sessions'),
      headers: {
        ...baseHeaders,
        'Content-Type': 'application/json', // ← force this
        'Accept':       'application/json',
      },
      body: jsonEncode(data),
    );

    debugPrint('📅 scheduleSession status: ${res.statusCode}');
    debugPrint('📅 scheduleSession body: ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to schedule: ${res.body}');
    }
    return jsonDecode(res.body);
  }

  // =========================================================
// CHAT STUDENTS
// =========================================================

  static Future<List<dynamic>>
  chatStudents() async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/chat-students",
      ),

      headers: await authHeaders(),
    );

    debugPrint(
        "CHAT STUDENTS : ${response.body}");

    final data =
    jsonDecode(response.body);

    return data['data'] ?? [];
  }

// =========================================================
// CHAT TUTORS
// =========================================================

  static Future<List<dynamic>>
  chatTutors() async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/tutors",
      ),

      headers: await authHeaders(),
    );

    debugPrint(
        "CHAT TUTORS : ${response.body}");

    final data =
    jsonDecode(response.body);

    return data['data'] ?? [];
  }
}
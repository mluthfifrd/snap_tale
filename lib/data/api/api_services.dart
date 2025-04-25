import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_tale/data/model/auth/register_model.dart';
import 'package:snap_tale/data/model/auth/login_model.dart';
import 'package:snap_tale/data/model/story_add_response.dart';

import '../model/story_detail_response.dart';
import '../model/story_list_response.dart';

class ApiServices {
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<StoryListResponse> getStoryList({int page = 1, int size = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login first.');
    }

    final uri = Uri.parse("$baseUrl/stories?page=$page&size=$size");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return StoryListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to load story: ${json.decode(response.body)['message']}',
      );
    }
  }

  static Future<StoryDetailResponse> fetchStoryDetail(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Harap login terlebih dahulu.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/stories/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return StoryDetailResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to load detail story: ${json.decode(response.body)['message']}',
      );
    }
  }

  Future<StoryAddResponse> addStory({
    required List<int> bytes,
    required String fileName,
    required String description,
    double? lat,
    double? lon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login first.');
    }
    final uri = Uri.parse("$baseUrl/stories");
    final request = http.MultipartRequest('POST', uri);

    final multiPartFile = http.MultipartFile.fromBytes(
      'photo',
      bytes,
      filename: fileName,
    );

    request.files.add(multiPartFile);
    request.fields['description'] = description;
    request.headers['Authorization'] = 'Bearer $token';
    if (lat != null && lon != null) {
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();
    }

    final streamedResponse = await request.send();
    final responseBytes = await streamedResponse.stream.toBytes();
    final responseString = String.fromCharCodes(responseBytes);

    if (streamedResponse.statusCode == 201) {
      return StoryAddResponse.fromJson(json.decode(responseString));
    } else {
      throw Exception(
        'Failed to add Story: ${(json.decode(responseString)["message"])}',
      );
    }
  }

  Future<Login> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      return Login.fromJson(json.decode(response.body));
    } else {
      return Login.fromJson(json.decode(response.body));
    }
  }

  Future<Register> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'name': name, 'email': email, 'password': password},
    );

    return Register.fromJson(json.decode(response.body));
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

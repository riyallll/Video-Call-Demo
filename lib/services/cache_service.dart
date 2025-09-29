import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class CacheService {
  static const String usersKey = "users_cache_v1";

  Future<void> cacheUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(users.map((e) => e.toJson()).toList());
    await prefs.setString(usersKey, encoded);
  }

  Future<List<UserModel>> getCachedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(usersKey);
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(usersKey);
  }
}

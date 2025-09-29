import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = "https://reqres.in/api";

  /// Attempt login using ReqRes
  /// ReqRes expects email & password; returns 200 if accepted
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Fetch user list (page 1)
  Future<List<UserModel>> fetchUsers() async {
    await Future.delayed(Duration(seconds: 1)); // fake network delay
    return [
      UserModel(
        id: 1,
        email: "george.bluth@reqres.in",
        firstName: "George",
        lastName: "Bluth",
        avatar: "https://reqres.in/img/faces/1-image.jpg",
      ),
      UserModel(
        id: 2,
        email: "janet.weaver@reqres.in",
        firstName: "Janet",
        lastName: "Weaver",
        avatar: "https://reqres.in/img/faces/2-image.jpg",
      ),
    ];
  }

}

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class MockLoginResponse {

  static Map<String, dynamic> getLoginResponseJson() {
    return {
      "success": true,
      "message": "Login successful",
      "data": {
        "user": {
          "_id": "693c7ce4c814841fde775f31",
          "id": "693c7ce4c814841fde775f31",
          "phone": "1234567890",
          "countryCode": "+20",
          "role": "customer",
          "name": "",
          "email": "",
          "avatar": "",
          "isVerified": true,
          "isProfileComplete": false
        },
        "tokens": {
          "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OTNjN2NlNGM4MTQ4NDFmZGU3NzVmMzEiLCJyb2xlIjoiY3VzdG9tZXIiLCJpYXQiOjE3NjU1NzE4MTIsImV4cCI6MTc2NTY1ODIxMn0.BVQQJErd80iOYiCQghHAVbiqrszfclyvO3tSyKxCE3Y",
          "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OTNjN2NlNGM4MTQ4NDFmZGU3NzVmMzEiLCJpYXQiOjE3NjU1NzE4MTIsImV4cCI6MTc2NjE3NjYxMn0.j9L59tBztyibnZyW1UMGJJwBahMYSrcq4ZHRL2HPXOs"
        }
      }
    };
  }

  static UserAuthResponseModel getLoginResponseModel() {
    final json = getLoginResponseJson();
    final user = UserModel.fromJson(json["data"]["user"]);
    return UserAuthResponseModel(
      message: json["message"],
      token: json["data"]["token"],
      user: user,
    );
  }

  static Future<Map<String, dynamic>> loadLoginResponseFromFile() async {
    final String response = await rootBundle.loadString('lib/data/mock_login_response.json');
    return json.decode(response);
  }
}


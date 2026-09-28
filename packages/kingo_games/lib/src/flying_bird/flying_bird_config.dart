import 'package:flutter/material.dart';

/// Copy and gameplay tuning for Flying Bird.
abstract class FlyingBirdConfig {
  static const gravity = 1250.0;
  static const flapVelocity = -390.0;
  static const maxFallSpeed = 760.0;
  static const pipeSpeed = 175.0;
  static const cloudSpeed = 28.0;
  static const groundSpeed = 175.0;
  static const pipeWidth = 68.0;
  static const pipeGap = 188.0;
  static const spawnInterval = 1.6;
  static const birdSize = 46.0;
  static const groundHeight = 96.0;
  static const skyTop = Color(0xFF7EC8F8);
  static const skyBottom = Color(0xFFE5D4FF);
  static const pipeGreen = Color(0xFF2FA36B);
  static const pipeDark = Color(0xFF1E7A4D);
  static const pipeLight = Color(0xFF4ECB86);
  static const groundColor = Color(0xFFD7B06A);
  static const groundDark = Color(0xFFC49A4E);
  static const grassColor = Color(0xFF3CB371);
  static const grassDark = Color(0xFF2E8B57);
  static const birdBody = Color(0xFFFFC107);
  static const birdWing = Color(0xFFFF9800);
  static const birdBeak = Color(0xFFFF6D00);
  static const birdEye = Color(0xFF222222);
  static const accent = Color(0xFF9810FA);
}

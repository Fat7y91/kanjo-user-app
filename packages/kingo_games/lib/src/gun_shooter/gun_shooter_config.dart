import 'package:flutter/material.dart';

abstract class GunShooterConfig {
  static const accent = Color(0xFF9810FA);
  static const skyTop = Color(0xFF0B1026);
  static const skyBottom = Color(0xFF1B2550);
  static const groundColor = Color(0xFF243047);
  static const gunBody = Color(0xFFCFD8E6);
  static const gunDark = Color(0xFF7A869A);
  static const muzzleFlash = Color(0xFFFFC107);
  static const bulletColor = Color(0xFFFFE082);
  static const enemyBody = Color(0xFFE53935);
  static const enemyDark = Color(0xFFB71C1C);
  static const enemyEye = Color(0xFFFFFFFF);

  static const groundHeight = 72.0;
  static const gunSize = 64.0;
  static const bulletSpeed = 620.0;
  static const bulletRadius = 5.0;
  static const enemySize = 42.0;
  static const enemyBaseSpeed = 90.0;
  static const spawnInterval = 1.15;
  static const maxLives = 3;
  static const pointsPerHit = 1;
  static const fireCooldown = 0.18;
}

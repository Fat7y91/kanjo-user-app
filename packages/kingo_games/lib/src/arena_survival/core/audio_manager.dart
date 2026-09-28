import 'package:flutter/services.dart';

enum ArenaSfx {
  enemyHit,
  enemyDeath,
  xpPickup,
  levelUp,
  playerDamage,
  bossSpawn,
  bossHit,
  victory,
  gameOver,
}

class ArenaAudioManager {
  ArenaAudioManager({
    this.musicVolume = 0.7,
    this.sfxVolume = 0.9,
  });

  double musicVolume;
  double sfxVolume;

  void playSfx(ArenaSfx sfx) {
    if (sfxVolume <= 0.01) return;
    // Lightweight placeholder SFX until dedicated audio assets are added.
    SystemSound.play(SystemSoundType.click);
  }
}

class ArenaSurvivalStrings {
  const ArenaSurvivalStrings({
    this.title = 'Arena Survival',
    this.subtitle = 'Survive 5 minutes and defeat the guardian',
    this.play = 'Play',
    this.continueRun = 'Continue chapter',
    this.upgrades = 'Upgrades',
    this.settings = 'Settings',
    this.coins = 'Coins',
    this.chapter = 'Chapter',
    this.pause = 'Pause',
    this.resume = 'Resume',
    this.restart = 'Restart',
    this.mainMenu = 'Main Menu',
    this.gamePaused = 'Game Paused',
    this.levelUp = 'Level Up!',
    this.chooseUpgrade = 'Choose one upgrade',
    this.gameOver = 'Game Over',
    this.victory = 'Victory!',
    this.bossDefeated = 'Boss Defeated',
    this.survivalTime = 'Survival Time',
    this.level = 'Level',
    this.kills = 'Enemies Defeated',
    this.coinsEarned = 'Coins Earned',
    this.playAgain = 'Play Again',
    this.back = 'Back',
    this.hp = 'HP',
    this.damage = 'Damage',
    this.moveSpeed = 'Movement Speed',
    this.pickupRadius = 'XP Pickup Radius',
    this.upgrade = 'Upgrade',
    this.maxLevel = 'Max',
    this.cost = 'Cost',
    this.music = 'Music Volume',
    this.sfx = 'SFX Volume',
    this.bestTime = 'Best Time',
    this.highestLevel = 'Highest Level',
    this.totalKills = 'Total Kills',
    this.countdownGo = 'GO!',
    this.pointsWonTemplate = 'You won {count} points',
  });

  final String title;
  final String subtitle;
  final String play;
  final String continueRun;
  final String upgrades;
  final String settings;
  final String coins;
  final String chapter;
  final String pause;
  final String resume;
  final String restart;
  final String mainMenu;
  final String gamePaused;
  final String levelUp;
  final String chooseUpgrade;
  final String gameOver;
  final String victory;
  final String bossDefeated;
  final String survivalTime;
  final String level;
  final String kills;
  final String coinsEarned;
  final String playAgain;
  final String back;
  final String hp;
  final String damage;
  final String moveSpeed;
  final String pickupRadius;
  final String upgrade;
  final String maxLevel;
  final String cost;
  final String music;
  final String sfx;
  final String bestTime;
  final String highestLevel;
  final String totalKills;
  final String countdownGo;
  final String pointsWonTemplate;

  String pointsWon(int score) =>
      pointsWonTemplate.replaceAll('{count}', '$score');
}

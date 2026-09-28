/// Localizable strings for [GunShooterGameView].
class GunShooterStrings {
  const GunShooterStrings({
    this.title = 'Gun Shooter',
    this.tapToShoot = 'Tap to shoot',
    this.hint = 'Aim and shoot the targets before they reach you',
    this.gameOver = 'Game Over',
    this.yourScore = 'Your score',
    this.scoreLabel = 'Score',
    this.livesLabel = 'Lives',
    this.playAgain = 'Play again',
    this.back = 'Back',
    this.pointsWonTemplate = 'You won {count} points',
  });

  final String title;
  final String tapToShoot;
  final String hint;
  final String gameOver;
  final String yourScore;
  final String scoreLabel;
  final String livesLabel;
  final String playAgain;
  final String back;

  /// Use `{count}` as the points placeholder.
  final String pointsWonTemplate;

  String pointsWon(int score) =>
      pointsWonTemplate.replaceAll('{count}', '$score');
}

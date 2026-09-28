/// Localizable strings for [FlyingBirdGameView].
class FlyingBirdStrings {
  const FlyingBirdStrings({
    this.title = 'Flying Bird',
    this.tapToFly = 'Tap to fly',
    this.passPipesHint = 'Pass the pipes to win points',
    this.gameOver = 'Game Over',
    this.yourScore = 'Your score',
    this.scoreLabel = 'Score',
    this.playAgain = 'Play again',
    this.back = 'Back',
    this.pointsWonTemplate = 'You won {count} points',
  });

  final String title;
  final String tapToFly;
  final String passPipesHint;
  final String gameOver;
  final String yourScore;
  final String scoreLabel;
  final String playAgain;
  final String back;

  /// Use `{count}` as the points placeholder.
  final String pointsWonTemplate;

  String pointsWon(int score) =>
      pointsWonTemplate.replaceAll('{count}', '$score');
}

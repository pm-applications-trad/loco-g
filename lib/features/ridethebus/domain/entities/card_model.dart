enum CardSuit { hearts, diamonds, clubs, spades }

extension CardSuitDisplay on CardSuit {
  String get emoji {
    switch (this) {
      case CardSuit.hearts:
        return '♥';
      case CardSuit.diamonds:
        return '♦';
      case CardSuit.clubs:
        return '♣';
      case CardSuit.spades:
        return '♠';
    }
  }

  bool get isRed => this == CardSuit.hearts || this == CardSuit.diamonds;

  String get displayName {
    switch (this) {
      case CardSuit.hearts:
        return 'Hearts';
      case CardSuit.diamonds:
        return 'Diamonds';
      case CardSuit.clubs:
        return 'Clubs';
      case CardSuit.spades:
        return 'Spades';
    }
  }
}

enum CardValue {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

extension CardValueDisplay on CardValue {
  String get label {
    switch (this) {
      case CardValue.ace:
        return 'A';
      case CardValue.two:
        return '2';
      case CardValue.three:
        return '3';
      case CardValue.four:
        return '4';
      case CardValue.five:
        return '5';
      case CardValue.six:
        return '6';
      case CardValue.seven:
        return '7';
      case CardValue.eight:
        return '8';
      case CardValue.nine:
        return '9';
      case CardValue.ten:
        return '10';
      case CardValue.jack:
        return 'J';
      case CardValue.queen:
        return 'Q';
      case CardValue.king:
        return 'K';
    }
  }

  int get numericValue {
    switch (this) {
      case CardValue.ace:
        return 1;
      case CardValue.two:
        return 2;
      case CardValue.three:
        return 3;
      case CardValue.four:
        return 4;
      case CardValue.five:
        return 5;
      case CardValue.six:
        return 6;
      case CardValue.seven:
        return 7;
      case CardValue.eight:
        return 8;
      case CardValue.nine:
        return 9;
      case CardValue.ten:
        return 10;
      case CardValue.jack:
        return 11;
      case CardValue.queen:
        return 12;
      case CardValue.king:
        return 13;
    }
  }
}

class PlayingCard {
  final CardSuit suit;
  final CardValue value;

  const PlayingCard({required this.suit, required this.value});

  String get displayName => '${value.label}${suit.emoji}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard && suit == other.suit && value == other.value;

  @override
  int get hashCode => suit.hashCode ^ value.hashCode;

  @override
  String toString() => displayName;
}

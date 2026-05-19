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

  String get name {
    switch (this) {
      case CardValue.ace:
        return 'ace';
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
        return 'jack';
      case CardValue.queen:
        return 'queen';
      case CardValue.king:
        return 'king';
    }
  }
}

class CardModel {
  final CardSuit suit;
  final CardValue value;

  const CardModel({required this.suit, required this.value});

  String get displayName => '${value.label}${suit.emoji}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel && suit == other.suit && value == other.value;

  @override
  int get hashCode => suit.hashCode ^ value.hashCode;

  @override
  String toString() => displayName;
}

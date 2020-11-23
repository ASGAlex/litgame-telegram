enum CardType { generic, person, place }

extension StringType on CardType {
  String value() {
    switch (this) {
      case CardType.generic:
        return 'generic';
      case CardType.person:
        return 'person';
      case CardType.place:
        return 'place';
    }
    return '';
  }
}

class Card {
  Card(this.name, this.type);

  final String name;
  final CardType type;
}

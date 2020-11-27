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
  }

  CardType getTypeByName(String name) {
    switch (name) {
      case 'generic':
        return CardType.generic;
      case 'person':
        return CardType.person;
      case 'place':
        return CardType.place;
    }
    throw 'No such type: ' + name;
  }
}

class Card {
  Card(this.name, this.imgUrl, this.type);

  final String name;
  final String imgUrl;
  final CardType type;
}

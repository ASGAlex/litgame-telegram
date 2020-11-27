import 'dart:math';

import 'package:litgame_telegram/models/cards/card.dart';

class CardCollection {
  CardCollection(String name) : name = name.isEmpty ? name : 'default' {
    loadCollection();
  }

  final String name;
  final Map<String, List<Card>> cards = {};

  void loadCollection() {
    cards.clear();
    var generic = <Card>[];
    generic.add(Card(
        'Случайность',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fgeneric%2Faccident.jpg?alt=media&token=fd0cad3a-d5be-491e-a2d7-c8986823166b',
        CardType.generic));
    generic.add(Card(
        'Амулет',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fgeneric%2Famulet.jpg?alt=media&token=e0345296-70ea-45c4-bf7a-cbbfb593e528',
        CardType.generic));
    generic.add(Card(
        'Яблоко раздора',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fgeneric%2Fapple-of-discord.jpg?alt=media&token=e400d3a6-e660-4469-badf-e4923793514f',
        CardType.generic));
    generic.add(Card(
        'Возвращение к истокам',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fgeneric%2Fback-to-the-roots.jpg?alt=media&token=ba47d633-9d56-4900-98f4-d161e90ba16c',
        CardType.generic));
    generic.add(Card(
        'Противостояние',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fgeneric%2Fconfrontation.jpg?alt=media&token=c73270a7-b640-4af9-8708-f75a6ec98d58',
        CardType.generic));

    cards[CardType.generic.value()] = generic;
    var random = Random(generic.length);
    generic.shuffle(random);

    var place = <Card>[];
    place.add(Card(
        'Центр мира',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fplace%2Fcenter-of-the-world.jpg?alt=media&token=2bd111e8-8b60-466b-b92f-23538a111ea8',
        CardType.place));
    place.add(Card(
        'Вражьи земли',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fplace%2Fenemy-lands.jpg?alt=media&token=24ede740-f1b1-44f6-b6c2-87365ca985d6',
        CardType.place));
    place.add(Card(
        'Чужбина',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fplace%2Fforeign-land.jpg?alt=media&token=d2fcf9f6-36e2-452f-9748-e7b37267b2f9',
        CardType.place));
    place.add(Card(
        'Святая земля',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fplace%2Fholy-land.jpg?alt=media&token=88c43348-6e83-4c18-807a-8271a4b50cc7',
        CardType.place));
    place.add(Card(
        'Дом',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fplace%2Fhome.jpg?alt=media&token=6e5b146a-e719-40b2-a056-de92a66df30d',
        CardType.place));
    place.shuffle(random);
    cards[CardType.place.value()] = place;

    var person = <Card>[];
    person.add(Card(
        'Антагонист',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fperson%2Fantogonist.jpg?alt=media&token=b6015640-cf13-446f-b1bd-6a9ac8836394',
        CardType.person));
    person.add(Card(
        'Возлюбленный',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fperson%2Fbeloved.jpg?alt=media&token=1be69fda-a3a7-432f-ab58-8f90878abae9',
        CardType.person));
    person.add(Card(
        'Черт',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fperson%2Fdevil.jpg?alt=media&token=d8aaeeb4-fbca-40c8-ba79-98c2eb7f563d',
        CardType.person));
    person.add(Card(
        'Страж',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fperson%2Fguardian.jpg?alt=media&token=16f16605-9297-439a-97e2-e94d55358a78',
        CardType.person));
    person.add(Card(
        'Герой',
        'https://firebasestorage.googleapis.com/v0/b/litgame-70f87.appspot.com/o/cardset%2Fdefault%2Fperson%2Fhero.jpg?alt=media&token=0686581c-607b-47aa-b4c3-996d4c7954cc',
        CardType.person));
    person.shuffle(random);
    cards[CardType.person.value()] = person;
  }
}

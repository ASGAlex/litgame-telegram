import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:test/test.dart';

void main() {
  test('test', () {
    final cc1 = CardCollection('default');
    cc1.loadCollection();

    final cc2 = CardCollection('default');
    cc2.loadCollection();

    expect(cc1.cards['generic']?.first.name == cc2.cards['generic']?.first.name, false);
  });
}

// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:file/memory.dart';
import 'package:http/http.dart' as http;
import 'package:litgame_telegram/models/cards/card.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class CardCollection extends ParseObject implements ParseCloneable {
  CardCollection(String name) : super('CardCollection') {
    this['name'] = name.isEmpty ? 'default' : name;
  }

  CardCollection.clone() : super('CardCollection');

  @override
  CardCollection clone(Map<String, dynamic> map) =>
      CardCollection.clone()..fromJson(map);

  String get name => this['name'];

  set name(String name) {
    this['name'] = name;
  }

  final Map<String, List<Card>> cards = {};
  static final Map<String, String> _cacheNameById = {};

  Future? loaded;

  CardCollection.fromArchive(String url) : super('CardCollection') {
    final allCompleter = Completer();
    loaded = allCompleter.future;
    http.get(url).then((value) {
      final tmpPath = Directory.systemTemp.path +
          '/litgameBot/' +
          DateTime.now().millisecond.toString();
      final arch = ZipDecoder().decodeBytes(value.bodyBytes);
      final savedFiles = <String, File>{};
      final loopCompleter = Completer();
      final loopFuture = loopCompleter.future;
      late final Future jsonFuture;

      for (var file in arch) {
        if (file.name == 'description.json') {
          final mFile = MemoryFileSystem().file(tmpPath + '/description.json');
          mFile.createSync(recursive: true);
          mFile.writeAsBytesSync(file.content as List<int>);
          jsonFuture = mFile
              .readAsString()
              .then((value) => json.decode(value))
              .then((jsonData) {
            _fillCardsFromJson(jsonData);
          });
        } else {
          final dFile = File(tmpPath + '/' + file.name);
          dFile.createSync(recursive: true);
          dFile.writeAsBytesSync(file.content as List<int>);
          savedFiles[file.name] = dFile;
        }
      }
      loopCompleter.complete();

      Future.wait([loopFuture, jsonFuture]).then((value) {
        if (savedFiles.length < cards.length) {
          throw 'Не для всех карт загружены картинки!';
        }
        savedFiles.forEach((key, file) {
          var parts = key.split('/');
          final imgCardType = parts.first;
          final imgCardFile = parts.last;
          var parseFile = ParseFile(file);
          var cardsOfType = cards[imgCardType];
          if (cardsOfType == null) {
            throw 'Parse error';
          }
          for (var element in cardsOfType) {
            if (element['imgUrl'] == imgCardFile) {
              element.set('img', parseFile);
              element.save();
              break;
            }
          }
        });

        save().then((value) {
          allCompleter.complete();
        });
      });
    });
  }

  void _fillCardsFromJson(Map jsonData) {
    if (jsonData['name'] == null) {
      throw 'Invalid archive format';
    }
    name = jsonData['name'];
    var cardsList;
    try {
      cardsList = jsonData['cards'] as List;
    } catch (error) {
      throw 'Invalid archive format';
    }
    if (cardsList.isEmpty) {
      throw 'Invalid archive format';
    }
    for (var c in cardsList) {
      if (c['type'] == null) {
        throw 'Invalid archive format';
      }
      String cType = c['type'];
      if (cards[cType] == null) {
        cards[cType] = <Card>[];
      }
      cards[cType]?.add(Card(
          c['name'], c['file'], CardType.generic.getTypeByName(cType), name));
    }
  }

  static Future<CardCollection> fromServer(String name) async {
    final builder = QueryBuilder<CardCollection>(CardCollection.clone())
      ..whereEqualTo('name', name);
    var completer = Completer();
    var loadCards = completer.future;
    var loadCollection =
        builder.query<CardCollection>().then((ParseResponse response) {
      if (response.results == null) return CardCollection('');
      var c = response.results.first;
      var collection = c as CardCollection;
      collection._loadCards().then((_) {
        completer.complete();
      });
      return collection;
    });
    return Future.wait([loadCollection, loadCards])
        .then((value) => loadCollection);
  }

  static Future<List> listCollections() {
    return CardCollection.clone().getAll().then((response) => response.results);
  }

  static Future getById(String id) =>
      CardCollection.clone().getObject(id).then((value) => value.results.first);

  static Future getName(String id) {
    final name = _cacheNameById[id];
    if (name == null) {
      return getById(id).then((value) {
        if (value.name != null) {
          _cacheNameById[id] = value.name;
        }
        return value;
      });
    }

    final completer = Completer();
    completer.complete(CardCollection(name));
    return completer.future;
  }

  Future _loadCards() {
    final builder = QueryBuilder<Card>(Card.clone())
      ..whereEqualTo('collection', name);
    return builder.query().then((ParseResponse response) {
      if (response.results == null) throw 'Error loading cards';
      for (Card item in response.results) {
        if (cards[item.cardType.value()] == null) {
          cards[item.cardType.value()] = <Card>[];
        }
        cards[item.cardType.value()]?.add(item);
      }
      cards.values.forEach((listOfCards) {
        listOfCards.shuffle(Random());
      });
    });
  }

  Future deleteWithCards() {
    var log = 'Delete collection ${name}...\r\n';
    final builder = QueryBuilder<Card>(Card.clone())
      ..whereEqualTo('collection', name);
    return builder.query().then((ParseResponse response) {
      if (response.results != null) {
        for (Card item in response.results) {
          log +=
              'Delete ${item.name}, ${item.objectId} ${item.collectionName} \r\n';
          item.delete();
        }
      }
      log += 'done';
      print(log);
      super.delete();
    });
  }
}

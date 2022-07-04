import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/entities/number_trivia_entity.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTrivaModel = NumberTriviaModel(number: 1, text: 'TestText');

  test('should be a subclass of NumberTrivaEntity entity', () async {
    expect(tNumberTrivaModel, isA<NumberTriviaEntity>());
  });

  group('fromJson', () {
    test('should return a valid model when the Json number is an integer.',
        () async {
      final Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, tNumberTrivaModel);
    });

    test(
        'should ret urn a valid model when the Json number is regarded as a double',
        () async {
      final Map<String, dynamic> jsonMap =
          jsonDecode(fixture('trivia_double.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, tNumberTrivaModel);
    });
  });
  group('toJson', () {
    test('should return a Json map containing the proper data', () async {
      final expectedMap = {
        "text": "TestText",
        "number": 1,
      };
      final result = tNumberTrivaModel.toJson();
      expect(result, expectedMap);
    });
  });
}

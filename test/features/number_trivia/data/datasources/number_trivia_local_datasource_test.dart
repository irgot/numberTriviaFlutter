import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture_reso/core/error/exceptions.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDatasourceImpl datasourceImpl;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    datasourceImpl = NumberTriviaLocalDatasourceImpl(mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from SharedPreferences when there is onw in the cache',
        () async {
      when(() => mockSharedPreferences.getString(any()))
          .thenReturn(fixture('trivia_cached.json'));
      final result = await datasourceImpl.getLastNumberTrivia();
      verify(() => mockSharedPreferences.getString(cachedNumberTrivia));
      expect(result, equals(tNumberTriviaModel));
    });
    test('should throw CacheException when there is not a cached value',
        () async {
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      final call = datasourceImpl.getLastNumberTrivia;
      expect(call, throwsA(const TypeMatcher<CacheException>()));
    });
  });
  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'text', number: 1);
    test('should call SharedPreferences to cache the data', () async {
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((invocation) async => true);
      await datasourceImpl.cacheNumberTrivia(tNumberTriviaModel);
      final expectedJsonString = jsonEncode(tNumberTriviaModel);

      verify(() => mockSharedPreferences.setString(
          cachedNumberTrivia, expectedJsonString));
    });
  });
}

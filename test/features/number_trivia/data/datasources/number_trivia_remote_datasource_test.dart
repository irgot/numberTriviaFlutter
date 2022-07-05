import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture_reso/core/error/exceptions.dart';
import 'package:tdd_clean_architecture_reso/core/error/failures.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/models/number_trivia_model.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late NumberTriviaRemoteDatasourceImpl datasourceImpl;

  setUp(() {
    mockHttpClient = MockHttpClient();
    datasourceImpl = NumberTriviaRemoteDatasourceImpl(mockHttpClient);
  });

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    void setUpMockHttpClient(int statusCode) {
      when(() => mockHttpClient.get(Uri.parse('$baseUrl/$tNumber'),
              headers: any(named: 'headers')))
          .thenAnswer((invocation) async =>
              http.Response(fixture('trivia.json'), statusCode));
    }

    test('''should perform a get request on a Url with number 
        being the endpoint and with application/json header''', () async {
      setUpMockHttpClient(200);
      final response = await datasourceImpl.getConcreteNumberTrivia(tNumber);

      verify(() => mockHttpClient.get(Uri.parse('$baseUrl/$tNumber'),
          headers: {'content-type': 'application/json'})).called(1);
      expect(response, NumberTriviaModel(text: 'TestText', number: 1));
    });
    test('''should return ServerFailure when the statusCode is != of 200''',
        () async {
      setUpMockHttpClient(500);
      final response = datasourceImpl.getConcreteNumberTrivia(tNumber);
      expect(response, throwsA(const TypeMatcher<ServerException>()));
    });
  });
  group('getRandomNumberTrivia', () {
    void setUpMockHttpClient(int statusCode) {
      when(() => mockHttpClient.get(Uri.parse('$baseUrl/random'),
              headers: any(named: 'headers')))
          .thenAnswer((invocation) async =>
              http.Response(fixture('trivia.json'), statusCode));
    }

    test('''should perform a get request on a Url with number 
        being the endpoint and with application/json header''', () async {
      setUpMockHttpClient(200);
      final response = await datasourceImpl.getRandomNumberTrivia();

      verify(() => mockHttpClient.get(Uri.parse('$baseUrl/random'),
          headers: {'content-type': 'application/json'})).called(1);
      expect(response, NumberTriviaModel(text: 'TestText', number: 1));
    });
    test('''should return ServerFailure when the statusCode is != of 200''',
        () async {
      setUpMockHttpClient(500);
      final response = datasourceImpl.getRandomNumberTrivia();
      expect(response, throwsA(const TypeMatcher<ServerException>()));
    });
  });
}

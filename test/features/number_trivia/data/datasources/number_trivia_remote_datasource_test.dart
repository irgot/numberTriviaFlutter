import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late NumberTriviaRemoteDatasourceImpl datasourceImpl;

  setUp(() {
    mockDio = MockDio();
    datasourceImpl = NumberTriviaRemoteDatasourceImpl(mockDio);
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tRequestOpstions = RequestOptions(path: any(named: 'path'));
    // final tResponse = Response(
    //     requestOptions: tRequestOpstions,
    //     statusCode: 200,
    //     data: fixture('trivia.json'));
    // final tExpectedOptions =
    //     Options(headers: {'Content-Type': 'Application/Json'});
    // final tOptions = Options(headers: any(named: 'headers'));
    // final tNumberTriviaMiodel =
    //     NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
    test(
        '''should perform a get request on a Url with number 
        being the endpoint and with application/json header''',
        () async {
      when(() => mockDio.getUri(
                Uri.parse(any()),
              ))
          .thenAnswer((invocation) async => Response(
              requestOptions: tRequestOpstions,
              data: jsonDecode(fixture('trivia.json'))));
      await datasourceImpl.getConcreteNumberTrivia(tNumber);
      verify(() => mockDio.getUri(Uri.parse('$baseUrl/$tNumber')));
      // when(() => mockDio.getUri(any(), options: tOptions))
      //     .thenAnswer((invocation) async => tResponse);
      // datasourceImpl.getConcreteNumberTrivia(tNumber);
      // verify(() => mockDio.getUri(
      //     Uri.parse('$getConcreteNumberTriviaUrl$tNumber'),
      //     options: tExpectedOptions)).called(1);
    });
  });
}

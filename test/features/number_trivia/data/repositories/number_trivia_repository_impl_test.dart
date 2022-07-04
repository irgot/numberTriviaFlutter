import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture_reso/core/error/exceptions.dart';
import 'package:tdd_clean_architecture_reso/core/error/failures.dart';
import 'package:tdd_clean_architecture_reso/core/platform/network_info.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/entities/number_trivia_entity.dart';

class MockRemoteDatasource extends Mock
    implements NumberTriviaRemoteDatasource {}

class MockLocalDatasource extends Mock implements NumberTriviaLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repositoryImpl;
  late MockRemoteDatasource mockRemoteDatasource;
  late MockLocalDatasource mockLocalDatasource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDatasource = MockRemoteDatasource();
    mockLocalDatasource = MockLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repositoryImpl = NumberTriviaRepositoryImpl(
        numberTriviaRemoteDatasource: mockRemoteDatasource,
        numberTriviaLocalDatasource: mockLocalDatasource,
        networkInfo: mockNetworkInfo);
  });

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(text: 'text', number: tNumber);
    final NumberTriviaEntity tNumberTriviaEntity = tNumberTriviaModel;
    setUp(() {
      when(() => mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel))
          .thenAnswer((invocation) async {});
    });
    test('should check if the device is online', () async {
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((invocation) async => true);
      when(() => mockRemoteDatasource.getConcreteNumberTrivia(tNumber))
          .thenAnswer((invocation) async => tNumberTriviaModel);
      repositoryImpl.getConcreteNumberTrivia(tNumber);
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((invocation) async => true);

        when(() => mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((invocation) async {});
      });
      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        when(() => mockRemoteDatasource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((invocation) async => tNumberTriviaModel);
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);
        verify(() => mockRemoteDatasource.getConcreteNumberTrivia(tNumber));

        expect(result, equals(right(tNumberTriviaEntity)));
      });
      test(
          'should cache the data localy when the call to remote data source is successful',
          () async {
        when(() => mockRemoteDatasource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((invocation) async => tNumberTriviaModel);
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);
        verify(() => mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel));
      });
      test(
          'should return ServerFailure when the call to remote data source is unsuccessful',
          () async {
        when(() => mockRemoteDatasource.getConcreteNumberTrivia(tNumber))
            .thenThrow(ServerException());
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);
        verifyZeroInteractions(mockLocalDatasource);
        expect(result, left(ServerFailure()));
      });
    });
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((invocation) async => false);
      });
      test(
          'should return last locally cached data when the cached data is present.',
          () async {
        when(mockLocalDatasource.getLastNumberTrivia)
            .thenAnswer((invocation) async => tNumberTriviaModel);
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        verifyZeroInteractions(mockRemoteDatasource);
        verify(mockLocalDatasource.getLastNumberTrivia);
        expect(result, equals(right(tNumberTriviaEntity)));
      });
      test('should return CacheFailure when there is no cached data present',
          () async {
        when(mockLocalDatasource.getLastNumberTrivia)
            .thenThrow(CacheException());
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);
        verify(mockLocalDatasource.getLastNumberTrivia);
        expect(result, equals(left(CacheFailure())));
      });
    });
  });
  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'text', number: 1);
    final NumberTriviaEntity tNumberTriviaEntity = tNumberTriviaModel;
    setUp(() {
      when(() => mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel))
          .thenAnswer((invocation) async {});
    });
    test('should check if the device is online', () async {
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((invocation) async => true);
      when(() => mockRemoteDatasource.getRandomNumberTrivia())
          .thenAnswer((invocation) async => tNumberTriviaModel);
      repositoryImpl.getRandomNumberTrivia();
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((invocation) async => true);

        when(() => mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((invocation) async {});
      });
      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        when(() => mockRemoteDatasource.getRandomNumberTrivia())
            .thenAnswer((invocation) async => tNumberTriviaModel);
        final result = await repositoryImpl.getRandomNumberTrivia();
        verify(() => mockRemoteDatasource.getRandomNumberTrivia());

        expect(result, equals(right(tNumberTriviaEntity)));
      });
      test(
          'should cache the data localy when the call to remote data source is successful',
          () async {
        when(() => mockRemoteDatasource.getRandomNumberTrivia())
            .thenAnswer((invocation) async => tNumberTriviaModel);
        final result = await repositoryImpl.getRandomNumberTrivia();
        verify(() => mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel));
      });
      test(
          'should return ServerFailure when the call to remote data source is unsuccessful',
          () async {
        when(() => mockRemoteDatasource.getRandomNumberTrivia())
            .thenThrow(ServerException());
        final result = await repositoryImpl.getRandomNumberTrivia();
        verifyZeroInteractions(mockLocalDatasource);
        expect(result, left(ServerFailure()));
      });
    });
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((invocation) async => false);
      });
      test(
          'should return last locally cached data when the cached data is present.',
          () async {
        when(mockLocalDatasource.getLastNumberTrivia)
            .thenAnswer((invocation) async => tNumberTriviaModel);
        final result = await repositoryImpl.getRandomNumberTrivia();

        verifyZeroInteractions(mockRemoteDatasource);
        verify(mockLocalDatasource.getLastNumberTrivia);
        expect(result, equals(right(tNumberTriviaEntity)));
      });
      test('should return CacheFailure when there is no cached data present',
          () async {
        when(mockLocalDatasource.getLastNumberTrivia)
            .thenThrow(CacheException());
        final result = await repositoryImpl.getRandomNumberTrivia();
        verify(mockLocalDatasource.getLastNumberTrivia);
        expect(result, equals(left(CacheFailure())));
      });
    });
  });
}

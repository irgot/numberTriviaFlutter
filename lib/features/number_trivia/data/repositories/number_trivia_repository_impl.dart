import 'package:tdd_clean_architecture_reso/core/error/exceptions.dart';
import 'package:tdd_clean_architecture_reso/core/network/network_info.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/entities/number_trivia_entity.dart';
import 'package:tdd_clean_architecture_reso/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/repositories/number_trivia_repository.dart';

import '../models/number_trivia_model.dart';

typedef Future<NumberTriviaModel> _concreteOrRandomChoose();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDatasource numberTriviaRemoteDatasource;
  final NumberTriviaLocalDatasource numberTriviaLocalDatasource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl(
      {required this.numberTriviaRemoteDatasource,
      required this.numberTriviaLocalDatasource,
      required this.networkInfo});

  @override
  Future<Either<Failure, NumberTriviaEntity>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(
        () => numberTriviaRemoteDatasource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTriviaEntity>> getRandomNumberTrivia() async {
    return await _getTrivia(
        () => numberTriviaRemoteDatasource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTriviaEntity>> _getTrivia(
      _concreteOrRandomChoose getConcreteOrRandom) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteOrRandom();
        await numberTriviaLocalDatasource.cacheNumberTrivia(remoteTrivia);
        return right(remoteTrivia);
      } on ServerException {
        return left(ServerFailure());
      }
    } else {
      try {
        final localTrivia =
            await numberTriviaLocalDatasource.getLastNumberTrivia();
        return (right(localTrivia));
      } on CacheException {
        return (left(CacheFailure()));
      }
    }
  }
}

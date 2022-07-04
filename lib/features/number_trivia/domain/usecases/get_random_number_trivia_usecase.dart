import 'package:equatable/equatable.dart';
import 'package:tdd_clean_architecture_reso/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:tdd_clean_architecture_reso/core/usecases/usecase.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/entities/number_trivia_entity.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetRandomNumberTriviaUsecase
    implements UseCase<NumberTriviaEntity, NoParams> {
  final NumberTriviaRepository repository;

  GetRandomNumberTriviaUsecase(this.repository);

  @override
  Future<Either<Failure, NumberTriviaEntity>> call(NoParams noParams) async {
    return await repository.getRandomNumberTrivia();
  }
}

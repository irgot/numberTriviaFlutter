import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tdd_clean_architecture_reso/core/error/failures.dart';
import 'package:tdd_clean_architecture_reso/core/usecases/usecase.dart';
import 'package:tdd_clean_architecture_reso/core/util/input_converter.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/entities/number_trivia_entity.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/usecases/get_concrete_number_trivia_usecase.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/usecases/get_random_number_trivia_usecase.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive  integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTriviaUsecase getConcreteNumberTriviaUsecase;
  final GetRandomNumberTriviaUsecase getRandomNumberTriviaUsecase;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required this.getConcreteNumberTriviaUsecase,
      required this.getRandomNumberTriviaUsecase,
      required this.inputConverter})
      : super(Empty()) {
    on<NumberTriviaEvent>((event, emit) async {
      if (event is GetTriviaForConcreteNumber) {
        final inputEither =
            inputConverter.StringToUnsignedInt(event.numberString);
        inputEither.fold((failure) {
          emit(Error(errorMessage: _mapFailureToMessage(failure)));
        }, (number) async {
          emit(Loading());
          final failureOrTrivia =
              await getConcreteNumberTriviaUsecase.call(Params(number: number));
          emit.isDone;
          emit(failureOrTrivia.fold(
              (failure) => Error(errorMessage: _mapFailureToMessage(failure)),
              (numberTrivia) => Loaded(triviaEntity: numberTrivia)));
        });
      }
      if (event is GetTriviaForRandomNumber) {
        emit(Loading());
        final failureOrTrivia = await getRandomNumberTriviaUsecase(NoParams());
        emit(failureOrTrivia.fold(
            (failure) => Error(errorMessage: _mapFailureToMessage(failure)),
            (numberTrivia) => Loaded(triviaEntity: numberTrivia)));
      }
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case InvalidInputFailure:
        return invalidInputFailureMessage;
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture_reso/core/util/input_converter.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/entities/number_trivia_entity.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/usecases/get_concrete_number_trivia_usecase.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/usecases/get_random_number_trivia_usecase.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTriviaUsecase {}

class MockGetRandomNumberTrivia extends Mock
    implements GetRandomNumberTriviaUsecase {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc numberTriviaBloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    numberTriviaBloc = NumberTriviaBloc(
        getConcreteNumberTriviaUsecase: mockGetConcreteNumberTrivia,
        getRandomNumberTriviaUsecase: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });
  test('initialState should be Empty', () {
    expect(numberTriviaBloc.state, equals(Empty()));
  });
  group('getTriviaForConcreteGroup', () {
    final tNumberString = '1';
    final tNumberParse = 1;
    final tNumberTriviaEntity = NumberTriviaEntity(text: 'text', number: 1);
    test(
        'should call the InputConverter to validate and convert the String to an unsign int',
        () async {
      when(() => mockInputConverter.StringToUnsignedInt(any()))
          .thenAnswer((invocation) => right(tNumberParse));
      numberTriviaBloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockInputConverter.StringToUnsignedInt(any()));
      verify(() => mockInputConverter.StringToUnsignedInt(tNumberString));
    });
    test('The bloc should emit [Error] when the input is invalid', () async {
      when(() => mockInputConverter.StringToUnsignedInt(any()))
          .thenAnswer((invocation) => left(InvalidInputFailure()));
      final expected = [
        Empty(),
        const Error(errorMessage: invalidInputFailureMessage)
      ];
      await expectLater(() => numberTriviaBloc.stream.listen((event) {}),
          emitsInOrder(expected));
      numberTriviaBloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });
}

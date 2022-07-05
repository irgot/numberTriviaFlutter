import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture_reso/core/error/failures.dart';
import 'package:tdd_clean_architecture_reso/core/usecases/usecase.dart';
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

class FakeParams extends Fake implements Params {}

class FakeNoParams extends Fake implements NoParams {}

class MyMockBloc extends MockBloc<NumberTriviaEvent, NumberTriviaState>
    implements NumberTriviaBloc {}

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

    registerFallbackValue(FakeParams());
    registerFallbackValue(FakeNoParams());
  });
  test('initialState should be Empty', () {
    expect(numberTriviaBloc.state, equals(Empty()));
  });
  group('getTriviaForConcreteGroup', () {
    const tNumberString = '1';
    const tNumberParse = 1;
    final tNumberTriviaEntity = NumberTriviaEntity(text: 'text', number: 1);
    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.StringToUnsignedInt(any()))
            .thenReturn(right(tNumberParse));
    void setUpMockGetConcreteNumberTrivia() =>
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((invocation) async => right(tNumberTriviaEntity));
    void setUpMockGetConcreteNumberTriviaServerFailure() =>
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((invocation) async => left(ServerFailure()));
    void setUpMockGetConcreteNumberTriviaCacheFailure() =>
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((invocation) async => left(CacheFailure()));
    test(
        'should call the InputConverter to validate and convert the String to an unsign int',
        () async {
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTrivia();
      numberTriviaBloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockInputConverter.StringToUnsignedInt(any()));
      verify(() => mockInputConverter.StringToUnsignedInt(tNumberString));
    });
    test('The bloc should emit [Error] when the input is invalid', () async {
      when(() => mockInputConverter.StringToUnsignedInt(any()))
          .thenAnswer((invocation) => left(InvalidInputFailure()));
      expect(numberTriviaBloc.state, equals(Empty()));
      numberTriviaBloc.add(GetTriviaForConcreteNumber(tNumberString));
      final expected = [const Error(errorMessage: invalidInputFailureMessage)];
      await expectLater(numberTriviaBloc.stream, emitsInOrder(expected));
    });
    test('should get data from the concrete usecase', () async {
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTrivia();
      numberTriviaBloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockGetConcreteNumberTrivia(any()));
      verify(() =>
          mockGetConcreteNumberTrivia(const Params(number: tNumberParse)));
    });
    blocTest('should emit [Loading, Loaded] when data is gotten successfully',
        build: () => numberTriviaBloc,
        act: (NumberTriviaBloc bloc) {
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTrivia();
          return bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
        expect: () => [Loading(), Loaded(triviaEntity: tNumberTriviaEntity)],
        tearDown: () => numberTriviaBloc.close());
    blocTest(
        'should emit [Loading, Error] when data is not gotten successfully',
        build: () => numberTriviaBloc,
        act: (NumberTriviaBloc bloc) {
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaServerFailure();
          return bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
        expect: () =>
            [Loading(), const Error(errorMessage: serverFailureMessage)],
        tearDown: () => numberTriviaBloc.close());
    blocTest(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        build: () => numberTriviaBloc,
        act: (NumberTriviaBloc bloc) {
          setUpMockInputConverterSuccess();
          setUpMockGetConcreteNumberTriviaCacheFailure();
          return bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
        expect: () =>
            [Loading(), const Error(errorMessage: cacheFailureMessage)],
        tearDown: () => numberTriviaBloc.close());
  });
  group('getTriviaForRandomGroup', () {
    final tNumberTriviaEntity = NumberTriviaEntity(text: 'text', number: 1);
    void setUpMockGetRandomNumberTrivia() =>
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((invocation) async => right(tNumberTriviaEntity));
    void setUpMockGetRandomNumberTriviaServerFailure() =>
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((invocation) async => left(ServerFailure()));
    void setUpMockGetRandomNumberTriviaCacheFailure() =>
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((invocation) async => left(CacheFailure()));
    test('should get data from the Random usecase', () async {
      setUpMockGetRandomNumberTrivia();
      numberTriviaBloc.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia(any()));
      verify(() => mockGetRandomNumberTrivia.call(any()));
    });
    blocTest('should emit [Loading, Loaded] when data is gotten successfully',
        build: () => numberTriviaBloc,
        act: (NumberTriviaBloc bloc) {
          setUpMockGetRandomNumberTrivia();
          return bloc.add(GetTriviaForRandomNumber());
        },
        expect: () => [Loading(), Loaded(triviaEntity: tNumberTriviaEntity)],
        tearDown: () => numberTriviaBloc.close());
    blocTest(
        'should emit [Loading, Error] when data is not gotten successfully',
        build: () => numberTriviaBloc,
        act: (NumberTriviaBloc bloc) {
          setUpMockGetRandomNumberTriviaServerFailure();
          return bloc.add(GetTriviaForRandomNumber());
        },
        expect: () =>
            [Loading(), const Error(errorMessage: serverFailureMessage)],
        tearDown: () => numberTriviaBloc.close());
    blocTest(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        build: () => numberTriviaBloc,
        act: (NumberTriviaBloc bloc) {
          setUpMockGetRandomNumberTriviaCacheFailure();
          return bloc.add(GetTriviaForRandomNumber());
        },
        expect: () =>
            [Loading(), const Error(errorMessage: cacheFailureMessage)],
        tearDown: () => numberTriviaBloc.close());
  });
}

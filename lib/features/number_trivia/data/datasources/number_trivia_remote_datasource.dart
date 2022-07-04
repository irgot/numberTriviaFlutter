import 'package:dio/dio.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/models/number_trivia_model.dart';

const baseUrl = 'http://numbersapi.com';
const getRandomNumberTriviaUrl = 'http://numbersapi.com/random?json';

abstract class NumberTriviaRemoteDatasource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  ///Calls the http://numbersapi.com/random endpoint.
  ///
  ///Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDatasourceImpl implements NumberTriviaRemoteDatasource {
  final Dio dio;

  NumberTriviaRemoteDatasourceImpl(this.dio);
  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    final response = await dio.getUri(Uri.parse('$baseUrl/$number'));
    return NumberTriviaModel.fromJson(response.data);
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    // TODO: implement getRandomNumberTrivia
    throw UnimplementedError();
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:tdd_clean_architecture_reso/core/error/exceptions.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/models/number_trivia_model.dart';

const baseUrl = 'http://numbersapi.com';
const getRandomNumberTriviaUrl = 'http://numbersapi.com/random';

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
  final Client httpClient;
  final _headers = {'content-type': 'application/json'};

  NumberTriviaRemoteDatasourceImpl(this.httpClient);
  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return _getTriviaFromUrl('$baseUrl/$number');
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    return _getTriviaFromUrl('$baseUrl/random');
  }

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final response = await httpClient.get(Uri.parse(url), headers: _headers);
    if (response.statusCode != 200) throw ServerException();
    return NumberTriviaModel.fromJson(jsonDecode(response.body));
  }
}

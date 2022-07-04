import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture_reso/core/error/exceptions.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalDatasource {
  /// Gets the cached [NumberTriviaModel] wich was gotten the last time
  /// the user had an internet connection
  ///
  /// Throws [NoLocalDataException] if no cached data is present.
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

const cachedNumberTrivia = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDatasourceImpl implements NumberTriviaLocalDatasource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDatasourceImpl(this.sharedPreferences);

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() async {
    final numberTriviaJson = sharedPreferences.getString(cachedNumberTrivia);
    if (numberTriviaJson == null || numberTriviaJson.isEmpty) {
      throw CacheException();
    }
    final numberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(numberTriviaJson));
    return numberTriviaModel;
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) async {
    final jsonNumberTrivia = jsonEncode(triviaToCache.toJson());
    await sharedPreferences.setString(cachedNumberTrivia, jsonNumberTrivia);
  }
}

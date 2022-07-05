import 'package:dartz/dartz.dart';
import 'package:tdd_clean_architecture_reso/core/error/failures.dart';

class InputConverter {
  Either<Failure, int> StringToUnsignedInt(String str) {
    try {
      final result = int.parse(str);
      if (result < 0) throw FormatException();
      return right(result);
    } on FormatException {
      return left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure {
  @override
  List<Object?> get props => [];
}

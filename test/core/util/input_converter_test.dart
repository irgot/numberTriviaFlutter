import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture_reso/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;
  setUp(() {
    inputConverter = InputConverter();
  });

  group('StringToUnsignedInt', () {
    test('should return an int when the string represents an unsigned integer',
        () {
      const str = '1';
      final result = inputConverter.StringToUnsignedInt(str);
      expect(result, right(1));
    });
    test(
        'should return left InvalidInputFailure when the string not represents an unsigned integer',
        () {
      const str = 'a1';
      final result = inputConverter.StringToUnsignedInt(str);
      expect(result, left(InvalidInputFailure()));
    });
    test(
        'should return left an InvalidInputFailure when the string represents an negative number',
        () {
      const str = '-1';
      final result = inputConverter.StringToUnsignedInt(str);
      expect(result, left(InvalidInputFailure()));
    });
  });
}

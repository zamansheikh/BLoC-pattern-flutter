import 'package:flutter_test/flutter_test.dart';
import 'package:blocpatternflutter/features/home/domain/entities/counter.dart';
import 'package:blocpatternflutter/features/home/data/models/counter_model.dart';

void main() {
  group('Counter Model Tests', () {
    test('should create a counter model from entity', () {
      // Arrange
      final counter = Counter(value: 5, lastUpdated: DateTime(2025, 6, 12));

      // Act
      final counterModel = CounterModel.fromEntity(counter);

      // Assert
      expect(counterModel.value, equals(5));
      expect(counterModel.lastUpdated, equals(DateTime(2025, 6, 12)));
    });

    test('should convert counter model to entity', () {
      // Arrange
      final counterModel = CounterModel(
        value: 10,
        lastUpdated: DateTime(2025, 6, 12),
      );

      // Act
      final counter = counterModel.toEntity();

      // Assert
      expect(counter.value, equals(10));
      expect(counter.lastUpdated, equals(DateTime(2025, 6, 12)));
      expect(counter.runtimeType, equals(Counter));
    });

    test('should serialize and deserialize from JSON', () {
      // Arrange
      final counterModel = CounterModel(
        value: 15,
        lastUpdated: DateTime(2025, 6, 12),
      );

      // Act
      final json = counterModel.toJson();
      final fromJson = CounterModel.fromJson(json);

      // Assert
      expect(fromJson.value, equals(15));
      expect(fromJson.lastUpdated, equals(DateTime(2025, 6, 12)));
    });

    test('should have proper equality', () {
      // Arrange
      final counter1 = Counter(value: 20, lastUpdated: DateTime(2025, 6, 12));
      final counter2 = Counter(value: 20, lastUpdated: DateTime(2025, 6, 12));

      // Assert
      expect(counter1, equals(counter2));
      expect(counter1.hashCode, equals(counter2.hashCode));
    });
  });
}

import 'package:app/features/reflection/domain/entities/reflection_entity.dart';

/// Abstract reflection repository.
abstract class ReflectionRepository {
  Stream<List<ReflectionEntity>> watchReflections(String userId);
  Future<void> saveReflection(ReflectionEntity reflection);
  Future<ReflectionEntity?> getReflectionByDate(String userId, DateTime date);
  Future<List<ReflectionEntity>> getRecentReflections(String userId, int limit);
}

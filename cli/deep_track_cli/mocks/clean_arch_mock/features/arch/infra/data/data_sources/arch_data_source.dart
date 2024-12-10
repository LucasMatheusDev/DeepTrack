import '../../../domain/entities/arch_entity.dart';

abstract class DataSource {
  
  Future<List<ArchEntity>> getArchEntities();
}

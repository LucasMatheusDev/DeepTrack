import '../../../domain/entities/arch_entity.dart';
import '../../../infra/data/data_sources/arch_data_source.dart';

class DataSourceImpl implements DataSource {
  @override
  Future<List<ArchEntity>> getArchEntities() async {
    return [
      ArchEntity(),
    ];
  }
}

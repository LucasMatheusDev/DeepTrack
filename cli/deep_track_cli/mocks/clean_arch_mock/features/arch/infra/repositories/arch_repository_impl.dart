import '../../domain/entities/arch_entity.dart';
import '../../domain/repositories/arch_repository.dart';
import '../data/data_sources/arch_data_source.dart';

class RepositoryImpl extends Repository {
  final DataSource dataSource;

  @override
  final ArchEntity entity;

  RepositoryImpl(
    this.dataSource,
    this.entity,
  ) : super(entity);
}

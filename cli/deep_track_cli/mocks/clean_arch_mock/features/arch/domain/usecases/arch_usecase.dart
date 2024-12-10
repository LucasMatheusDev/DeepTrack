import '../entities/arch_entity.dart';
import '../repositories/arch_repository.dart';

final ArchEntity value = ArchEntity();

final repository = Repository(value);

class	Usecase {
  final Repository repository;

  Usecase(this.repository);

  Future<ArchEntity> getArchEntities() async {
    return value;
  }
}
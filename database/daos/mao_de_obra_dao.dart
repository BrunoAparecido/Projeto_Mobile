import 'package:drift/drift.dart';
import 'package:lotus_mobile/database/tables/mao_de_obra_table.dart';
import '../database.dart';

part 'mao_de_obra_dao.g.dart';

@DriftAccessor(tables: [MaoDeObra])
class MaoDeObraDao extends DatabaseAccessor<AppDatabase> with _$MaoDeObraDaoMixin {
  final AppDatabase db;
  MaoDeObraDao(this.db) : super(db);

  Future<int> inserirMaoDeObra({
    required String uid,
    required String descricao,
    required int statusTipoMaoDeObraEnum,
  }) {
    return into(maoDeObra).insertOnConflictUpdate(
      MaoDeObraCompanion(
        uid: Value(uid),
        descricao: Value(descricao),
        statusTipoMaoDeObraEnum: Value(statusTipoMaoDeObraEnum),
      ),
    );
  }

  Future<int> atualizarMaoDeObra({
    required String uid,
    String? descricao,
    int? statusTipoMaoDeObraEnum,
  }) {
    return (update(maoDeObra)..where((c) => c.uid.equals(uid)))
        .write(
      MaoDeObraCompanion(
        descricao: descricao != null ? Value(descricao) : Value.absent(),
        statusTipoMaoDeObraEnum: statusTipoMaoDeObraEnum != null ? Value(statusTipoMaoDeObraEnum) : Value.absent(),
      ),
    );
  }

  Future<List<MaoDeObraData>> getAllMaoDeObras() => select(maoDeObra).get();

  Future<MaoDeObraData?> getByUid(String uid) {
    return (select(maoDeObra)..where((tbl) => tbl.uid.equals(uid))).getSingleOrNull();
  }

  Future<int> clearMaoDeObra() => delete(maoDeObra).go();
}
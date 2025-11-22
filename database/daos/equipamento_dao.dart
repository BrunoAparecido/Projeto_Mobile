import 'package:drift/drift.dart';
import 'package:lotus_mobile/database/tables/equipamento_table.dart';
import '../database.dart';

part 'equipamento_dao.g.dart';

@DriftAccessor(tables: [Equipamento])
class EquipamentoDao extends DatabaseAccessor<AppDatabase> with _$EquipamentoDaoMixin {
  final AppDatabase db;
  EquipamentoDao(this.db) : super(db);

  Future<int> inserirEquipamento({
    required String uid,
    required String nomeEquipamento,
  }) {
    return into(equipamento).insertOnConflictUpdate(
      EquipamentoCompanion(
        uid: Value(uid),
        nomeEquipamento: Value(nomeEquipamento),
      ),
    );
  }

  Future<int> atualizarEquipamento({
    required String uid,
    String? nomeEquipamento
  }) {
    return (update(equipamento)..where((c) => c.uid.equals(uid)))
        .write(
      EquipamentoCompanion(
        nomeEquipamento: nomeEquipamento != null ? Value(nomeEquipamento) : Value.absent(),
      ),
    );
  }

  Future<List<EquipamentoData>> getAllEquipamentos() => select(equipamento).get();

  Future<EquipamentoData?> getByUid(String uid) {
    return (select(equipamento)..where((tbl) => tbl.uid.equals(uid))).getSingleOrNull();
  }

  Future<int> clearEquipamento() => delete(equipamento).go();
}
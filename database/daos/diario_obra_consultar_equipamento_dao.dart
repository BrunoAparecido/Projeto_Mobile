import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_consultar_equipamento_table.dart';

part 'diario_obra_consultar_equipamento_dao.g.dart';

@DriftAccessor(tables: [DiarioObraConsultarEquipamento])
class DiarioObraConsultarEquipamentoDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraConsultarEquipamentoDaoMixin {
  final AppDatabase db;
  DiarioObraConsultarEquipamentoDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraConsultarEquipamento({
    required String uid,
    required String diarioObraConsultarUid,
    required String equipamentoUid,
    required String status,
    required String dataHoraInclusao,
  }) {
    return into(diarioObraConsultarEquipamento).insertOnConflictUpdate(
      DiarioObraConsultarEquipamentoCompanion(
        uid: Value(uid),
        diarioObraConsultarUid: Value(diarioObraConsultarUid),
        equipamentoUid: Value(equipamentoUid),
        status: Value(status),
        dataHoraInclusao: Value(dataHoraInclusao),
      ),
    );
  }

  Future<int> atualizarDiarioObraConsultarEquipamento({
    required String uid,
    String? diarioObraConsultarUid,
    String? equipamentoUid,
    String? status,
    String? dataHoraInclusao,
  }) {
    return (update(diarioObraConsultarEquipamento)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraConsultarEquipamentoCompanion(
        diarioObraConsultarUid: diarioObraConsultarUid != null ? Value(diarioObraConsultarUid) : Value.absent(),
        equipamentoUid: equipamentoUid != null ? Value(equipamentoUid) : Value.absent(),
        status: status != null ? Value(status) : Value.absent(), 
        dataHoraInclusao: dataHoraInclusao != null ? Value(dataHoraInclusao) : Value.absent(), 
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraConsultarEquipamentoData>> getAllDiarioObraConsultarEquipamento() => select(diarioObraConsultarEquipamento).get();

  Future<List<DiarioObraConsultarEquipamentoData>> buscarPorDiarioObraConsultar(
      String consultarUid) {
    return (select(diarioObraConsultarEquipamento)
      ..where((tbl) => tbl.diarioObraConsultarUid.equals(consultarUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraConsultarEquipamentoData?> getByUid(String uid) {
    return (select(diarioObraConsultarEquipamento)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraConsultarEquipamentos() => delete(diarioObraConsultarEquipamento).go();
}
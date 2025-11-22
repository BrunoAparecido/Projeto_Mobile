import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_apontamento_table.dart';

part 'diario_obra_apontamento_dao.g.dart';

@DriftAccessor(tables: [DiarioObraApontamento])
class DiarioObraApontamentoDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraApontamentoDaoMixin {
  final AppDatabase db;
  DiarioObraApontamentoDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraApontamento({
    required String uid,
    String? diarioObraUid,
    String? projetoEmpresaUid,
    String? maoDeObraUid,
    String? equipamentoUid, 
    String? subcontratadaUid,
    required int valorApontamento,
    required String dataHoraInclusao,
  }) {
    return into(diarioObraApontamento).insertOnConflictUpdate(
      DiarioObraApontamentoCompanion(
        uid: Value(uid),
        diarioObraUid: Value(diarioObraUid),
        projetoEmpresaUid: Value(projetoEmpresaUid),
        maoDeObraUid: Value(maoDeObraUid),
        equipamentoUid: Value(equipamentoUid),
        subcontratadaUid: Value(subcontratadaUid),
        valorApontamento: Value(valorApontamento),
        dataHoraInclusao: Value(dataHoraInclusao),
      ),
    );
  }

  Future<int> atualizarDiarioObraApontamento({
    required String uid,
    String? diarioObraUid,
    String? projetoEmpresaUid,
    String? maoDeObraUid,
    String? equipamentoUid,
    String? subcontratadaUid, 
    int? valorApontamento,
    String? dataHoraInclusao,
  }) {
    return (update(diarioObraApontamento)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraApontamentoCompanion(
        diarioObraUid: diarioObraUid != null ? Value(diarioObraUid) : Value.absent(),
        projetoEmpresaUid: projetoEmpresaUid != null ? Value(projetoEmpresaUid) : Value.absent(),
        maoDeObraUid: maoDeObraUid != null ? Value(maoDeObraUid) : Value.absent(),
        equipamentoUid: equipamentoUid != null ? Value(equipamentoUid) : Value.absent(),
        subcontratadaUid: subcontratadaUid != null ? Value(subcontratadaUid) : Value.absent(),
        valorApontamento: valorApontamento != null ? Value(valorApontamento) : Value.absent(),
        dataHoraInclusao: dataHoraInclusao != null ? Value(dataHoraInclusao) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraApontamentoData>> getAllDiarioObraApontamento() => select(diarioObraApontamento).get();

  Future<List<DiarioObraApontamentoData>> buscarPorDiarioObra(
      String diarioObraUid) {
    return (select(diarioObraApontamento)
      ..where((tbl) => tbl.diarioObraUid.equals(diarioObraUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraApontamentoData?> getByUid(String uid) {
    return (select(diarioObraApontamento)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraApontamento() => delete(diarioObraApontamento).go();
}
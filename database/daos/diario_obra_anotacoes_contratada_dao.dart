import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_anotacoes_contratada_table.dart';

part 'diario_obra_anotacoes_contratada_dao.g.dart';

@DriftAccessor(tables: [DiarioObraAnotacoesContratada])
class DiarioObraAnotacoesContratadaDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraAnotacoesContratadaDaoMixin {
  final AppDatabase db;
  DiarioObraAnotacoesContratadaDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraAnotacoesContratada({
    required String uid,
    String? obraUid,
    String? diarioObraUid,
    required String anotacao, 
    required DateTime data,
    required String dataHoraInclusao,
  }) {
    return into(diarioObraAnotacoesContratada).insertOnConflictUpdate(
      DiarioObraAnotacoesContratadaCompanion(
        uid: Value(uid),
        obraUid: Value(obraUid),
        diarioObraUid: Value(diarioObraUid),
        anotacao: Value(anotacao),
        data: Value(data),
        dataHoraInclusao: Value(dataHoraInclusao),
      ),
    );
  }

  Future<int> atualizarDiarioObraAnotacoesContratada({
    required String uid,
    String? obraUid,
    String? diarioObraUid,
    String? anotacao, 
    DateTime? data,
    String? dataHoraInclusao,
  }) {
    return (update(diarioObraAnotacoesContratada)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraAnotacoesContratadaCompanion(
        obraUid: obraUid != null ? Value(obraUid) : Value.absent(),
        diarioObraUid: diarioObraUid != null ? Value(diarioObraUid) : Value.absent(),
        anotacao: anotacao != null ? Value(anotacao) : Value.absent(),
        data: data != null ? Value(data) : Value.absent(),
        dataHoraInclusao: dataHoraInclusao != null ? Value(dataHoraInclusao) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraAnotacoesContratadaData>> getAllDiarioObraAnotacoesContratada() => select(diarioObraAnotacoesContratada).get();

  Future<List<DiarioObraAnotacoesContratadaData>> buscarPorDiarioObra(
      String diarioObraUid) {
    return (select(diarioObraAnotacoesContratada)
      ..where((tbl) => tbl.diarioObraUid.equals(diarioObraUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraAnotacoesContratadaData?> getByUid(String uid) {
    return (select(diarioObraAnotacoesContratada)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraAnotacoesContratada() => delete(diarioObraAnotacoesContratada).go();
}
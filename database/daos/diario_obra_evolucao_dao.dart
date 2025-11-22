import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_evolucao_table.dart';

part 'diario_obra_evolucao_dao.g.dart';

@DriftAccessor(tables: [DiarioObraEvolucao])
class DiarioObraEvolucaoDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraEvolucaoDaoMixin {
  final AppDatabase db;
  DiarioObraEvolucaoDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraEvolucao({
    required String uid,
    String? obraUid,
    String? diarioObraUid,
    required String evolucao, 
    required int numero,
    required int sequencial,
    required String dataHoraInclusao,
  }) {
    return into(diarioObraEvolucao).insertOnConflictUpdate(
      DiarioObraEvolucaoCompanion(
        uid: Value(uid),
        obraUid: Value(obraUid),
        diarioObraUid: Value(diarioObraUid),
        evolucao: Value(evolucao),
        numero: Value(numero),
        sequencial: Value(sequencial),
        dataHoraInclusao: Value(dataHoraInclusao),
      ),
    );
  }

  Future<int> atualizarDiarioObraEvolucao({
    required String uid,
    String? obraUid,
    String? diarioObraUid,
    String? evolucao, 
    int? numero,
    int? sequencial,
    String? dataHoraInclusao,
  }) {
    return (update(diarioObraEvolucao)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraEvolucaoCompanion(
        obraUid: obraUid != null ? Value(obraUid) : Value.absent(),
        diarioObraUid: diarioObraUid != null ? Value(diarioObraUid) : Value.absent(),
        evolucao: evolucao != null ? Value(evolucao) : Value.absent(),
        numero: numero != null ? Value(numero) : Value.absent(),
        sequencial: sequencial != null ? Value(sequencial) : Value.absent(),
        dataHoraInclusao: dataHoraInclusao != null ? Value(dataHoraInclusao) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraEvolucaoData>> getAllDiarioObraEvolucao() => select(diarioObraEvolucao).get();

  Future<List<DiarioObraEvolucaoData>> buscarPorDiarioObra(String diarioObraUid) {
    return (select(diarioObraEvolucao)
      ..where((tbl) => tbl.diarioObraUid.equals(diarioObraUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraEvolucaoData?> getByUid(String uid) {
    return (select(diarioObraEvolucao)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraEvolucao() => delete(diarioObraEvolucao).go();
}
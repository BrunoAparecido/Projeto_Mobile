import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_anotacoes_gerenciadora_table.dart';

part 'diario_obra_anotacoes_gerenciadora_dao.g.dart';

@DriftAccessor(tables: [DiarioObraAnotacoesGerenciadora])
class DiarioObraAnotacoesGerenciadoraDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraAnotacoesGerenciadoraDaoMixin {
  final AppDatabase db;
  DiarioObraAnotacoesGerenciadoraDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraAnotacoesGerenciadora({
    required String uid,
    String? obraUid,
    String? diarioObraUid,
    required String anotacao, 
    required DateTime data,
    required String dataHoraInclusao,
  }) {
    return into(diarioObraAnotacoesGerenciadora).insertOnConflictUpdate(
      DiarioObraAnotacoesGerenciadoraCompanion(
        uid: Value(uid),
        obraUid: Value(obraUid),
        diarioObraUid: Value(diarioObraUid),
        anotacao: Value(anotacao),
        data: Value(data),
        dataHoraInclusao: Value(dataHoraInclusao),
      ),
    );
  }

  Future<int> atualizarDiarioObraAnotacoesGerenciadora({
    required String uid,
    String? usuarioResponsavelUid,
    String? obraUid,
    String? diarioObraUid,
    String? anotacao, 
    DateTime? data,
    String? dataHoraInclusao,
  }) {
    return (update(diarioObraAnotacoesGerenciadora)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraAnotacoesGerenciadoraCompanion(
        obraUid: obraUid != null ? Value(obraUid) : Value.absent(),
        diarioObraUid: diarioObraUid != null ? Value(diarioObraUid) : Value.absent(),
        anotacao: anotacao != null ? Value(anotacao) : Value.absent(),
        data: data != null ? Value(data) : Value.absent(),
        dataHoraInclusao: dataHoraInclusao != null ? Value(dataHoraInclusao) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraAnotacoesGerenciadoraData>> getAllDiarioObraAnotacoesGerenciadora() => select(diarioObraAnotacoesGerenciadora).get();

  Future<List<DiarioObraAnotacoesGerenciadoraData>> buscarPorDiarioObra(
      String diarioObraUid) {
    return (select(diarioObraAnotacoesGerenciadora)
      ..where((tbl) => tbl.diarioObraUid.equals(diarioObraUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraAnotacoesGerenciadoraData?> getByUid(String uid) {
    return (select(diarioObraAnotacoesGerenciadora)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraAnotacoesGerenciadora() => delete(diarioObraAnotacoesGerenciadora).go();
}
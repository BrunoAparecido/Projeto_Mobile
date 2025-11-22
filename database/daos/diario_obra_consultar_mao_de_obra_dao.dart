import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_consultar_mao_de_obra_table.dart';

part 'diario_obra_consultar_mao_de_obra_dao.g.dart';

@DriftAccessor(tables: [DiarioObraConsultarMaoDeObra])
class DiarioObraConsultarMaoDeObraDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraConsultarMaoDeObraDaoMixin {
  final AppDatabase db;
  DiarioObraConsultarMaoDeObraDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraConsultarMaoDeObra({
    required String uid,
    required String diarioObraConsultarUid,
    required String maoDeObraUid,
    required String status,
    required String dataHoraInclusao,
  }) {
    return into(diarioObraConsultarMaoDeObra).insertOnConflictUpdate(
      DiarioObraConsultarMaoDeObraCompanion(
        uid: Value(uid),
        diarioObraConsultarUid: Value(diarioObraConsultarUid),
        maoDeObraUid: Value(maoDeObraUid),
        status: Value(status),
        dataHoraInclusao: Value(dataHoraInclusao),
      ),
    );
  }

  Future<int> atualizarDiarioObraConsultarMaoDeObra({
    required String uid,
    String? diarioObraConsultarUid,
    String? maoDeObraUid,
    String? status,
    String? dataHoraInclusao,
  }) {
    return (update(diarioObraConsultarMaoDeObra)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraConsultarMaoDeObraCompanion(
        diarioObraConsultarUid: diarioObraConsultarUid != null ? Value(diarioObraConsultarUid) : Value.absent(),
        maoDeObraUid: maoDeObraUid != null ? Value(maoDeObraUid) : Value.absent(),
        status: status != null ? Value(status) : Value.absent(),
        dataHoraInclusao: dataHoraInclusao != null ? Value(dataHoraInclusao) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraConsultarMaoDeObraData>> getAllDiarioObraConsultarMaoDeObra() => select(diarioObraConsultarMaoDeObra).get();

  Future<List<DiarioObraConsultarMaoDeObraData>> buscarPorDiarioObraConsultar(
      String consultarUid) {
    return (select(diarioObraConsultarMaoDeObra)
      ..where((tbl) => tbl.diarioObraConsultarUid.equals(consultarUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraConsultarMaoDeObraData?> getByUid(String uid) {
    return (select(diarioObraConsultarMaoDeObra)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraConsultarMaoDeObras() => delete(diarioObraConsultarMaoDeObra).go();
}
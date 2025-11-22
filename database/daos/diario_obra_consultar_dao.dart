import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_consultar_table.dart';

part 'diario_obra_consultar_dao.g.dart';

@DriftAccessor(tables: [DiarioObraConsultar])
class DiarioObraConsultarDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraConsultarDaoMixin {
  final AppDatabase db;
  DiarioObraConsultarDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraConsultar({
    required String uid,
    required String obraUid,
    required String obraContratadoUid,
    required String projetoUid, 
  }) {
    return into(diarioObraConsultar).insertOnConflictUpdate(
      DiarioObraConsultarCompanion(
        uid: Value(uid),
        obraUid: Value(obraUid),
        obraContratadoUid: Value(obraContratadoUid),
        projetoUid: Value(projetoUid),
      ),
    );
  }

  Future<int> atualizarDiarioObraConsultar({
    required String uid,
    String? obraUid,
    String? obraContratadoUid,
    String? projetoUid,
  }) {
    return (update(diarioObraConsultar)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraConsultarCompanion(
        obraUid: obraUid != null ? Value(obraUid) : Value.absent(),
        obraContratadoUid: obraContratadoUid != null ? Value(obraContratadoUid) : Value.absent(),
        projetoUid: projetoUid != null ? Value(projetoUid) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraConsultarData>> getAllDiarioObraConsultar() => select(diarioObraConsultar).get();

  /// Busca login por UID
  Future<DiarioObraConsultarData?> getByUid(String uid) {
    return (select(diarioObraConsultar)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraConsultar() => delete(diarioObraConsultar).go();
}
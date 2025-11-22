import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_anexo_table.dart';

part 'diario_obra_anexo_dao.g.dart';

@DriftAccessor(tables: [DiarioObraAnexo])
class DiarioObraAnexoDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraAnexoDaoMixin {
  final AppDatabase db;
  DiarioObraAnexoDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraAnexo({
    required String uid,
    String? diarioObraUid,
    required String descricao, 
    required String guidControleUpload,
    required bool uploadComplete,
  }) {
    return into(diarioObraAnexo).insertOnConflictUpdate(
      DiarioObraAnexoCompanion(
        uid: Value(uid),
        diarioObraUid: Value(diarioObraUid),
        descricao: Value(descricao),
        guidControleUpload: Value(guidControleUpload),
        uploadComplete: Value(uploadComplete),
      ),
    );
  }

  Future<int> atualizarDiarioObraAnexo({
    required String uid,
    String? diarioObraUid,
    String? descricao, 
    String? guidControleUpload,
    bool? uploadComplete,
  }) {
    return (update(diarioObraAnexo)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraAnexoCompanion(
        diarioObraUid: diarioObraUid != null ? Value(diarioObraUid) : Value.absent(),
        descricao: descricao != null ? Value(descricao) : Value.absent(),
        guidControleUpload: guidControleUpload != null ? Value(guidControleUpload) : Value.absent(),
        uploadComplete: uploadComplete != null ? Value(uploadComplete) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraAnexoData>> getAllDiarioObraAnexo() => select(diarioObraAnexo).get();

  Future<List<DiarioObraAnexoData>> buscarPorDiarioObra(String diarioObraUid) {
    return (select(diarioObraAnexo)
      ..where((tbl) => tbl.diarioObraUid.equals(diarioObraUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraAnexoData?> getByUid(String uid) {
    return (select(diarioObraAnexo)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraAnexo() => delete(diarioObraAnexo).go();

  Future<List<DiarioObraAnexoData>> buscarPorGuidControleUpload(
    String guid,
  ) async {
    return (select(diarioObraAnexo)
          ..where((tbl) => tbl.guidControleUpload.equals(guid)))
        .get();
  }
}


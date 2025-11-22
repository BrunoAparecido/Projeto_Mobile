import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/obra_table.dart';

part 'obra_dao.g.dart';

@DriftAccessor(tables: [Obra])
class ObraDao extends DatabaseAccessor<AppDatabase> with _$ObraDaoMixin {
  final AppDatabase db;
  ObraDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirObra({
    required String uid,
    required String nomeObra,
    required String projetoUid,
    required String contatoResponsavelUid,
  }) {
    return into(obra).insertOnConflictUpdate(
      ObraCompanion(
        uid: Value(uid),
        nomeObra: Value(nomeObra),
        projetoUid: Value(projetoUid),
        contatoResponsavelUid: Value(contatoResponsavelUid),
      ),
    );
  }

  Future<int> atualizarObra({
    required String uid,
    String? nomeObra,
    String? projetoUid,
    String? contatoResponsavelUid,
  }) {
    return (update(obra)..where((c) => c.uid.equals(uid)))
        .write(
      ObraCompanion(
        nomeObra: nomeObra != null ? Value(nomeObra) : Value.absent(),
        projetoUid: projetoUid != null ? Value(projetoUid) : Value.absent(),
        contatoResponsavelUid: contatoResponsavelUid != null ? Value(contatoResponsavelUid) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<ObraData>> getAllObras() => select(obra).get();

  /// Busca login por UID
  Future<ObraData?> getByUid(String uid) {
    return (select(obra)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearObras() => delete(obra).go();

}
import 'package:drift/drift.dart';
import 'package:lotus_mobile/database/tables/contato_table.dart';
import '../database.dart';

part 'contato_dao.g.dart';

@DriftAccessor(tables: [Contato])
class ContatoDao extends DatabaseAccessor<AppDatabase> with _$ContatoDaoMixin {
  final AppDatabase db;
  ContatoDao(this.db) : super(db);

  Future<int> inserirContato({
  required String uid,
  required int pronomeEnum,
  required String nome,
  required String ultimoNome,
  required bool grupoLotus,
}) {
  return into(contato).insertOnConflictUpdate(
    ContatoCompanion(
      uid: Value(uid),
      pronomeEnum: Value(pronomeEnum),
      nome: Value(nome),
      ultimoNome: Value(ultimoNome),
      grupoLotus: Value(grupoLotus),
    ),
  );
}

  Future<int> atualizarContato({
    required String uid,
    int? pronomeEnum,
    String? nome,
    String? ultimoNome,
    bool? grupoLotus,
  }) {
    return (update(contato)..where((c) => c.uid.equals(uid)))
        .write(
      ContatoCompanion(
        pronomeEnum: pronomeEnum != null ? Value(pronomeEnum) : Value.absent(),
        nome: nome != null ? Value(nome) : Value.absent(),
        ultimoNome: ultimoNome != null ? Value(ultimoNome) : Value.absent(),
        grupoLotus: grupoLotus != null ? Value(grupoLotus) : Value.absent(),
      ),
    );
  }

  Future<List<ContatoData>> getAllContatos() => select(contato).get();

  Future<ContatoData?> getByUid(String uid) {
    return (select(contato)..where((tbl) => tbl.uid.equals(uid))).getSingleOrNull();
  }

  Future<int> clearContatos() => delete(contato).go();
}
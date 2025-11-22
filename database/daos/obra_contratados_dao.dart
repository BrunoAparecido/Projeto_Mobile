import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/obra_contratados_table.dart';

part 'obra_contratados_dao.g.dart';

@DriftAccessor(tables: [ObraContratados])
class ObraContratadosDao extends DatabaseAccessor<AppDatabase> with _$ObraContratadosDaoMixin {
  final AppDatabase db;
  ObraContratadosDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirObraContratados({
    required String uid,
    required String projetoEmpresaUid,
    required String obraUid,
    required String escopo,
    required DateTime dataInicio,
    required int prazo,
    required int aditivos,
    required DateTime dataTermino,
    DateTime? dataTerminoRealizado,
  }) {
    return into(obraContratados).insertOnConflictUpdate(
      ObraContratadosCompanion(
        uid: Value(uid),
        projetoEmpresaUid: Value(projetoEmpresaUid),
        obraUid: Value(obraUid),
        escopo: Value(escopo),
        dataInicio: Value(dataInicio),
        prazo: Value(prazo),
        aditivos: Value(aditivos),
        dataTermino: Value(dataTermino),
        dataTerminoRealizado: dataTerminoRealizado != null ? Value(dataTerminoRealizado) : Value.absent(),
      ),
    );
  }

  Future<int> atualizarObraContratados({
    required String uid,
    String? projetoEmpresaUid,
    String? obraUid,
    String? escopo,
    DateTime? dataInicio,
    int? prazo,
    int? aditivos,
    DateTime? dataTermino,
    DateTime? dataTerminoRealizado,
  }) {
    return (update(obraContratados)..where((c) => c.uid.equals(uid)))
        .write(
      ObraContratadosCompanion(
        projetoEmpresaUid: projetoEmpresaUid != null ? Value(projetoEmpresaUid) : Value.absent(),
        obraUid: obraUid != null ? Value(obraUid) : Value.absent(),
        escopo: escopo != null ? Value(escopo) : Value.absent(),
        dataInicio: dataInicio != null ? Value(dataInicio) : Value.absent(),
        prazo: prazo != null ? Value(prazo) : Value.absent(),
        aditivos: aditivos != null ? Value(aditivos) : Value.absent(),
        dataTermino: dataTermino != null ? Value(dataTermino) : Value.absent(),
        dataTerminoRealizado: dataTerminoRealizado != null ? Value(dataTerminoRealizado) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<ObraContratado>> getAllObraContratados() => select(obraContratados).get();

  /// Busca login por UID
  Future<ObraContratado?> getByUid(String uid) {
    return (select(obraContratados)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearObraContratados() => delete(obraContratados).go();
}
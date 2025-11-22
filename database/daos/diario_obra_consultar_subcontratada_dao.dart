import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_consultar_subcontratada_table.dart';

part 'diario_obra_consultar_subcontratada_dao.g.dart';

@DriftAccessor(tables: [DiarioObraConsultarSubcontratada])
class DiarioObraConsultarSubcontratadaDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraConsultarSubcontratadaDaoMixin {
  final AppDatabase db;
  DiarioObraConsultarSubcontratadaDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObraConsultarSubcontratada({
    required String uid,
    required String diarioObraConsultarUid,
    required String abreviacao,
    required String nomeEmpresa, 
    required String contatoPrincipal,
    required String dataHoraInclusao,
  }) {
    return into(diarioObraConsultarSubcontratada).insertOnConflictUpdate(
      DiarioObraConsultarSubcontratadaCompanion(
        uid: Value(uid),
        diarioObraConsultarUid: Value(diarioObraConsultarUid),
        abreviacao: Value(abreviacao),
        nomeEmpresa: Value(nomeEmpresa),
        contatoPrincipal: Value(contatoPrincipal),
        dataHoraInclusao: Value(dataHoraInclusao),
      ),
    );
  }

  Future<int> atualizarDiarioObraConsultarSubcontratada({
    required String uid,
    String? diarioObraConsultarUid,
    String? abreviacao,
    String? nomeEmpresa,
    String? contatoPrincipal,
    String? dataHoraInclusao,
  }) {
    return (update(diarioObraConsultarSubcontratada)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraConsultarSubcontratadaCompanion(
        diarioObraConsultarUid: diarioObraConsultarUid != null ? Value(diarioObraConsultarUid) : Value.absent(),
        abreviacao: abreviacao != null ? Value(abreviacao) : Value.absent(),
        nomeEmpresa: nomeEmpresa != null ? Value(nomeEmpresa) : Value.absent(),
        contatoPrincipal: contatoPrincipal != null ? Value(contatoPrincipal) : Value.absent(),
        dataHoraInclusao: dataHoraInclusao != null ? Value(dataHoraInclusao) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraConsultarSubcontratadaData>> getAllDiarioObraConsultarSubcontratada() => select(diarioObraConsultarSubcontratada).get();

  Future<List<DiarioObraConsultarSubcontratadaData>> buscarPorDiarioObraConsultar(
      String consultarUid) {
    return (select(diarioObraConsultarSubcontratada)
      ..where((tbl) => tbl.diarioObraConsultarUid.equals(consultarUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraConsultarSubcontratadaData?> getByUid(String uid) {
    return (select(diarioObraConsultarSubcontratada)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObraConsultarSubcontratadas() => delete(diarioObraConsultarSubcontratada).go();
}
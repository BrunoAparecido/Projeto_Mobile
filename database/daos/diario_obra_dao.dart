import 'package:drift/drift.dart';
import '../database.dart';
import 'package:lotus_mobile/database/tables/diario_obra_table.dart';

part 'diario_obra_dao.g.dart';

@DriftAccessor(tables: [DiarioObra])
class DiarioObraDao extends DatabaseAccessor<AppDatabase> with _$DiarioObraDaoMixin {
  final AppDatabase db;
  DiarioObraDao(this.db) : super(db);

  /// Insere ou atualiza um login
  Future<void> inserirDiarioObra({
    required String uid,
    String? usuarioResponsavelUid,
    String? diarioObraConsultarUid,
    String? obraContratadosUid,
    required int statusObraEnum,
    String? numero,
    required DateTime data,
    int? sequencial,
    required bool aprovadoContratada,
    required bool assinadoContratada,
    required bool assinadoContratante,
    required int periodoTrabalhadoManhaEnum,
    required int periodoTrabalhadoTardeEnum,
    required int periodoTrabalhadoNoiteEnum,
    String? observacoesPeriodoTrabalhado,
    required int condicoesMeteorologicasManhaEnum,
    required int condicoesMeteorologicasTardeEnum,
    required int condicoesMeteorologicasNoiteEnum,
    String? observacoesCondicoesMeteorologicas,
    required String dataHoraInclusao,
    String statusSincronizacao = 'pendente',
    String? erroSincronizacao,
  }) {
    return into(diarioObra).insertOnConflictUpdate(
      DiarioObraCompanion(
        uid: Value(uid),
        usuarioResponsavelUid: Value(usuarioResponsavelUid),
        diarioObraConsultarUid: Value(diarioObraConsultarUid),
        obraContratadosUid: Value(obraContratadosUid),
        statusObraEnum: Value(statusObraEnum),
        numero: Value(numero),
        data: Value(data),
        sequencial: Value(sequencial),
        aprovadoContratada: Value(aprovadoContratada),
        assinadoContratada: Value(assinadoContratada),
        assinadoContratante: Value(assinadoContratante),
        periodoTrabalhadoManhaEnum: Value(periodoTrabalhadoManhaEnum),
        periodoTrabalhadoTardeEnum: Value(periodoTrabalhadoTardeEnum),
        periodoTrabalhadoNoiteEnum: Value(periodoTrabalhadoNoiteEnum),
        observacoesPeriodoTrabalhado: Value(observacoesPeriodoTrabalhado),
        condicoesMeteorologicasManhaEnum: Value(condicoesMeteorologicasManhaEnum),
        condicoesMeteorologicasTardeEnum: Value(condicoesMeteorologicasTardeEnum),
        condicoesMeteorologicasNoiteEnum: Value(condicoesMeteorologicasNoiteEnum),
        observacoesCondicoesMeteorologicas: Value(observacoesCondicoesMeteorologicas),
        dataHoraInclusao: Value(dataHoraInclusao),
        statusSincronizacao: Value(statusSincronizacao),
        erroSincronizacao: Value(erroSincronizacao),
      ),
    );
  }

  Future<int> atualizarDiarioObra({
    required String uid,
    String? usuarioResponsavelUid,
    String? diarioObraConsultarUid,
    String? obraContratadosUid,
    int? statusObraEnum,
    String? numero,
    DateTime? data,
    int? sequencial,
    bool? aprovadoContratada,
    bool? assinadoContratada,
    bool? assinadoContratante,
    int? periodoTrabalhadoManhaEnum,
    int? periodoTrabalhadoTardeEnum,
    int? periodoTrabalhadoNoiteEnum,
    String? observacoesPeriodoTrabalhado,
    int? condicoesMeteorologicasManhaEnum,
    int? condicoesMeteorologicasTardeEnum,
    int? condicoesMeteorologicasNoiteEnum,
    String? observacoesCondicoesMeteorologicas,
    String? dataHoraInclusao,
    String? statusSincronizacao,
    String? erroSincronizacao,
  }) {
    return (update(diarioObra)..where((c) => c.uid.equals(uid)))
        .write(
      DiarioObraCompanion(
        usuarioResponsavelUid: usuarioResponsavelUid != null ? Value(usuarioResponsavelUid) : Value.absent(),
        diarioObraConsultarUid: diarioObraConsultarUid != null ? Value(diarioObraConsultarUid) : Value.absent(),
        obraContratadosUid: obraContratadosUid != null ? Value(obraContratadosUid) : Value.absent(),
        statusObraEnum: statusObraEnum != null ? Value(statusObraEnum) : Value.absent(),
        numero: numero != null ? Value(numero) : Value.absent(),
        data: data != null ? Value(data) : Value.absent(),
        sequencial: sequencial != null ? Value(sequencial) : Value.absent(),
        aprovadoContratada: aprovadoContratada != null ? Value(aprovadoContratada) : Value.absent(),
        assinadoContratada: assinadoContratada != null ? Value(assinadoContratada) : Value.absent(),
        assinadoContratante: assinadoContratante != null ? Value(assinadoContratante) : Value.absent(),
        periodoTrabalhadoManhaEnum: periodoTrabalhadoManhaEnum != null ? Value(periodoTrabalhadoManhaEnum) : Value.absent(),
        periodoTrabalhadoTardeEnum: periodoTrabalhadoTardeEnum != null ? Value(periodoTrabalhadoTardeEnum) : Value.absent(),
        periodoTrabalhadoNoiteEnum: periodoTrabalhadoNoiteEnum != null ? Value(periodoTrabalhadoNoiteEnum) : Value.absent(),
        observacoesPeriodoTrabalhado: observacoesPeriodoTrabalhado != null ? Value(observacoesPeriodoTrabalhado) : Value.absent(),
        condicoesMeteorologicasManhaEnum: condicoesMeteorologicasManhaEnum != null ? Value(condicoesMeteorologicasManhaEnum) : Value.absent(),
        condicoesMeteorologicasTardeEnum: condicoesMeteorologicasTardeEnum != null ? Value(condicoesMeteorologicasTardeEnum) : Value.absent(),
        condicoesMeteorologicasNoiteEnum: condicoesMeteorologicasNoiteEnum != null ? Value(condicoesMeteorologicasNoiteEnum) : Value.absent(),
        observacoesCondicoesMeteorologicas: observacoesCondicoesMeteorologicas != null ? Value(observacoesCondicoesMeteorologicas) : Value.absent(),
        dataHoraInclusao: dataHoraInclusao != null ? Value(dataHoraInclusao) : Value.absent(),
        statusSincronizacao: statusSincronizacao != null ? Value(statusSincronizacao) : Value.absent(),
        erroSincronizacao: erroSincronizacao != null ? Value(erroSincronizacao) : Value.absent(),
      ),
    );
  }

  /// Busca todos os logins
  Future<List<DiarioObraData>> getAllDiarioObra() => select(diarioObra).get();

  Future<List<DiarioObraData>> buscarPorDiarioObraConsultar(String consultarUid) {
    return (select(diarioObra)
      ..where((tbl) => tbl.diarioObraConsultarUid.equals(consultarUid)))
        .get();
  }

  /// Busca login por UID
  Future<DiarioObraData?> getByUid(String uid) {
    return (select(diarioObra)..where((tbl) => tbl.uid.equals(uid)))
        .getSingleOrNull();
  }

  /// Apaga todos os logins
  Future<int> clearDiarioObra() => delete(diarioObra).go();
}
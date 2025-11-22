import 'package:lotus_mobile/dtos/equipamento_dto.dart';
import 'package:lotus_mobile/dtos/mao_de_obra_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';

class DiarioObraApontamentoDto {
  final String uid;
  final String? empresaUid;
  final String diarioObraUid;
  final String? usuarioResponsavelUid;
  final String? projetoEmpresaUid;
  final String? diarioObraConsultarSubcontratadaUid;
  final String? maoDeObraUid;
  final String? equipamentoUid;
  final int valorApontamento;
  final String? dataHoraInclusao;
  final int? statusRegistroEnum;

  final ProjetoEmpresaDto? projetoEmpresa;
  final MaoDeObraDto? maoDeObra;
  final EquipamentoDto? equipamento;

  bool novoRegistro;

  DiarioObraApontamentoDto({
    required this.uid,
    this.empresaUid,
    required this.diarioObraUid,
    this.usuarioResponsavelUid,
    this.projetoEmpresaUid,
    this.diarioObraConsultarSubcontratadaUid,
    this.maoDeObraUid,
    this.equipamentoUid,
    required this.valorApontamento,
    this.dataHoraInclusao,
    this.statusRegistroEnum,
    this.projetoEmpresa,
    this.maoDeObra,
    this.equipamento,
    this.novoRegistro = true,
  });

  factory DiarioObraApontamentoDto.fromJson(Map<String, dynamic> json) {
    return DiarioObraApontamentoDto(
      uid: json['uid'] as String,
      empresaUid: json['empresaUid'] as String,
      diarioObraUid: json['diarioObraUid'] as String,
      usuarioResponsavelUid: json['usuarioResponsavelUid'] as String?,
      projetoEmpresaUid: json['projetoEmpresaUid'] as String?,
      diarioObraConsultarSubcontratadaUid:
          json['diarioObraConsultarSubcontratadaUid'] as String?,
      maoDeObraUid: json['maoDeObraUid'] as String?,
      equipamentoUid: json['equipamentoUid'] as String?,
      valorApontamento: json['valorApontamento'] as int,
      dataHoraInclusao: json['dataHoraInclusao'] as String,
      statusRegistroEnum: json['statusRegistroEnum'] as int,
      projetoEmpresa: json['projetoEmpresa'] != null 
          ? ProjetoEmpresaDto.fromJson(json['projetoEmpresa']) 
          : null,
      maoDeObra: json['maoDeObra'] != null 
          ? MaoDeObraDto.fromJson(json['maoDeObra']) 
          : null,
      equipamento: json['equipamento'] != null 
          ? EquipamentoDto.fromJson(json['equipamento']) 
          : null,
      novoRegistro: false, // Dados vindos da API não são novos registros
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'equipamentoUid': equipamentoUid,
      'maoDeObraUid': maoDeObraUid,
      'valorApontamento': valorApontamento,
      'diarioObraConsultarSubcontratadaUid': diarioObraConsultarSubcontratadaUid,
    };
  }
}

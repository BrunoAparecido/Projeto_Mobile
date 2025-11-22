import 'package:lotus_mobile/dtos/contato_projeto_empresa_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_avaliacao_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_servico_dto.dart';

class ProjetoEmpresaDto {
  String uid;
  String empresaUid;
  int tipoDocumentoEnum;
  String tipoDocumentoEnumTexto;
  String? cpf;
  String? cnpj;
  List<int>? tipoRelacionamentoEnum = [];
  String telefone;
  String razaoSocial;
  String nomeFantasia;
  String abreviacao;
  String observacoesEmpresa;
  List<ContatoProjetoEmpresaDto> contatoProjetoEmpresa; // Removido '?'
  List<ProjetoEmpresaAvaliacaoDto> projetoEmpresaAvaliacao; // Removido '?'
  List<ProjetoEmpresaServicoDto> projetoEmpresaServico; // Removido '?'
  

  ProjetoEmpresaDto({
    required this.uid,
    required this.empresaUid,
    required this.tipoDocumentoEnum,
    required this.tipoDocumentoEnumTexto,
    this.cpf,
    this.cnpj,
    this.tipoRelacionamentoEnum,
    required this.telefone,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.abreviacao,
    required this.observacoesEmpresa,
    this.contatoProjetoEmpresa = const [], // Definido valor padrão
    this.projetoEmpresaAvaliacao = const [], // Definido valor padrão
    this.projetoEmpresaServico = const [] // Definido valor padrão
  });

  // Função auxiliar para mapeamento seguro de listas
  static List<T> _safeList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List) {
      // Mapeia cada item da lista (que deve ser um Map)
      return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    }
    // Retorna uma lista vazia se o dado for null ou não for uma lista
    return [];
  }

  factory ProjetoEmpresaDto.fromJson(Map<String, dynamic> json) {
    return ProjetoEmpresaDto(
      uid: json['uid'] as String, 
      empresaUid: json['empresaUid'] as String, 
      tipoDocumentoEnum: json['tipoDocumentoEnum'] as int, 
      tipoDocumentoEnumTexto: json['tipoDocumentoEnumTexto'] as String,
      cpf: json['cpf'] as String?, 
      cnpj: json['cnpj'] as String?, 
      // O campo tipoRelacionamentoEnum é uma lista de inteiros, mas não é uma lista de DTOs, 
      // então o mapeamento é mais simples, mas ainda precisa ser seguro.
      tipoRelacionamentoEnum: (json['tipoRelacionamentoEnum'] is List) 
          ? (json['tipoRelacionamentoEnum'] as List).cast<int>() 
          : [],
      telefone: json['telefone'] as String, 
      razaoSocial: json['razaoSocial'] as String, 
      nomeFantasia: json['nomeFantasia'] as String, 
      abreviacao: json['abreviacao'] as String, 
      observacoesEmpresa: json['observacoesEmpresa'] as String, 
      
      // APLICAÇÃO DA CORREÇÃO DE TIPAGEM SEGURA:
      contatoProjetoEmpresa: _safeList<ContatoProjetoEmpresaDto>(
          json['contatoProjetoEmpresa'], 
          (p) => ContatoProjetoEmpresaDto.fromJson(p)),
          
      projetoEmpresaAvaliacao: _safeList<ProjetoEmpresaAvaliacaoDto>(
          json['projetoEmpresaAvaliacao'], 
          (p) => ProjetoEmpresaAvaliacaoDto.fromJson(p)),
          
      projetoEmpresaServico: _safeList<ProjetoEmpresaServicoDto>(
          json['projetoEmpresaServico'], 
          (p) => ProjetoEmpresaServicoDto.fromJson(p)),
    );
  }
}
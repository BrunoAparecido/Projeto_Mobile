import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';
import 'package:workmanager/workmanager.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/services/notification_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lotus_mobile/dtos/diario_obra_anexo_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_anotacoes_contratada_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_anotacoes_gerenciadora_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_apontamento_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_equipamento_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_mao_de_obra_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_subcontratada_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_evolucao_servicos_dto.dart';
import 'package:uuid/uuid.dart';
import 'package:cron/cron.dart';
import 'dart:async';
import 'dart:isolate';

// Constantes
const String _empresaUid = '9a54ca34-2b37-4f82-a841-81253e00e627';
const int _statusRegistroEnum = 0;

// Enums e Classes de Status
enum SyncStatus { idle, syncing, success, error }

class SyncEvent {
  final SyncStatus status;
  final String? message;
  final String? diarioConsultarUid;

  SyncEvent({required this.status, this.message, this.diarioConsultarUid});
}

// Função callback executada em background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('[Background] Iniciando tarefa: $task');

      final database = AppDatabase();
      final dioClient = DioClient();
      final notificationService = NotificationService();

      await notificationService.initialize();

      final diarioConsultarUid = inputData?['diarioConsultarUid'] as String?;

      if (diarioConsultarUid == null) {
        print('[Background] UID do diário não fornecido');
        await notificationService.showSyncError('Dados inválidos');
        await database.close();
        return Future.value(false);
      }

      await notificationService.showSyncInProgress();

      bool syncCompleted = false;
      const portName = 'background_sync_port';

      // Função para tentar sincronizar
      Future<bool> tentarSincronizar() async {
        try {
          print('[Background] Verificando conexão...');
          final hasInternet = await InternetConnection().hasInternetAccess;

          if (!hasInternet) {
            print('[Background] Sem conexão');
            return false;
          }

          print('[Background] Internet disponível - iniciando sincronização');

          final diarioConsultar = await database.diarioObraConsultarDao
              .getByUid(diarioConsultarUid);

          if (diarioConsultar == null) {
            throw Exception('Diário não encontrado');
          }

          final diariosParaNumerar =
              await (database.select(database.diarioObra)..where(
                    (tbl) =>
                        tbl.diarioObraConsultarUid.equals(diarioConsultar.uid) &
                        tbl.numero.isNull(),
                  ))
                  .get();

          // ✨ NOVO: Para cada diário sem número, obter sequencial e atualizar
          for (var diario in diariosParaNumerar) {
            print('[Background] Obtendo sequencial para diário ${diario.uid}');

            final sequencial = await _obterProximoSequencial(
              dioClient,
              diarioConsultar.obraContratadoUid!,
            );

            if (sequencial == null) {
              throw Exception('Erro ao obter sequencial do backend');
            }

            // Formata o número com 5 dígitos
            final numeroFormatado = sequencial.toString().padLeft(5, '0');

            print(
              '[Background] Sequencial obtido: $sequencial, Número: $numeroFormatado',
            );

            // Atualiza o diário no banco com o número e sequencial
            await database.diarioObraDao.atualizarDiarioObra(
              uid: diario.uid,
              usuarioResponsavelUid: diario.usuarioResponsavelUid,
              diarioObraConsultarUid: diario.diarioObraConsultarUid,
              obraContratadosUid: diario.obraContratadosUid,
              statusObraEnum: diario.statusObraEnum,
              numero: numeroFormatado, // ← Atualiza com número obtido
              data: diario.data,
              sequencial: sequencial, // ← Atualiza com sequencial
              aprovadoContratada: diario.aprovadoContratada,
              assinadoContratada: diario.assinadoContratada,
              assinadoContratante: diario.assinadoContratante,
              periodoTrabalhadoManhaEnum: diario.periodoTrabalhadoManhaEnum,
              periodoTrabalhadoTardeEnum: diario.periodoTrabalhadoTardeEnum,
              periodoTrabalhadoNoiteEnum: diario.periodoTrabalhadoNoiteEnum,
              observacoesPeriodoTrabalhado: diario.observacoesPeriodoTrabalhado,
              condicoesMeteorologicasManhaEnum:
                  diario.condicoesMeteorologicasManhaEnum,
              condicoesMeteorologicasTardeEnum:
                  diario.condicoesMeteorologicasTardeEnum,
              condicoesMeteorologicasNoiteEnum:
                  diario.condicoesMeteorologicasNoiteEnum,
              observacoesCondicoesMeteorologicas:
                  diario.observacoesCondicoesMeteorologicas,
              dataHoraInclusao: diario.dataHoraInclusao,
            );
          }

          print('[Background] Buscando imagens para upload...');
          final imagensParaUpload = await _buscarImagensParaUpload(
            database,
            diarioConsultarUid,
          );

          // 2️⃣ FAZER UPLOAD DAS IMAGENS PRIMEIRO
          if (imagensParaUpload.isNotEmpty) {
            print(
              '[Background] Enviando ${imagensParaUpload.length} imagens...',
            );
            final uploadSucesso = await _uploadImagens(
              imagensParaUpload,
              dioClient,
            );

            if (!uploadSucesso) {
              throw Exception('Falha ao enviar imagens');
            }

            // Atualiza o status de upload dos anexos
            for (var guid in imagensParaUpload.keys) {
              final anexos = await database.diarioObraAnexoDao
                  .buscarPorGuidControleUpload(guid);

              for (var anexo in anexos) {
                await database.diarioObraAnexoDao.atualizarDiarioObraAnexo(
                  uid: anexo.uid,
                  diarioObraUid: anexo.diarioObraUid,
                  descricao: anexo.descricao,
                  guidControleUpload: guid,
                  uploadComplete: true,
                );
              }
            }

            print('[Background] ✅ Todas as imagens enviadas com sucesso');
          }

          final dto = await _montarDiarioObraConsultarDto(
            database,
            diarioConsultar,
          );

          final raw = dto.toJson();
          raw['projetoUid'] = diarioConsultar.projetoUid;
          raw['obraUid'] = diarioConsultar.obraUid;
          raw['obraContratadosUid'] = diarioConsultar.obraContratadoUid;
          raw['diarioObraConsultarUid'] = diarioConsultar.uid;

          final payload = _cleanMap(raw);

          final response = await dioClient.dio.post(
            'http://127.0.0.1:5089/DiarioObraConsultar/AdicionarAtualizar',
            data: payload,
          );

          if (response.statusCode == 200 && response.data?['sucesso'] == true) {
            print('[Background] Sincronização bem-sucedida');

            await notificationService.cancelAll();
            await notificationService.showSyncSuccess();

            try {
              final sendPort =
                  IsolateNameServer.lookupPortByName(portName) as SendPort?;
              final payload = {
                'status': 'success',
                'message': 'Sincronização concluída com sucesso',
                'diarioConsultarUid': diarioConsultarUid,
              };
              if (sendPort != null) {
                sendPort.send(payload);
                print('[Background] SendPort enviado: $payload');
              } else {
                print(
                  '[Background] SendPort não encontrado — UI possivelmente inativa',
                );
              }
            } catch (e) {
              print('[Background] Erro ao enviar SendPort: $e');
            }

            return true;
          } else {
            final errorMsg = response.data?['mensagem'] ?? 'Erro desconhecido';
            print('[Background] Erro: $errorMsg');
            throw Exception(errorMsg);
          }
        } catch (e) {
          print('[Background] Erro na sincronização: $e');

          try {
            final sendPort =
                IsolateNameServer.lookupPortByName(portName) as SendPort?;
            final payloadMap = {
              'status': 'error',
              'message': e.toString(),
              'diarioConsultarUid': diarioConsultarUid,
            };
            if (sendPort != null) {
              sendPort.send(payloadMap);
              print('[Background] SendPort enviado (erro): $payloadMap');
            } else {
              print(
                '[Background] SendPort não encontrado — UI possivelmente inativa',
              );
            }
          } catch (err) {
            print('[Background] Falha ao enviar payload de erro ao UI: $err');
          }

          return false;
        }
      }

      // Primeira tentativa IMEDIATA
      print('[Background] Primeira tentativa de sincronização (imediata)');
      syncCompleted = await tentarSincronizar();

      // Se já sincronizou com sucesso, retorna
      if (syncCompleted) {
        await database.close();
        return Future.value(true);
      }

      // Se não conseguiu sincronizar, inicia verificação periódica
      print(
        '[Background] Sem conexão. Iniciando verificação periódica a cada 2 minutos...',
      );

      final cron = Cron();
      late final dynamic cronTask;

      cronTask = cron.schedule(Schedule.parse('*/2 * * * *'), () async {
        if (syncCompleted) return;

        syncCompleted = await tentarSincronizar();

        if (syncCompleted) {
          cronTask.cancel();
        }
      });

      // Aguarda até 30 minutos (15 tentativas a cada 2 minutos)
      // O cron já está fazendo as verificações periódicas
      int attempts = 0;
      const maxAttempts = 15;

      while (!syncCompleted && attempts < maxAttempts) {
        await Future.delayed(Duration(minutes: 2));
        attempts++;

        // Verifica se foi concluído durante o delay
        if (syncCompleted) break;
      }

      // Se não conseguiu sincronizar após todas as tentativas
      if (!syncCompleted) {
        print('[Background] Timeout - máximo de tentativas atingido');

        await notificationService.cancelAll();
        await notificationService.showSyncError(
          'Não foi possível sincronizar após várias tentativas',
        );

        try {
          final sendPort =
              IsolateNameServer.lookupPortByName(portName) as SendPort?;
          final payloadMap = {
            'status': 'error',
            'message': 'Não foi possível sincronizar após várias tentativas',
            'diarioConsultarUid': diarioConsultarUid,
          };
          if (sendPort != null) sendPort.send(payloadMap);
        } catch (err) {
          print('[Background] Falha ao enviar payload de timeout ao UI: $err');
        }

        try {
          cronTask.cancel();
        } catch (e) {
          print('[Background] Erro ao cancelar cron: $e');
        }

        await database.close();
        return Future.value(false);
      }

      // Cleanup
      try {
        cronTask.cancel();
      } catch (e) {
        print('[Background] Cron já estava cancelado ou não foi iniciado');
      }

      await database.close();

      return Future.value(true);
    } catch (e) {
      print('[Background] Erro fatal: $e');
      return Future.value(false);
    }
  });
}

// Funções auxiliares privadas usadas no background

String _normalizarUid(String? uid) {
  final guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  if (uid == null) return Uuid().v4();
  uid = uid.trim();
  if (uid.isEmpty || uid.toLowerCase() == 'null') return Uuid().v4();

  if (uid.startsWith('temp_')) {
    final candidate = uid.substring(5);
    if (guidRegex.hasMatch(candidate)) return candidate;
    return Uuid().v4();
  }

  if (guidRegex.hasMatch(uid)) return uid;
  return Uuid().v4();
}

Future<DiarioObraConsultarDto> _montarDiarioObraConsultarDto(
  AppDatabase database,
  DiarioObraConsultarData diarioConsultar,
) async {
  final listaDiarioObra = await database.diarioObraDao
      .buscarPorDiarioObraConsultar(diarioConsultar.uid);

  final listaDiarioObraDto = <DiarioObraDto>[];

  for (final diario in listaDiarioObra) {
    final evolucoes = await database.diarioObraEvolucaoDao.buscarPorDiarioObra(
      diario.uid,
    );

    final anotacoesGerenciadora = await database
        .diarioObraAnotacoesGerenciadoraDao
        .buscarPorDiarioObra(diario.uid);

    final anotacoesContratada = await database.diarioObraAnotacoesContratadaDao
        .buscarPorDiarioObra(diario.uid);

    final anexos = await database.diarioObraAnexoDao.buscarPorDiarioObra(
      diario.uid,
    );

    final apontamentos = await database.diarioObraApontamentoDao
        .buscarPorDiarioObra(diario.uid);

    listaDiarioObraDto.add(
      DiarioObraDto(
        uid: _normalizarUid(diario.uid),
        empresaUid: _empresaUid,
        usuarioResponsavelUid: diario.usuarioResponsavelUid,
        diarioObraConsultarUid: _normalizarUid(diarioConsultar.uid),
        obraContratadosUid: diario.obraContratadosUid,
        numero: diario.numero!,
        sequencial: diario.sequencial!,
        data: diario.data != null
            ? diario.data!.toIso8601String().split('T')[0]
            : DateTime.now().toIso8601String().split('T')[0],
        statusObraEnum: diario.statusObraEnum,
        statusObraEnumTexto: '',
        periodoTrabalhadoManhaEnum: diario.periodoTrabalhadoManhaEnum,
        periodoTrabalhadoManhaEnumTexto: '',
        periodoTrabalhadoTardeEnum: diario.periodoTrabalhadoTardeEnum,
        periodoTrabalhadoTardeEnumTexto: '',
        periodoTrabalhadoNoiteEnum: diario.periodoTrabalhadoNoiteEnum,
        periodoTrabalhadoNoiteEnumTexto: '',
        observacoesPeriodoTrabalhado: diario.observacoesPeriodoTrabalhado ?? '',
        condicoesMeteorologicasManhaEnum:
            diario.condicoesMeteorologicasManhaEnum,
        condicoesMeteorologicasManhaEnumTexto: '',
        condicoesMeteorologicasTardeEnum:
            diario.condicoesMeteorologicasTardeEnum,
        condicoesMeteorologicasTardeEnumTexto: '',
        condicoesMeteorologicasNoiteEnum:
            diario.condicoesMeteorologicasNoiteEnum,
        condicoesMeteorologicasNoiteEnumTexto: '',
        observacoesCondicoesMeteorologicas:
            diario.observacoesCondicoesMeteorologicas ?? '',
        dataHoraInclusao: diario.dataHoraInclusao,
        statusRegistroEnum: _statusRegistroEnum,
        assinadoContratada: diario.assinadoContratada,
        aprovadoContratada: diario.aprovadoContratada,
        assinadoContratante: diario.assinadoContratante,
        diarioObraEvolucaoServicos: evolucoes
            .map(
              (e) => DiarioObraEvolucaoServicosDto(
                uid: _normalizarUid(e.uid),
                empresaUid: _empresaUid,
                usuarioResponsavelUid: null,
                obraUid: e.obraUid ?? '',
                numero: e.numero,
                sequencial: e.sequencial,
                evolucao: e.evolucao,
                dataHoraInclusao: e.dataHoraInclusao,
                statusRegistroEnum: _statusRegistroEnum,
              ),
            )
            .toList(),
        diarioObraAnotacoesGerenciadora: anotacoesGerenciadora
            .map(
              (a) => DiarioObraAnotacoesGerenciadoraDto(
                uid: _normalizarUid(a.uid),
                empresaUid: _empresaUid,
                usuarioResponsavelUid: null,
                obraUid: a.obraUid ?? '',
                data: a.data != null
                    ? a.data.toIso8601String().split('T')[0]
                    : DateTime.now().toIso8601String().split('T')[0],
                anotacao: a.anotacao,
                dataHoraInclusao: a.dataHoraInclusao,
                statusRegistroEnum: _statusRegistroEnum,
              ),
            )
            .toList(),
        diarioObraAnotacoesContratada: anotacoesContratada
            .map(
              (a) => DiarioObraAnotacoesContratadaDto(
                uid: _normalizarUid(a.uid),
                empresaUid: _empresaUid,
                usuarioResponsavelUid: null,
                obraUid: a.obraUid ?? '',
                data: a.data != null
                    ? a.data.toIso8601String().split('T')[0]
                    : DateTime.now().toIso8601String().split('T')[0],
                anotacao: a.anotacao,
                dataHoraInclusao: a.dataHoraInclusao,
                statusRegistroEnum: _statusRegistroEnum,
              ),
            )
            .toList(),
        diarioObraAnexo: anexos
            .map(
              (a) => DiarioObraAnexoDto(
                uid: _normalizarUid(a.uid),
                empresaUid: _empresaUid,
                descricao: a.descricao,
                guidControleUpload: a.guidControleUpload,
                uploadComplete: a.uploadComplete,
              ),
            )
            .toList(),
        diarioObraApontamento: apontamentos
            .map(
              (a) => DiarioObraApontamentoDto(
                uid: _normalizarUid(a.uid),
                empresaUid: _empresaUid,
                diarioObraUid: _normalizarUid(diario.uid),
                usuarioResponsavelUid: null,
                projetoEmpresaUid: a.projetoEmpresaUid,
                diarioObraConsultarSubcontratadaUid: a.subcontratadaUid != null
                    ? _normalizarUid(a.subcontratadaUid!)
                    : null,
                equipamentoUid: a.equipamentoUid,
                maoDeObraUid: a.maoDeObraUid,
                valorApontamento: a.valorApontamento,
                dataHoraInclusao: '',
                statusRegistroEnum: _statusRegistroEnum,
              ),
            )
            .toList(),
      ),
    );
  }

  final subcontratadas = await database.diarioObraConsultarSubcontratadaDao
      .buscarPorDiarioObraConsultar(diarioConsultar.uid);

  final equipamentos = await database.diarioObraConsultarEquipamentoDao
      .buscarPorDiarioObraConsultar(diarioConsultar.uid);

  final maoDeObra = await database.diarioObraConsultarMaoDeObraDao
      .buscarPorDiarioObraConsultar(diarioConsultar.uid);

  return DiarioObraConsultarDto(
    uid: _normalizarUid(diarioConsultar.uid),
    empresaUid: _empresaUid,
    projetoUid: diarioConsultar.projetoUid,
    obraUid: diarioConsultar.obraUid,
    obraContratadosUid: diarioConsultar.obraContratadoUid,
    obra: null,
    obraContratados: null,
    contatoResponsavel: null,
    projeto: null,
    contato: null,
    projetoEmpresa: null,
    diarioObra: listaDiarioObraDto,
    diarioObraConsultarSubcontratada: subcontratadas
        .map(
          (s) => DiarioObraConsultarSubcontratadaDto(
            uid: _normalizarUid(s.uid),
            abreviacao: s.abreviacao,
            nomeEmpresa: s.nomeEmpresa,
            contatoPrincipal: s.contatoPrincipal,
            dataHoraInclusao: s.dataHoraInclusao,
            statusRegistroEnum: _statusRegistroEnum,
          ),
        )
        .toList(),
    diarioObraConsultarEquipamento: equipamentos
        .map(
          (e) => DiarioObraConsultarEquipamentoDto(
            uid: _normalizarUid(e.uid),
            empresaUid: _empresaUid,
            equipamentoUid: e.equipamentoUid ?? '',
            equipamento: null,
            status: e.status.toLowerCase() == 'ativo' ? 0 : 1,
            statusEquipamentoEnumTexto: e.status,
            dataHoraInclusao: e.dataHoraInclusao,
            statusRegistroEnum: _statusRegistroEnum,
          ),
        )
        .toList(),
    diarioObraConsultarMaoDeObra: maoDeObra
        .map(
          (m) => DiarioObraConsultarMaoDeObraDto(
            uid: _normalizarUid(m.uid),
            empresaUid: _empresaUid,
            maoDeObraUid: m.maoDeObraUid ?? '',
            maoDeObra: null,
            status: m.status.toLowerCase() == 'ativo' ? 0 : 1,
            statusMaoDeObraEnumTexto: m.status,
            dataHoraInclusao: m.dataHoraInclusao,
            statusRegistroEnum: _statusRegistroEnum,
          ),
        )
        .toList(),
  );
}

Map<String, dynamic> _cleanMap(Map<String, dynamic> map) {
  final result = <String, dynamic>{};
  map.forEach((k, v) {
    if (v == null) return;
    if (v is Map<String, dynamic>) {
      final cleaned = _cleanMap(v);
      if (cleaned.isNotEmpty) result[k] = cleaned;
    } else if (v is List) {
      final listCleaned = v
          .map((e) {
            if (e is Map<String, dynamic>)
              return _cleanMap(e as Map<String, dynamic>);
            return e;
          })
          .where((e) => !(e is Map && e.isEmpty))
          .toList();
      result[k] = listCleaned;
    } else {
      result[k] = v;
    }
  });
  return result;
}

Future<Map<String, File>> _buscarImagensParaUpload(
  AppDatabase database,
  String diarioConsultarUid,
) async {
  final imagens = <String, File>{};

  try {
    // Busca todos os diários do DiarioObraConsultar
    final listaDiarioObra = await database.diarioObraDao
        .buscarPorDiarioObraConsultar(diarioConsultarUid);

    for (final diario in listaDiarioObra) {
      // Busca anexos do diário
      final anexos = await database.diarioObraAnexoDao.buscarPorDiarioObra(
        diario.uid,
      );

      for (final anexo in anexos) {
        // Se o anexo tem um guidControleUpload válido e não foi feito upload
        if (anexo.guidControleUpload.isNotEmpty && !anexo.uploadComplete) {
          // Verifica se é um caminho local (começa com '/')
          if (anexo.guidControleUpload.startsWith('/')) {
            final file = File(anexo.guidControleUpload);
            if (await file.exists()) {
              // Gera um GUID real para o upload
              final guidReal = Uuid().v4();
              imagens[guidReal] = file;

              // Atualiza o banco com o GUID real
              await database.diarioObraAnexoDao.atualizarDiarioObraAnexo(
                uid: anexo.uid,
                diarioObraUid: anexo.diarioObraUid,
                descricao: anexo.descricao,
                guidControleUpload: guidReal,
                uploadComplete: false,
              );
            }
          }
        }
      }
    }
  } catch (e) {
    print('[Background] Erro ao buscar imagens para upload: $e');
  }

  return imagens;
}

Future<bool> _uploadImagens(
  Map<String, File> imagens,
  DioClient dioClient,
) async {
  if (imagens.isEmpty) {
    print('[Background] Nenhuma imagem para upload');
    return true;
  }

  print('[Background] Iniciando upload de ${imagens.length} imagens');

  try {
    for (var entry in imagens.entries) {
      final guid = entry.key;
      final file = entry.value;

      print('[Background] Enviando imagem: $guid');

      final formData = FormData.fromMap({
        'guidControleUpload': guid,
        'files': await MultipartFile.fromFile(file.path, filename: '$guid.png'),
      });

      final response = await dioClient.dio.post(
        '/DiarioObra/UploadAnexo',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode != 200) {
        print('[Background] Falha ao enviar imagem $guid');
        return false;
      }

      print('[Background] ✅ Imagem enviada: $guid');
    }

    print('[Background] Todas as imagens enviadas com sucesso');
    return true;
  } catch (e) {
    print('[Background] Erro ao fazer upload de imagens: $e');
    return false;
  }
}

Future<int?> _obterProximoSequencial(
  DioClient dioClient,
  String obraContratadosUid,
) async {
  try {
    final response = await dioClient.dio.get(
      '/DiarioObra/GetSequencialNumeroDiarioObra',
      queryParameters: {'obraContratadosUid': obraContratadosUid},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'];
      if (data != null) {
        return int.tryParse(data.toString());
      }
    }
    return null;
  } catch (e) {
    print('[Background] Erro ao obter sequencial: $e');
    return null;
  }
}

// Classe principal do serviço
class BackgroundSyncService {
  static final BackgroundSyncService _instance =
      BackgroundSyncService._internal();
  factory BackgroundSyncService() => _instance;
  BackgroundSyncService._internal();

  // Stream para comunicação com a UI
  static final _syncStatusController = StreamController<SyncEvent>.broadcast();
  Stream<SyncEvent> get syncStatusStream => _syncStatusController.stream;

  // Método estático para enviar eventos do background
  static void notifySyncStatus(SyncEvent event) {
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(event);
      print('Evento enviado: ${event.status} - ${event.message}');
    }
  }

  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    print('BackgroundSyncService inicializado');
  }

  Future<void> scheduleSyncTask(String diarioConsultarUid) async {
    await Workmanager().registerOneOffTask(
      'sync_task_$diarioConsultarUid',
      'syncDiarioObra',
      inputData: {'diarioConsultarUid': diarioConsultarUid},
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: Duration(minutes: 2),
    );

    // Notifica que a sincronização foi agendada
    notifySyncStatus(
      SyncEvent(
        status: SyncStatus.syncing,
        message: 'Sincronização agendada',
        diarioConsultarUid: diarioConsultarUid,
      ),
    );

    print('Tarefa de sincronização agendada para $diarioConsultarUid');
    print('Verificação de conexão a cada 2 minutos por até 30 minutos');
  }

  Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    print('Todas as tarefas canceladas');
  }

  Future<void> cancelTask(String diarioConsultarUid) async {
    await Workmanager().cancelByUniqueName('sync_task_$diarioConsultarUid');
    print('Tarefa $diarioConsultarUid cancelada');
  }

  void dispose() {
    _syncStatusController.close();
  }
}

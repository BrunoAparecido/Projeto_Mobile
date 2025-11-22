import 'package:flutter/material.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';
import 'package:lotus_mobile/services/equipamento_service.dart';
import 'package:lotus_mobile/services/login_service.dart';
import 'package:lotus_mobile/services/mao_de_obra_service.dart';
import 'package:lotus_mobile/services/projeto_service.dart';
import 'package:lotus_mobile/services/storage_service.dart';
import 'package:lotus_mobile/database/daos/usuario_dao.dart';
import 'package:lotus_mobile/services/usuario_service.dart';

class AuthProvider with ChangeNotifier {
  final AppDatabase database;
  final LoginService loginService;
  final StorageService storageService;
  final UsuarioService usuarioService;

  UsuarioData? _currentUser;

  AuthProvider({
    required this.database,
    required this.loginService,
    required this.storageService,
    required this.usuarioService,
  });

  UsuarioData? get currentUser => _currentUser;

  Future<bool> loadUser() async {
    final users = await database.usuarioDao.getAllUsers();
    final token = await storageService.getToken();

    if (users.isNotEmpty && token != null) {
      _currentUser = users.first;
      return true;
    } else {
      _currentUser = null;
      return false;
    }
  }

  Future<void> login(String email, String senha) async {
    final response = await loginService.login(email: email, senha: senha);

    if (response != null && response.sucesso) {
      final parametros = [
        ParametroGetDto(
          atributoPesquisa: "uid",
          comparador: 0,
          valorPesquisa: response.uid,
        ),
      ];

      await storageService.saveToken(response.data);

      final usuarioResponse = await usuarioService.buscar(parametros);
      print("resposta do Usuario Service: $usuarioResponse");

      final contatoJson = usuarioResponse.contato;
      print("Como está o contatoJson: $contatoJson");

      print("UID: ${usuarioResponse.uid}");
      print("Nome: ${usuarioResponse.nome}");
      print("Email: $email");
      print("Último nome: ${usuarioResponse.ultimoNome}");
      print("GrupoLotus: ${usuarioResponse.grupoLotus}");
      print("ContatoUid vindo do UsuarioResponse: ${usuarioResponse.contatoUid}");
      print("ContatoUid real no banco (Contato inserido): ${contatoJson?.uid}");

      if (contatoJson == null) {
        throw Exception(
          "Usuário sem contato não pode ser salvo localmente (FK obrigatória).",
        );
      }

      final contatoUid = contatoJson.uid;
      print("Contato UID: $contatoUid");

      // Garante que o contato existe no banco local
      final contatoExistente = await database.contatoDao.getByUid(contatoUid);

      if (contatoExistente == null) {
        await database.contatoDao.inserirContato(
          uid: contatoUid,
          pronomeEnum: contatoJson.pronomeEnum,
          nome: contatoJson.nome,
          ultimoNome: contatoJson.ultimoNome,
          grupoLotus: usuarioResponse.grupoLotus,
        );
      } else {
        await database.contatoDao.atualizarContato(
          uid: contatoUid,
          pronomeEnum: contatoJson.pronomeEnum,
          nome: contatoJson.nome,
          ultimoNome: contatoJson.ultimoNome,
          grupoLotus: usuarioResponse.grupoLotus,
        );
      }

      final contatoVerificado = await database.contatoDao.getByUid(contatoUid);
      if (contatoVerificado == null) {
        throw Exception("❌ Contato ainda não foi persistido antes de salvar o usuário!");
      }

      print("✅ Contato persistido. Agora salvando usuário...");

      await database.usuarioDao.saveUsuario(
        uid: usuarioResponse.uid,
        nome: usuarioResponse.nome,
        email: email,
        ultimoNome: usuarioResponse.ultimoNome,
        grupoLotus: usuarioResponse.grupoLotus,
        contatoUid: contatoUid,
      );

      _currentUser = UsuarioData(
        uid: usuarioResponse.uid,
        nome: usuarioResponse.nome,
        email: email,
        ultimoNome: usuarioResponse.ultimoNome,
        grupoLotus: usuarioResponse.grupoLotus,
        contatoUid: contatoUid,
      );
      print(_currentUser);

      notifyListeners();
    } else {
      throw Exception("Falha no login");
    }
  }

  Future<void> logout() async {
    await storageService.deleteToken();
    _currentUser = null;
    notifyListeners();
  }
}

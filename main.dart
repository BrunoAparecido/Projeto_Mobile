import 'dart:ui';
import 'package:dio/src/dio.dart';
import 'package:flutter/material.dart';
import 'package:lotus_mobile/app_router.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/pages/home_page.dart';
import 'package:lotus_mobile/pages/login_page.dart';
import 'package:lotus_mobile/providers/auth_provider.dart';
import 'package:lotus_mobile/services/background_service.dart';
import 'package:lotus_mobile/services/contato_service.dart';
import 'package:lotus_mobile/services/diario_obra_consultar_service.dart';
import 'package:lotus_mobile/services/equipamento_service.dart';
import 'package:lotus_mobile/services/image_service.dart';
import 'package:lotus_mobile/services/login_service.dart';
import 'package:lotus_mobile/services/mao_de_obra_service.dart';
import 'package:lotus_mobile/services/notification_service.dart';
import 'package:lotus_mobile/services/obra_service.dart';
import 'package:lotus_mobile/services/pdf_service.dart';
import 'package:lotus_mobile/services/projeto_service.dart';
import 'package:lotus_mobile/services/storage_service.dart';
import 'package:lotus_mobile/services/usuario_service.dart';
import 'package:lotus_mobile/services/projeto_empresa_service.dart';
import 'package:provider/provider.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'dart:isolate';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final receivePort = ReceivePort();
  const portName = 'background_sync_port';

  IsolateNameServer.removePortNameMapping(portName);
  final registered = IsolateNameServer.registerPortWithName(
    receivePort.sendPort, 
    portName,
  );

  if(!registered) {
    print('Não foi possível registrar portName. Já registrado?');
  }

  receivePort.listen((dynamic message) {
    print('Tela recebeu mensagem do background: $message');

    if(message is Map) {
      final statusStr = message['status'] as String?;
      final msg = message['message'] as String?;
      final diarioUid = message['diarioConsultarUid'] as String?;

      if(statusStr != null) {
        final status = statusStr == 'success'
            ? SyncStatus.success
            : (statusStr == 'error' ? SyncStatus.error : SyncStatus.idle);

        BackgroundSyncService.notifySyncStatus(SyncEvent(
          status: status,
          message: msg,
          diarioConsultarUid: diarioUid,
        ));
      }
    }
  });

  final notificationService = NotificationService();
  await notificationService.initialize();
  
  final backgroundSyncService = BackgroundSyncService();
  await backgroundSyncService.initialize();

  final database = AppDatabase();
  final loginService = LoginService();
  final storageService = StorageService();
  final dioClient = DioClient();
  final usuarioService = UsuarioService(dioClient);
  final projetoService = ProjetoService(dioClient);
  final equipamentoService = EquipamentoService(dioClient);
  final maoDeObraService = MaoDeObraService(dioClient);
  final obraService = ObraService(dioClient);
  final projetoEmpresaService = ProjetoEmpresaService(dioClient);
  final diarioObraConsultarService = DiarioObraConsultarService(dioClient);
  final contatoService = ContatoService(dioClient);

  runApp(
    MyApp(
      database: database,
      loginService: loginService,
      storageService: storageService,
      usuarioService: usuarioService,
      projetoService: projetoService,
      equipamentoService: equipamentoService,
      maoDeObraService: maoDeObraService,
      obraService: obraService,
      projetoEmpresaService: projetoEmpresaService,
      diarioObraConsultarService: diarioObraConsultarService,
      contatoService: contatoService,
      dioClient: dioClient,
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final LoginService loginService;
  final StorageService storageService;
  final UsuarioService usuarioService;
  final ProjetoService projetoService;
  final EquipamentoService equipamentoService;
  final MaoDeObraService maoDeObraService;
  final ObraService obraService;
  final ProjetoEmpresaService projetoEmpresaService;
  final DiarioObraConsultarService diarioObraConsultarService;
  final ContatoService contatoService;
  final DioClient dioClient;

  const MyApp({
    super.key,
    required this.database,
    required this.loginService,
    required this.storageService,
    required this.usuarioService,
    required this.projetoService,
    required this.equipamentoService,
    required this.maoDeObraService,
    required this.obraService,
    required this.projetoEmpresaService,
    required this.diarioObraConsultarService,
    required this.contatoService,
    required this.dioClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => database),
        Provider(create: (_) => projetoService),
        Provider(create: (_) => equipamentoService),
        Provider(create: (_) => maoDeObraService),
        Provider(create: (_) => usuarioService),
        Provider(create: (_) => obraService),
        Provider(create: (_) => projetoEmpresaService),
        Provider(create: (_) => diarioObraConsultarService),
        Provider(create: (_) => contatoService),
        Provider(create: (_) => dioClient),
        Provider<AppDatabase>(create: (_) => database),
        Provider<Dio>(create: (_) => dioClient.dio),
        ProxyProvider2<Dio, AppDatabase, ImageService>(
          update: (_, dio, db, __) => ImageService(dio, db),
          ),
        Provider<ImageService>(
          create: (context) => ImageService(
            context.read<Dio>(),
            context.read<AppDatabase>(),
          )),
        Provider<PdfService>(
          create: (context) => PdfService(
            context.read<DioClient>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            database: database,
            loginService: loginService,
            storageService: storageService,
            usuarioService: usuarioService,
          ),
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('pt', 'BR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,

          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 15, 135, 233),
            surface: Colors.white, 
          ),

          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color.fromARGB(255, 236, 238, 238),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 15, 135, 233)),
            ),
            labelStyle: TextStyle(color: Colors.black54),
          ),

          // Tema do PopupMenuButton
          popupMenuTheme: const PopupMenuThemeData(
            color: Colors.white, // Cor de fundo do menu popup
            surfaceTintColor: Colors.transparent, // Remove o tint do Material 3
          ),
        ),
        home: const AppRouter(),
      ),
    );
  }
}

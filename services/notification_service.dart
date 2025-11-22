import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Solicita permissão no Android 13+
    if (await _needsPermission()) {
      await _requestPermission();
    }
  }

  Future<bool> _needsPermission() async {
    final plugin = _notifications.resolvePlatformSpecificImplementation
        <AndroidFlutterLocalNotificationsPlugin>();
    return (await plugin?.areNotificationsEnabled()) == false;
  }

  Future<void> _requestPermission() async {
    final plugin = _notifications.resolvePlatformSpecificImplementation
        <AndroidFlutterLocalNotificationsPlugin>();
    await plugin?.requestNotificationsPermission();
  }

  Future<void> showSyncSuccess() async {
    const androidDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sincronização',
      channelDescription: 'Notificações de sincronização de dados',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Sincronização Concluída',
      'Seus dados foram enviados com sucesso!',
      details,
    );
  }

  Future<void> showSyncError(String error) async {
    const androidDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sincronização',
      channelDescription: 'Notificações de sincronização de dados',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Erro na Sincronização',
      'Não foi possível sincronizar: $error',
      details,
    );
  }

  Future<void> showSyncInProgress() async {
    const androidDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sincronização',
      channelDescription: 'Notificações de sincronização de dados',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showProgress: true,
      indeterminate: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      'Sincronizando',
      'Enviando dados para o servidor...',
      details,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
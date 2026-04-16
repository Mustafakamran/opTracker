import 'dart:async';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/notification_log_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../core/constants/enums.dart';
import 'notification_parser_service.dart';

/// Bridges Android notification listener with transaction parsing.
class NotificationListenerManager {
  final NotificationParserService _parser = NotificationParserService();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final _uuid = const Uuid();

  StreamSubscription? _subscription;
  final _transactionController = StreamController<TransactionModel>.broadcast();

  Stream<TransactionModel> get onNewTransaction => _transactionController.stream;

  /// Check if notification listener permission is granted.
  Future<bool> hasPermission() async {
    return await NotificationListenerService.isPermissionGranted();
  }

  /// Request notification listener permission.
  Future<void> requestPermission() async {
    await NotificationListenerService.requestPermission();
  }

  /// Start listening for notifications.
  void startListening(String userId) {
    _subscription?.cancel();
    _subscription = NotificationListenerService.notificationsStream.listen(
      (event) => _handleNotification(event, userId),
    );
  }

  /// Stop listening for notifications.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleNotification(
    ServiceNotificationEvent event,
    String userId,
  ) async {
    final packageName = event.packageName;
    if (packageName == null) return;

    final parsed = _parser.parse(
      packageName: packageName,
      title: event.title,
      text: event.content,
      bigText: event.content,
    );

    if (parsed == null || parsed.amount == null) return;

    final transaction = TransactionModel(
      id: _uuid.v4(),
      userId: userId,
      amount: parsed.amount!,
      description: parsed.description,
      merchant: parsed.merchant,
      category: parsed.category,
      type: parsed.type,
      source: parsed.source,
      parseStatus: ParseStatus.parsed,
      rawNotification: '${event.title}: ${event.content}',
      sourceApp: packageName,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _transactionRepo.insert(transaction);
    _transactionController.add(transaction);
  }

  void dispose() {
    stopListening();
    _transactionController.close();
  }
}

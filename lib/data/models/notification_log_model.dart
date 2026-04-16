import 'package:equatable/equatable.dart';

class NotificationLogModel extends Equatable {
  final String id;
  final String packageName;
  final String? title;
  final String? text;
  final String? bigText;
  final DateTime receivedAt;
  final bool processed;
  final String? linkedTransactionId;

  const NotificationLogModel({
    required this.id,
    required this.packageName,
    this.title,
    this.text,
    this.bigText,
    required this.receivedAt,
    this.processed = false,
    this.linkedTransactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageName': packageName,
      'title': title,
      'text': text,
      'bigText': bigText,
      'receivedAt': receivedAt.toIso8601String(),
      'processed': processed ? 1 : 0,
      'linkedTransactionId': linkedTransactionId,
    };
  }

  factory NotificationLogModel.fromMap(Map<String, dynamic> map) {
    return NotificationLogModel(
      id: map['id'] as String,
      packageName: map['packageName'] as String,
      title: map['title'] as String?,
      text: map['text'] as String?,
      bigText: map['bigText'] as String?,
      receivedAt: DateTime.parse(map['receivedAt'] as String),
      processed: (map['processed'] as int?) == 1,
      linkedTransactionId: map['linkedTransactionId'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, packageName, receivedAt];
}

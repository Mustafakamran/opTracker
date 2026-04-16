import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final AuthMethod authMethod;
  final String? pinHash;
  final String? patternHash;
  final double monthlyBudget;
  final double availableFunds;
  final String currency;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const UserModel({
    required this.id,
    required this.username,
    this.displayName,
    this.email,
    this.avatarUrl,
    required this.authMethod,
    this.pinHash,
    this.patternHash,
    this.monthlyBudget = 0.0,
    this.availableFunds = 0.0,
    this.currency = 'USD',
    required this.createdAt,
    required this.lastLoginAt,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? avatarUrl,
    AuthMethod? authMethod,
    String? pinHash,
    String? patternHash,
    double? monthlyBudget,
    double? availableFunds,
    String? currency,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authMethod: authMethod ?? this.authMethod,
      pinHash: pinHash ?? this.pinHash,
      patternHash: patternHash ?? this.patternHash,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      availableFunds: availableFunds ?? this.availableFunds,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'authMethod': authMethod.name,
      'pinHash': pinHash,
      'patternHash': patternHash,
      'monthlyBudget': monthlyBudget,
      'availableFunds': availableFunds,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      displayName: map['displayName'] as String?,
      email: map['email'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      authMethod: AuthMethod.values.byName(map['authMethod'] as String),
      pinHash: map['pinHash'] as String?,
      patternHash: map['patternHash'] as String?,
      monthlyBudget: (map['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
      availableFunds: (map['availableFunds'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLoginAt: DateTime.parse(map['lastLoginAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, username, email, authMethod];
}

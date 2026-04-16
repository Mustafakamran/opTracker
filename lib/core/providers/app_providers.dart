import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_listener.dart';
import '../../core/services/budget_suggestion_service.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/budget_model.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/date_helpers.dart';

// ── Services ──────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final notificationListenerProvider = Provider<NotificationListenerManager>(
  (ref) => NotificationListenerManager(),
);

final budgetSuggestionServiceProvider = Provider<BudgetSuggestionService>(
  (ref) => BudgetSuggestionService(),
);

// ── Repositories ──────────────────────────────────────────────────
final transactionRepoProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

final userRepoProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

final budgetRepoProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(),
);

// ── Auth State ────────────────────────────────────────────────────
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>(
  (ref) => CurrentUserNotifier(ref.read(authServiceProvider)),
);

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    state = await _authService.getCurrentUser();
  }

  Future<void> signInWithGoogle() async {
    state = await _authService.signInWithGoogle();
  }

  Future<UserModel?> createLocalUser({
    required String username,
    required String displayName,
    String? pin,
    String? pattern,
  }) async {
    final user = await _authService.createLocalUser(
      username: username,
      displayName: displayName,
      pin: pin,
      pattern: pattern,
    );
    state = user;
    return user;
  }

  Future<bool> signInWithPin(String username, String pin) async {
    final user = await _authService.signInWithPin(username, pin);
    state = user;
    return user != null;
  }

  Future<bool> signInWithPattern(String username, String pattern) async {
    final user = await _authService.signInWithPattern(username, pattern);
    state = user;
    return user != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }

  void updateUser(UserModel user) {
    state = user;
  }
}

// ── Theme ─────────────────────────────────────────────────────────
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light

// ── Time Period ───────────────────────────────────────────────────
final selectedPeriodProvider = StateProvider<TimePeriod>(
  (ref) => TimePeriod.monthly,
);

// ── Transactions ──────────────────────────────────────────────────
final transactionsProvider = FutureProvider.family<List<TransactionModel>, String>(
  (ref, userId) async {
    final repo = ref.read(transactionRepoProvider);
    return await repo.getByUserId(userId, limit: 100);
  },
);

final recentTransactionsProvider = FutureProvider<List<TransactionModel>>(
  (ref) async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    final repo = ref.read(transactionRepoProvider);
    return await repo.getByUserId(user.id, limit: 5);
  },
);

final periodTransactionsProvider = FutureProvider<List<TransactionModel>>(
  (ref) async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    final period = ref.watch(selectedPeriodProvider);
    final (start, end) = DateHelpers.rangeForPeriod(period);
    final repo = ref.read(transactionRepoProvider);
    return await repo.getByDateRange(user.id, start, end);
  },
);

// ── Dashboard Stats ───────────────────────────────────────────────
final totalSpendingProvider = FutureProvider<double>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0.0;
  final period = ref.watch(selectedPeriodProvider);
  final (start, end) = DateHelpers.rangeForPeriod(period);
  final repo = ref.read(transactionRepoProvider);
  return await repo.getTotalSpending(user.id, start, end);
});

final totalIncomeProvider = FutureProvider<double>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0.0;
  final period = ref.watch(selectedPeriodProvider);
  final (start, end) = DateHelpers.rangeForPeriod(period);
  final repo = ref.read(transactionRepoProvider);
  return await repo.getTotalIncome(user.id, start, end);
});

final categorySpendingProvider = FutureProvider<Map<TransactionCategory, double>>(
  (ref) async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return {};
    final period = ref.watch(selectedPeriodProvider);
    final (start, end) = DateHelpers.rangeForPeriod(period);
    final repo = ref.read(transactionRepoProvider);
    return await repo.getSpendingByCategory(user.id, start, end);
  },
);

// ── Budgets ───────────────────────────────────────────────────────
final budgetsProvider = FutureProvider<List<BudgetModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.read(budgetRepoProvider);
  return await repo.getActiveBudgets(user.id);
});

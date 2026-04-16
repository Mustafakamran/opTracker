import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/gemma_service.dart';
import '../../../core/services/ai_budget_service.dart';
import '../../../widgets/common/op_card.dart';

/// Riverpod providers for AI state
final gemmaServiceProvider = Provider<GemmaService>((ref) => GemmaService());
final aiBudgetServiceProvider = Provider<AiBudgetService>((ref) => AiBudgetService());

final modelStatusProvider = FutureProvider<_ModelStatus>((ref) async {
  final gemma = ref.read(gemmaServiceProvider);
  final available = await gemma.isModelAvailable();
  final sizeMB = available ? await gemma.getModelSizeMB() : 0;
  return _ModelStatus(
    isImported: available,
    sizeMB: sizeMB,
    isInitialized: gemma.isInitialized,
  );
});

class _ModelStatus {
  final bool isImported;
  final int sizeMB;
  final bool isInitialized;
  const _ModelStatus({
    required this.isImported,
    required this.sizeMB,
    required this.isInitialized,
  });
}

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  bool _isImporting = false;
  bool _isInitializing = false;
  String? _error;
  String? _success;

  Future<void> _pickAndImportModel() async {
    setState(() {
      _isImporting = true;
      _error = null;
      _success = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isImporting = false);
        return;
      }

      final file = result.files.first;
      final uri = file.uri?.toString() ?? file.path;

      if (uri == null) {
        setState(() {
          _error = 'Could not access the selected file.';
          _isImporting = false;
        });
        return;
      }

      // Import via native side (copies to app's private storage)
      final gemma = ref.read(gemmaServiceProvider);
      final success = await gemma.importModelFromUri(uri);

      if (success) {
        setState(() => _success = 'Model imported successfully!');
        ref.invalidate(modelStatusProvider);
      } else {
        setState(() => _error = 'Failed to import model. Make sure it\'s a valid .bin file.');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isInitializing = true;
      _error = null;
      _success = null;
    });

    try {
      final gemma = ref.read(gemmaServiceProvider);
      final success = await gemma.initialize();

      if (success) {
        setState(() => _success = 'Gemma is ready! AI suggestions are now enabled.');
        ref.invalidate(modelStatusProvider);
      } else {
        setState(() => _error = 'Failed to initialize. The model file may be corrupted or incompatible.');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _deleteModel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove AI Model?'),
        content: const Text('This will free up storage space. You can import the model again later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final gemma = ref.read(gemmaServiceProvider);
    await gemma.deleteModel();
    ref.invalidate(modelStatusProvider);
    setState(() {
      _success = 'Model removed.';
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(modelStatusProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Budget Assistant'),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // Header
          OpCard(
            animate: true,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: const Icon(LucideIcons.brain, color: Colors.white, size: 28),
                ),
                AppSpacing.vGapMd,
                Text('On-Device AI', style: Theme.of(context).textTheme.titleMedium),
                AppSpacing.vGapXs,
                Text(
                  'Gemma 2B runs entirely on your phone.\nNo internet needed. Your data stays private.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.zinc500,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // Status
          statusAsync.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            )),
            error: (_, __) => const Text('Error checking model status'),
            data: (status) => Column(
              children: [
                // Model status card
                OpCard(
                  animate: true,
                  animationDelay: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: status.isImported
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.zinc100,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Icon(
                              status.isImported ? LucideIcons.checkCircle : LucideIcons.x,
                              size: 18,
                              color: status.isImported ? AppColors.success : AppColors.zinc400,
                            ),
                          ),
                          AppSpacing.hGapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status.isImported ? 'Model Imported' : 'No Model',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  status.isImported
                                      ? '${status.sizeMB} MB · Gemma 2B INT4'
                                      : 'Import a model to enable AI suggestions',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.zinc400,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (status.isInitialized)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              ),
                              child: Text(
                                'Active',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                AppSpacing.vGapBase,

                // Actions
                if (!status.isImported) ...[
                  // Import button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isImporting ? null : _pickAndImportModel,
                      icon: _isImporting
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(LucideIcons.folderOpen, size: 18),
                      label: Text(_isImporting ? 'Importing...' : 'Select Model File'),
                    ),
                  )
                      .animate()
                      .scaleXY(begin: 0.95, end: 1, duration: 300.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 200.ms),

                  AppSpacing.vGapBase,

                  // Instructions
                  OpCard(
                    animate: true,
                    animationDelay: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                            AppSpacing.hGapSm,
                            Text('How to get the model',
                                style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        AppSpacing.vGapMd,
                        _InstructionStep(number: '1', text: 'Download Gemma 2B INT4 from Kaggle or HuggingFace'),
                        _InstructionStep(number: '2', text: 'Extract the .tar.gz to get the .bin file (~1 GB)'),
                        _InstructionStep(number: '3', text: 'Tap "Select Model File" above and pick the .bin file'),
                        AppSpacing.vGapSm,
                        Text(
                          'The model runs 100% on your device. No data is sent anywhere.',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.zinc400,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Model is imported — show initialize / delete
                  if (!status.isInitialized)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isInitializing ? null : _initializeModel,
                        icon: _isInitializing
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(LucideIcons.zap, size: 18),
                        label: Text(_isInitializing ? 'Loading model...' : 'Activate AI'),
                      ),
                    ),

                  if (status.isInitialized)
                    OpCard(
                      child: Row(
                        children: [
                          Icon(LucideIcons.sparkles, size: 20, color: AppColors.primary),
                          AppSpacing.hGapMd,
                          Expanded(
                            child: Text(
                              'AI is active. Budget suggestions will use Gemma for personalized advice.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.zinc600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  AppSpacing.vGapBase,

                  // Delete model
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _deleteModel,
                      icon: const Icon(LucideIcons.trash2, size: 16),
                      label: const Text('Remove Model'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Feedback messages
          if (_error != null) ...[
            AppSpacing.vGapBase,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 16),
                  AppSpacing.hGapSm,
                  Expanded(child: Text(_error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error))),
                ],
              ),
            ).animate().shakeX(hz: 3, amount: 3, duration: 300.ms),
          ],

          if (_success != null) ...[
            AppSpacing.vGapBase,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, color: AppColors.success, size: 16),
                  AppSpacing.hGapSm,
                  Expanded(child: Text(_success!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success))),
                ],
              ),
            ).animate().scaleXY(begin: 0.95, end: 1, duration: 300.ms, curve: Curves.elasticOut),
          ],

          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;
  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

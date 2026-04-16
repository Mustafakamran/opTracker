import 'package:flutter/services.dart';

/// Flutter bridge to on-device Gemma via MediaPipe LLM Inference.
/// User picks the model file from their phone storage.
class GemmaService {
  static const _channel = MethodChannel('com.optracker.app/gemma');

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Check if a model file has been imported into the app.
  Future<bool> isModelAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isModelAvailable') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Get model file size in MB.
  Future<int> getModelSizeMB() async {
    try {
      final size = await _channel.invokeMethod<int>('getModelSizeMB');
      return size ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Import a model file from a content URI (from file_picker).
  /// The native side copies it to app's private storage.
  Future<bool> importModelFromUri(String uri) async {
    try {
      return await _channel.invokeMethod<bool>('importModelFromUri', {
        'uri': uri,
      }) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Delete the imported model to free storage.
  Future<bool> deleteModel() async {
    try {
      _initialized = false;
      return await _channel.invokeMethod<bool>('deleteModel') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Initialize the Gemma model for inference.
  Future<bool> initialize() async {
    try {
      _initialized = await _channel.invokeMethod<bool>('initialize') ?? false;
      return _initialized;
    } catch (_) {
      _initialized = false;
      return false;
    }
  }

  /// Generate a response from the local Gemma model.
  Future<String> generate(String prompt) async {
    if (!_initialized) return '';
    try {
      return await _channel.invokeMethod<String>('generateResponse', {
        'prompt': prompt,
      }) ?? '';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Clean up model resources.
  Future<void> close() async {
    try {
      await _channel.invokeMethod('close');
      _initialized = false;
    } catch (_) {}
  }
}

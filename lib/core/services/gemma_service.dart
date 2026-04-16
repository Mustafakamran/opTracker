import 'package:flutter/services.dart';

/// Flutter bridge to on-device Gemma 3 1B via MediaPipe LLM Inference.
class GemmaService {
  static const _channel = MethodChannel('com.optracker.app/gemma');

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Check if the Gemma model file exists on device.
  Future<bool> isModelAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isModelAvailable') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Get the file path where the model should be placed.
  Future<String> getModelPath() async {
    try {
      return await _channel.invokeMethod<String>('getModelPath') ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Initialize the Gemma model. Call after confirming model is available.
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

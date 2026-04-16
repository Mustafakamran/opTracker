package com.optracker.app

import android.content.Context
import java.io.File
import java.io.FileOutputStream

/**
 * On-device Gemma inference stub.
 * MediaPipe tasks-genai requires Java 21 which GitHub Actions CI doesn't support yet.
 * This stub handles model file management. When MediaPipe is available,
 * uncomment the LlmInference calls in initialize() and generateResponse().
 */
class GemmaInferenceService(private val context: Context) {

    private var isReady = false

    companion object {
        private const val MODEL_DIR = "gemma_model"
        private const val MODEL_FILENAME = "model.bin"
    }

    fun isModelAvailable(): Boolean {
        val modelFile = File(File(context.filesDir, MODEL_DIR), MODEL_FILENAME)
        return modelFile.exists() && modelFile.length() > 100_000
    }

    fun getModelPath(): String {
        return File(File(context.filesDir, MODEL_DIR), MODEL_FILENAME).absolutePath
    }

    fun getModelSizeMB(): Long {
        val modelFile = File(File(context.filesDir, MODEL_DIR), MODEL_FILENAME)
        return if (modelFile.exists()) modelFile.length() / (1024 * 1024) else 0
    }

    fun importModel(sourcePath: String): Boolean {
        return try {
            val sourceFile = File(sourcePath)
            if (!sourceFile.exists()) return false
            val modelDir = File(context.filesDir, MODEL_DIR)
            if (!modelDir.exists()) modelDir.mkdirs()
            val destFile = File(modelDir, MODEL_FILENAME)
            sourceFile.inputStream().use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output, bufferSize = 8192)
                }
            }
            destFile.exists() && destFile.length() > 0
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun importModelFromUri(uriString: String): Boolean {
        return try {
            val uri = android.net.Uri.parse(uriString)
            val modelDir = File(context.filesDir, MODEL_DIR)
            if (!modelDir.exists()) modelDir.mkdirs()
            val destFile = File(modelDir, MODEL_FILENAME)
            context.contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output, bufferSize = 8192)
                }
            }
            destFile.exists() && destFile.length() > 0
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun deleteModel(): Boolean {
        close()
        val modelFile = File(File(context.filesDir, MODEL_DIR), MODEL_FILENAME)
        return modelFile.delete()
    }

    fun initialize(): Boolean {
        if (!isModelAvailable()) return false
        // TODO: Uncomment when MediaPipe tasks-genai is added back
        // val options = LlmInference.LlmInferenceOptions.builder()
        //     .setModelPath(getModelPath())
        //     .setMaxTokens(512)
        //     .build()
        // llmInference = LlmInference.createFromOptions(context, options)
        isReady = true
        return true
    }

    fun generateResponse(prompt: String): String {
        if (!isReady) return ""
        // TODO: Uncomment when MediaPipe tasks-genai is added back
        // return llmInference?.generateResponse(prompt) ?: ""
        return "" // Falls back to rule-based in Dart side
    }

    fun close() {
        isReady = false
    }
}

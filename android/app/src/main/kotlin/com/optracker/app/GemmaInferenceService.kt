package com.optracker.app

import android.content.Context
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import java.io.File
import java.io.FileOutputStream

/**
 * On-device Gemma inference using MediaPipe LLM Inference API.
 * User picks the model file from their phone storage,
 * which gets copied to app's private directory for access.
 */
class GemmaInferenceService(private val context: Context) {

    private var llmInference: LlmInference? = null
    private var currentModelPath: String? = null

    companion object {
        private const val MODEL_DIR = "gemma_model"
        private const val MODEL_FILENAME = "model.bin"
    }

    /** Check if a model has been imported into the app. */
    fun isModelAvailable(): Boolean {
        val modelFile = File(File(context.filesDir, MODEL_DIR), MODEL_FILENAME)
        return modelFile.exists() && modelFile.length() > 100_000 // at least 100KB
    }

    /** Get the internal model file path. */
    fun getModelPath(): String {
        return File(File(context.filesDir, MODEL_DIR), MODEL_FILENAME).absolutePath
    }

    /** Get model file size in MB, or 0 if not available. */
    fun getModelSizeMB(): Long {
        val modelFile = File(File(context.filesDir, MODEL_DIR), MODEL_FILENAME)
        return if (modelFile.exists()) modelFile.length() / (1024 * 1024) else 0
    }

    /**
     * Copy user-picked model file from a source path into the app's private storage.
     * Returns true if successful.
     */
    fun importModel(sourcePath: String): Boolean {
        return try {
            val sourceFile = File(sourcePath)
            if (!sourceFile.exists()) return false

            val modelDir = File(context.filesDir, MODEL_DIR)
            if (!modelDir.exists()) modelDir.mkdirs()

            val destFile = File(modelDir, MODEL_FILENAME)

            // Copy file
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

    /**
     * Import model from a content URI (from file picker).
     * Returns true if successful.
     */
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

    /** Delete the imported model to free storage. */
    fun deleteModel(): Boolean {
        close()
        val modelFile = File(File(context.filesDir, MODEL_DIR), MODEL_FILENAME)
        return modelFile.delete()
    }

    /** Initialize the LLM inference engine. */
    fun initialize(): Boolean {
        if (!isModelAvailable()) return false

        return try {
            val modelPath = getModelPath()
            val options = LlmInference.LlmInferenceOptions.builder()
                .setModelPath(modelPath)
                .setMaxTokens(512)
                .build()

            llmInference = LlmInference.createFromOptions(context, options)
            currentModelPath = modelPath
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /** Run inference. */
    fun generateResponse(prompt: String): String {
        val inference = llmInference ?: return "Model not initialized"
        return try {
            inference.generateResponse(prompt)
        } catch (e: Exception) {
            "Error: ${e.message}"
        }
    }

    /** Clean up. */
    fun close() {
        try {
            llmInference?.close()
        } catch (_: Exception) {}
        llmInference = null
        currentModelPath = null
    }
}

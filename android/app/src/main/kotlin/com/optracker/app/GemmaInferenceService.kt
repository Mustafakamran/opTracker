package com.optracker.app

import android.content.Context
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import kotlinx.coroutines.*
import java.io.File

/**
 * On-device Gemma 3 1B inference using MediaPipe LLM Inference API.
 * The model file must be downloaded separately and placed in app's files directory.
 */
class GemmaInferenceService(private val context: Context) {

    private var llmInference: LlmInference? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    companion object {
        // Expected model filename in app's files dir
        const val MODEL_FILENAME = "gemma3-1b-it-int4.task"
    }

    /** Check if the Gemma model file is available on device. */
    fun isModelAvailable(): Boolean {
        val modelFile = File(context.filesDir, MODEL_FILENAME)
        return modelFile.exists() && modelFile.length() > 0
    }

    /** Get the expected model file path for download guidance. */
    fun getModelPath(): String {
        return File(context.filesDir, MODEL_FILENAME).absolutePath
    }

    /** Initialize the LLM inference engine with the local model. */
    fun initialize(): Boolean {
        if (!isModelAvailable()) return false

        return try {
            val modelPath = File(context.filesDir, MODEL_FILENAME).absolutePath
            val options = LlmInference.LlmInferenceOptions.builder()
                .setModelPath(modelPath)
                .setMaxTokens(512)
                .setTopK(40)
                .setTemperature(0.7f)
                .build()

            llmInference = LlmInference.createFromOptions(context, options)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /** Run inference with the given prompt. Returns generated text. */
    fun generateResponse(prompt: String): String {
        val inference = llmInference ?: return "Model not initialized"

        return try {
            inference.generateResponse(prompt)
        } catch (e: Exception) {
            "Error: ${e.message}"
        }
    }

    /** Clean up resources. */
    fun close() {
        llmInference?.close()
        llmInference = null
        scope.cancel()
    }
}

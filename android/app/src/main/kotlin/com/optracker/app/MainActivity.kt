package com.optracker.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.optracker.app/gemma"
    private var gemmaService: GemmaInferenceService? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        gemmaService = GemmaInferenceService(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isModelAvailable" -> {
                    result.success(gemmaService?.isModelAvailable() ?: false)
                }
                "getModelPath" -> {
                    result.success(gemmaService?.getModelPath() ?: "")
                }
                "initialize" -> {
                    scope.launch(Dispatchers.IO) {
                        val success = gemmaService?.initialize() ?: false
                        withContext(Dispatchers.Main) {
                            result.success(success)
                        }
                    }
                }
                "generateResponse" -> {
                    val prompt = call.argument<String>("prompt") ?: ""
                    scope.launch(Dispatchers.IO) {
                        val response = gemmaService?.generateResponse(prompt) ?: "Model not available"
                        withContext(Dispatchers.Main) {
                            result.success(response)
                        }
                    }
                }
                "close" -> {
                    gemmaService?.close()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        gemmaService?.close()
        scope.cancel()
        super.onDestroy()
    }
}

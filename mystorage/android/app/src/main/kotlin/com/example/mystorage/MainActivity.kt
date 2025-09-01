package com.example.mystorage
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mystorage/uri_permission"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "takePersistableUriPermission" -> {
                    val uriString = call.arguments as String
                    takePersistableUriPermission(uriString)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun takePersistableUriPermission(uriString: String) {
        val uri = Uri.parse(uriString)
        val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        contentResolver.takePersistableUriPermission(uri, takeFlags)
    }
}


package com.example.annadanam_app

import io.flutter.embedding.android.FlutterActivity
import android.view.WindowManager
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        allowScreenshotsDelayed("onCreate")
    }

    override fun onResume() {
        super.onResume()
        allowScreenshotsDelayed("onResume")
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            allowScreenshotsDelayed("onWindowFocusChanged")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.annadanam.app/security").setMethodCallHandler { call, result ->
            if (call.method == "disableSecure") {
                allowScreenshots("MethodChannel Request")
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun allowScreenshotsDelayed(source: String) {
        // Delay slightly because some devices (VIVO/OPPO) re-enable the flag 
        // immediately after lifecycle methods finish.
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            allowScreenshots(source)
        }, 500)
    }

    private fun allowScreenshots(source: String) {
        try {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            window.addFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED)
            println("MainActivity: FLAG_SECURE aggressively cleared from $source")
        } catch (e: Exception) {
            println("MainActivity: Error clearing FLAG_SECURE: ${e.message}")
        }
    }
}

package com.heartlink.heartlink_app

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.heartlink/wallpaper").setMethodCallHandler { call, result ->
            when (call.method) {
                "setWallpaper" -> {
                    try {
                        val bytes = call.argument<ByteArray>("bytes")!!
                        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                        val wm = WallpaperManager.getInstance(applicationContext)
                        wm.setBitmap(bitmap)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "resetWallpaper" -> {
                    try {
                        val wm = WallpaperManager.getInstance(applicationContext)
                        wm.clear()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}

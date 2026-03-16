package com.heartlink.heartlink_app

import android.content.Context
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PixelFormat
import android.os.Build
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.heartlink/overlay"
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showOverlay" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (!Settings.canDrawOverlays(this)) {
                                val intent = Intent(
                                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                                startActivity(intent)
                                result.success(false)
                                return@setMethodCallHandler
                            }
                        }
                        val data = call.arguments as? Map<*, *>
                        showOverlay(data)
                        result.success(true)
                    }
                    "hideOverlay" -> {
                        hideOverlay()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun showOverlay(data: Map<*, *>?) {
        hideOverlay()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else WindowManager.LayoutParams.TYPE_PHONE

        val params = WindowManager.LayoutParams(
            600, 400,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.BOTTOM or Gravity.END
        params.x = 16
        params.y = 100

        val view = DrawingOverlayView(this, data) {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent?.putExtra("goto_draw", true)
            startActivity(intent)
            hideOverlay()
        }

        // Drag support
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f

        view.setOnTouchListener { v, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = initialX + (event.rawX - initialTouchX).toInt()
                    params.y = initialY - (event.rawY - initialTouchY).toInt()
                    windowManager?.updateViewLayout(view, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY
                    if (Math.abs(dx) < 10 && Math.abs(dy) < 10) {
                        v.performClick()
                    }
                    true
                }
                else -> false
            }
        }

        overlayView = view
        windowManager?.addView(view, params)
    }

    private fun hideOverlay() {
        overlayView?.let {
            windowManager?.removeView(it)
            overlayView = null
        }
    }
}

class DrawingOverlayView(
    context: Context,
    private val data: Map<*, *>?,
    private val onClick: () -> Unit
) : View(context) {

    private val bgPaint = Paint().apply {
        color = Color.parseColor("#1A0F2E")
        style = Paint.Style.FILL
    }

    private val textPaint = Paint().apply {
        color = Color.parseColor("#F0607A")
        textSize = 28f
        isAntiAlias = true
    }

    private val strokePaint = Paint().apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
        isAntiAlias = true
    }

    init {
        setOnClickListener { onClick() }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        // Background
        canvas.drawRoundRect(0f, 0f, width.toFloat(), height.toFloat(),
            24f, 24f, bgPaint)

        // Title
        canvas.drawText("💕 Partner ki Drawing", 20f, 40f, textPaint)

        // Draw strokes
        val strokes = data?.get("strokes") as? Map<*, *>
        strokes?.values?.forEach { stroke ->
            val s = stroke as? Map<*, *> ?: return@forEach
            val pts = s["points"] as? List<*> ?: return@forEach
            if (pts.size < 2) return@forEach

            val color = (s["color"] as? Number)?.toInt() ?: Color.WHITE
            val size = (s["size"] as? Number)?.toFloat() ?: 4f

            strokePaint.color = color
            strokePaint.strokeWidth = size * 0.8f

            val path = android.graphics.Path()
            val first = pts[0] as? Map<*, *> ?: return@forEach
            val fx = ((first["x"] as? Number)?.toFloat() ?: 0f) * 0.5f
            val fy = ((first["y"] as? Number)?.toFloat() ?: 0f) * 0.5f + 60f
            path.moveTo(fx, fy)

            for (i in 1 until pts.size) {
                val p = pts[i] as? Map<*, *> ?: continue
                val x = ((p["x"] as? Number)?.toFloat() ?: 0f) * 0.5f
                val y = ((p["y"] as? Number)?.toFloat() ?: 0f) * 0.5f + 60f
                path.lineTo(x, y)
            }
            canvas.drawPath(path, strokePaint)
        }

        // Tap hint
        val hintPaint = Paint().apply {
            color = Color.parseColor("#666666")
            textSize = 22f
        }
        canvas.drawText("Tap karo drawing dekhne ke liye →",
            20f, height.toFloat() - 16f, hintPaint)
    }
}

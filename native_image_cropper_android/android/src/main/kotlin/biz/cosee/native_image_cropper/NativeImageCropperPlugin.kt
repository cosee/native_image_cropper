package biz.cosee.native_image_cropper

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import android.graphics.RectF
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/** NativeImageCropperPlugin */
class NativeImageCropperPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        private val threadPool: ExecutorService = Executors.newCachedThreadPool()
    }

    // / The MethodChannel that will the communication between Flutter and native Android
    // /
    // / This local reference serves to register the plugin with the Flutter Engine and unregister it
    // / when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(
                flutterPluginBinding.binaryMessenger,
                "biz.cosee/native_image_cropper_android"
            )
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onMethodCall(call: MethodCall, result: Result) {
        threadPool.execute {
            when (call.method) {
                "cropRect" -> handleCropRect(call, result)
                "cropOval" -> handleCropOval(call, result)
                else -> result.notImplemented()
            }
        }
    }
}

private fun handleCropRect(call: MethodCall, result: Result) {
    val bytes: ByteArray = call.argument("bytes")!!
    val x: Int = call.argument("x")!!
    val y: Int = call.argument("y")!!
    val width: Int = call.argument("width")!!
    val height: Int = call.argument("height")!!

    try {
        val croppedBitmap: Bitmap = getCroppedRectBitmap(bytes, x, y, width, height)
        result.success(bitmapToByteArray(croppedBitmap))
    } catch (e: IllegalArgumentException) {
        result.error("IllegalArgumentException", e.message, null)
    }
}

private fun handleCropOval(call: MethodCall, result: Result) {
    val bytes: ByteArray = call.argument("bytes")!!
    val x: Int = call.argument("x")!!
    val y: Int = call.argument("y")!!
    val width: Int = call.argument("width")!!
    val height: Int = call.argument("height")!!

    try {
        val croppedBitmap = getCroppedRectBitmap(bytes, x, y, width, height)
        val ovalBitmap = croppedBitmap.createOvalBitmap()
        result.success(bitmapToByteArray(ovalBitmap))
    } catch (e: IllegalArgumentException) {
        result.error("IllegalArgumentException", e.message, null)
    }
}

private fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
    val stream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
    val byteArray = stream.toByteArray()
    stream.flush()
    stream.close()
    return byteArray
}

private fun Bitmap.createOvalBitmap(): Bitmap {
    val output = Bitmap.createBitmap(this.width, this.height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(output)
    val paint = Paint()
    val rect = Rect(0, 0, this.width, this.height)

    paint.isAntiAlias = true
    canvas.drawOval(
        RectF(0f, 0f, width.toFloat(), height.toFloat()),
        paint,
    )
    paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
    canvas.drawBitmap(this, rect, rect, paint)

    return output
}

private fun getCroppedRectBitmap(
    bytes: ByteArray,
    x: Int,
    y: Int,
    width: Int,
    height: Int
): Bitmap {
    val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.count())

    return Bitmap.createBitmap(
        bitmap,
        x,
        y,
        width,
        height,
        null,
        false
    )
}

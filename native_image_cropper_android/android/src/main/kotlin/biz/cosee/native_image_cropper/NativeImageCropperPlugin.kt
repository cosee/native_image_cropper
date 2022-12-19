package biz.cosee.native_image_cropper

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import kotlin.concurrent.thread

/** NativeImageCropperPlugin */
class NativeImageCropperPlugin : FlutterPlugin, MethodCallHandler {
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
        thread {
            when (call.method) {
                "cropRect" -> handleCropRect(call, result)
                "cropCircle" -> handleCropCircle(call, result)
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

private fun handleCropCircle(call: MethodCall, result: Result) {
    val bytes: ByteArray = call.argument("bytes")!!
    val x: Int = call.argument("x")!!
    val y: Int = call.argument("y")!!
    val width: Int = call.argument("width")!!
    val height: Int = call.argument("height")!!

    try {
        val croppedBitmap = getCroppedRectBitmap(bytes, x, y, width, height)
        val circleBitmap = croppedBitmap.createCircleBitmap()
        result.success(bitmapToByteArray(circleBitmap))
    } catch (e: IllegalArgumentException) {
        result.error("IllegalArgumentException", e.message, null)
    }
}

private fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
    val stream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
    return stream.toByteArray()
}

private fun Bitmap.createCircleBitmap(): Bitmap {
    val output = Bitmap.createBitmap(this.width, this.height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(output)
    val paint = Paint()
    val rect = Rect(0, 0, this.width, this.height)

    paint.isAntiAlias = true
    canvas.drawCircle(
        (this.width / 2).toFloat(),
        (this.height / 2).toFloat(),
        (this.width / 2).toFloat(),
        paint
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

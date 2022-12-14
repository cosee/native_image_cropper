package biz.cosee.native_image_cropper

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

/** NativeImageCropperPlugin */
class NativeImageCropperPlugin : FlutterPlugin, MethodCallHandler {
    // / The MethodChannel that will the communication between Flutter and native Android
    // /
    // / This local reference serves to register the plugin with the Flutter Engine and unregister it
    // / when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "biz.cosee/native_image_cropper")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "cropRect" -> {
                val croppedBytes: ByteArray? = handleCropRect(call)
                if (croppedBytes != null) {
                    result.success(croppedBytes)
                } else {
                    // TODO fill error message
                    result.error("ERROR", "Received null", null)
                }
            }
            "cropCircle" -> {
                val croppedBytes: ByteArray? = handleCropCircle(call)
                if (croppedBytes != null) {
                    result.success(croppedBytes)
                } else {
                    // TODO fill error message
                    result.error("ERROR", "Received null", null)
                }
            }
            else -> result.notImplemented()
        }
    }
}

// TODO Als eigene Klasse auslagern? Vllt result.success und error auch hier einbauen?
private fun handleCropRect(call: MethodCall): ByteArray? {
    val croppedBitmap: Bitmap = getCroppedRectBitmap(call) ?: return null
    return bitmapToByteArray(croppedBitmap)
}

private fun handleCropCircle(call: MethodCall): ByteArray? {
    val croppedBitmap = getCroppedRectBitmap(call) ?: return null
    val circleBitMap = croppedBitmap.createCircleBitmap()
    return bitmapToByteArray(circleBitMap)
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

// TODO Ohne entpacken
private fun cropRect(bytes: ByteArray, x: Int, y: Int, width: Int, height: Int): Bitmap {
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

private fun getCroppedRectBitmap(call: MethodCall): Bitmap? {
    // TODO Ist es zu defensiv, wenn wir die Arugmente nicht als Non null casten?
    // TODO Methode soll sich nur um das croppen kümmern, das entpacken sollte vorher passieren
    val bytes: ByteArray? = call.argument("bytes")
    val x: Int? = call.argument("x")
    val y: Int? = call.argument("y")
    val width: Int? = call.argument("width")
    val height: Int? = call.argument("height")

    // TODO Logs entfernen wenn android fertig
    Log.i("FLUTTER", "x: $x")
    Log.i("FLUTTER", "y: $y")
    Log.i("FLUTTER", "width: $width")
    Log.i("FLUTTER", "height: $height")

    if (bytes == null || x == null || y == null || width == null || height == null) {
        return null
    }

    // TODO: Catch IllegalArgumentException
    val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.count())

    // TODO Catch IllegalArgumentException ?
    //  -> if the x, y, width, height values are outside of the dimensions of the source bitmap,
    //  or width is <= 0, or height is <= 0, or if the source bitmap has already been recycled
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

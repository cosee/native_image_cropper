package biz.cosee.native_image_cropper

import android.graphics.*
import android.util.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

/** NativeImageCropperPlugin */
class NativeImageCropperPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "biz.cosee/native_image_cropper")
        channel.setMethodCallHandler(this)
    }

    annotation class NonNull

    override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {
        TODO("Not yet implemented")
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "cropRect" -> {
                val croppedBytes: ByteArray? = handleCropRect(call)
                if (croppedBytes != null)
                    result.success(croppedBytes)
                else
                // TODO fill error message
                    result.error("ERROR", "Received null", null)
            }
            "cropCircle" -> {
                val croppedBytes: ByteArray? = handleCropCircle(call)
                if (croppedBytes != null)
                    result.success(croppedBytes)
                else
                // TODO fill error message
                    result.error("ERROR", "Received null", null)

            }
            else -> result.notImplemented()
        }
    }
}

private fun handleCropRect(call: MethodCall): ByteArray? {
    val croppedBitmap: Bitmap = getCroppedRectBitmap(call) ?: return null
    val stream = ByteArrayOutputStream()
    croppedBitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
    return stream.toByteArray()
}

private fun handleCropCircle(call: MethodCall): ByteArray? {

    val croppedBitmap = getCroppedRectBitmap(call) ?: return null
    val circleBitMap = croppedBitmap.createCircleBitmap()
    val stream = ByteArrayOutputStream()
    circleBitMap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
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

private fun getCroppedRectBitmap(call: MethodCall): Bitmap? {
    val bytes: ByteArray? = call.argument("bytes")
    val x: Int? = call.argument("x")
    val y: Int? = call.argument("y")
    val width: Int? = call.argument("width")
    val height: Int? = call.argument("height")

    Log.i("FLUTTER", "x: $x");
    Log.i("FLUTTER", "y: $y");
    Log.i("FLUTTER", "width: $width");
    Log.i("FLUTTER", "height: $height");

    if (bytes == null || x == null || y == null || width == null || height == null)
        return null

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






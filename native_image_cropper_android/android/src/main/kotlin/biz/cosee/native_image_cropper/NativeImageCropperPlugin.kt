package biz.cosee.native_image_cropper

import android.graphics.Bitmap
import android.graphics.BitmapFactory

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
                val croppedBytes : ByteArray? = handleCropRect(call)
                if(croppedBytes != null)
                    result.success(handleCropRect(call))
                else
                    // TODO fill error mesage
                    result.error("ERROR", "Received null", null)
            }
            else -> result.notImplemented()
        }
    }

}

private fun handleCropRect(call: MethodCall): ByteArray? {
    val bytes: ByteArray? = call.argument("bytes")
    val x: Int? = call.argument("x")
    val y: Int? = call.argument("y")
    val width: Int? = call.argument("width")
    val height: Int? = call.argument("height")
    print("bytes: " + bytes);
    print("x: " + x);
    print("y: " + y);
    print("width: " + width);
    print("height: " + height);

    if(bytes == null || x == null || y == null || width == null || height == null)
        return null

    val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.count())
    val croppedBitmap =
        Bitmap.createBitmap(
            bitmap,
            x,
            y,
            width,
            height,
            null,
            false
        )
    val stream = ByteArrayOutputStream()
    croppedBitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
    return stream.toByteArray()
}


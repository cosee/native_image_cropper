package biz.cosee.native_image_cropper

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import android.graphics.RectF
import androidx.exifinterface.media.ExifInterface
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/** The Android implementation of NativeImageCropperPlugin. */
class NativeImageCropperPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        /**
         * Creates a new cached thread pool that creates new threads as needed and reuses
         * previously created threads when they are available. This can be used to execute tasks
         * concurrently.
         */
        private val threadPool: ExecutorService = Executors.newCachedThreadPool()
    }

    /**
     * The MethodChannel that will the communication between Flutter and native Android
     * This local reference serves to register the plugin with the Flutter Engine and unregister it
     * when the Flutter Engine is detached from the Activity.
     */
    private lateinit var channel: MethodChannel

    /**
     * Initializes a [MethodChannel], which is used to communicate between the Flutter code
     * and the native Android code.
     */
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(
                flutterPluginBinding.binaryMessenger,
                "biz.cosee/native_image_cropper_android"
            )
        channel.setMethodCallHandler(this)
    }

    /** Unregisters the [MethodCallHandler] from the Flutter engine. */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    /** Handles Flutter method calls made to this Flutter plugin. */
    override fun onMethodCall(call: MethodCall, result: Result) {
        threadPool.execute {
            when (call.method) {
                "cropRect" -> handleCropRect(call, result)
                "cropOval" -> handleCropOval(call, result)
                else -> result.notImplemented()
            }
        }
    }

    /**  Extracts the arguments from [call] and crops the image in a rectangular shape. */
    private fun handleCropRect(call: MethodCall, result: Result) {
        val bytes = call.argument<ByteArray>("bytes")!!
        val x = call.argument<Int>("x")!!
        val y = call.argument<Int>("y")!!
        val width = call.argument<Int>("width")!!
        val height = call.argument<Int>("height")!!
        val imageFormat = ImageFormat.valueOf(call.argument<String>("imageFormat")!!.uppercase())

        try {
            val croppedBitmap: Bitmap = getCroppedRectBitmap(bytes, x, y, width, height)
            result.success(bitmapToByteArray(croppedBitmap, imageFormat))
        } catch (e: IllegalArgumentException) {
            result.error("IllegalArgumentException", e.message, null)
        }
    }

    /**  Extracts the arguments from [call] and crops the image in a oval shape. */
    private fun handleCropOval(call: MethodCall, result: Result) {
        val bytes = call.argument<ByteArray>("bytes")!!
        val x = call.argument<Int>("x")!!
        val y = call.argument<Int>("y")!!
        val width = call.argument<Int>("width")!!
        val height = call.argument<Int>("height")!!
        val imageFormat = ImageFormat.valueOf(call.argument<String>("imageFormat")!!.uppercase())

        try {
            val croppedBitmap = getCroppedRectBitmap(bytes, x, y, width, height)
            val ovalBitmap = croppedBitmap.createOvalBitmap()
            result.success(bitmapToByteArray(ovalBitmap, imageFormat))
        } catch (e: IllegalArgumentException) {
            result.error("IllegalArgumentException", e.message, null)
        }
    }

    /** Converts a [Bitmap] image to a [ByteArray] by using the given [format] for compression. */
    private fun bitmapToByteArray(bitmap: Bitmap, format: ImageFormat): ByteArray {
        val stream = ByteArrayOutputStream()
        if (format == ImageFormat.JPG) {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
        } else {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        }
        val byteArray = stream.toByteArray()
        stream.flush()
        stream.close()
        return byteArray
    }

    /** Creates a rectangular cropped [Bitmap] of the given [bytes]. */
    private fun getCroppedRectBitmap(
        bytes: ByteArray,
        x: Int,
        y: Int,
        width: Int,
        height: Int
    ): Bitmap {
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.count())
        val exif = ExifInterface(bytes.inputStream())
        val orientation = exif.getAttributeInt(
			ExifInterface.TAG_ORIENTATION,
			ExifInterface.ORIENTATION_NORMAL
			)
	val matrix = Matrix().apply {
		setRotate(
			when(orientation) {
				ExifInterface.ORIENTATION_ROTATE_90 -> 90f
				ExifInterface.ORIENTATION_ROTATE_180 -> 180f
				ExifInterface.ORIENTATION_ROTATE_270 -> 270f
				else -> 0f
			}
		)
	}
	val rotatedBitmap = Bitmap.createBitmap(
		bitmap,
		0,
		0,
		bitmap.width,
		bitmap.height,
		matrix,
		false
	)
	val croppedBitmap = Bitmap.createBitmap(
		rotatedBitmap,
		x,
		y,
		width,
		height,
		null,
		false
	)
	bitmap.recycle()
        return croppedBitmap
    }

    /** Extension method for creating an oval [Bitmap] from a given [Bitmap]. */
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

    /**
     * Represents the image file format. It is used to decide how the image should be
     * compressed.
     */
    private enum class ImageFormat {
        /** Compress the image using JPG, which is usually faster. */
        JPG,

        /** Compress the image using PNG, which is lossless but slower. */
        PNG,
    }
}

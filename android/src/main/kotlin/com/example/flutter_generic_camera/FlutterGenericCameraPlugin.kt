package com.example.flutter_generic_camera

//import com.example.flutter_generic_camera.model.GenericCameraConfiguration

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.result.ActivityResultCallback
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.example.flutter_generic_camera.enum.AssetType
import com.example.flutter_generic_camera.enum.CameraPosition
import com.example.flutter_generic_camera.enum.FlashMode
import com.example.flutter_generic_camera.enum.TorchMode
import com.example.flutter_generic_camera.model.GenericCameraConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
//import io.flutter.embedding.engine.plugins.activity.ActivityAware
import java.net.URL


/** FlutterGenericCameraPlugin  */
class FlutterGenericCameraPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private lateinit var context: Context
    var result: MethodChannel.Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_generic_camera")
        channel.setMethodCallHandler(this)
    }

    fun capturedVideoUrl(videoUrl: URL?) {
        Log.d("FlutterGenericCameraPlugin", "Captured Video Ready")
        if (videoUrl != null) {
            result?.success(mapOf("captured_video" to videoUrl.toString()))
        } else {
            result?.success(mapOf("captured_video" to ""))
        }
    }

     fun capturedImagesPath(capturedImages: List<String>) {
        Log.d("FlutterGenericCameraPlugin", "Captured Images Ready")
        Log.d("CAPTUREIMAGE_SIZE", capturedImages.toString())
        this.result?.success(mapOf("captured_images" to capturedImages))
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        this.result = result
        when (call.method) {
            "openCamera" -> {
                    val args = call.arguments as? Map<String, Any>
                    val config = args?.let { parseConfiguration(it) }
                    if (config != null) {
                        MainActivity.listner = object: ImageListener{
                            override fun imagePath(imageList: ArrayList<String>) {
                                capturedImagesPath(imageList)
                            }

                            override fun videoPath(videoList: String) {
                                capturedVideoUrl(File(videoList).toURI().toURL())
                            }
                        }
                        val cameraIntent = Intent(context, MainActivity::class.java).apply{
                            putExtra("config", config)
                        }
                        cameraIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        context.startActivity(cameraIntent)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid arguments received", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        fun parseConfiguration(args: Map<String, Any>): GenericCameraConfiguration? {
            val captureMode = args["captureMode"] as? Int
            val canCaptureMultiplePhotos = args["canCaptureMultiplePhotos"] as? Boolean
            val cameraPosition = args["cameraPosition"] as? Int
            val cameraPhotoFlash = args["cameraPhotoFlash"] as? Int
            val cameraVideoTorch = args["cameraVideoTorch"] as? Int

            return GenericCameraConfiguration(
                captureMode = if (captureMode == 0) AssetType.PHOTO else AssetType.VIDEO,
                canCaptureMultiplePhotos = canCaptureMultiplePhotos!!,
                cameraPosition = CameraPosition.fromInt(cameraPosition),
                cameraPhotoFlash = FlashMode.fromInt(cameraPhotoFlash),
                cameraVideoTorch = TorchMode.fromInt(cameraVideoTorch)
            )
        }

        override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
            channel.setMethodCallHandler(null)
        }
    }


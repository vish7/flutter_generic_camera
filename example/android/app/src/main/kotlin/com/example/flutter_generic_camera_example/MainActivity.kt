package com.example.flutter_generic_camera_example

import android.content.Intent
import android.widget.Toast
import com.example.flutter_generic_camera_example.model.ImageModel
import com.example.flutter_generic_camera_example.utils.costString
import dagger.hilt.android.AndroidEntryPoint
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

@AndroidEntryPoint
class MainActivity: FlutterActivity(){
    private val CHANNEL = costString.CHANNELNAME

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == costString.METHODNAME) {
                val arguments = call.arguments as Map<String, Any>

                val cameramode = arguments[costString.CAMERAMODE] as String
                val flashmode = arguments[costString.FLASHMODE] as Int
                val cameraid = arguments[costString.CAMERAID] as String
                val isMultiCapture = arguments[costString.ISMULTICAPTURE] as Boolean

                val intent = Intent(this, CustomCameraActivity::class.java)
                intent.putExtra(costString.CAMERAMODE,cameramode)
                intent.putExtra(costString.FLASHMODE,flashmode)
                intent.putExtra(costString.CAMERAID,cameraid)
                intent.putExtra(costString.ISMULTICAPTURE,isMultiCapture)
                startActivityForResult(intent, CAMERA_REQUEST_CODE)
                result.success(null)

            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == CAMERA_REQUEST_CODE && resultCode == RESULT_OK) {
            if (data?.hasExtra("image_path") == true) {
                val imagePath = data?.getStringExtra("image_path")
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger,
                    CHANNEL).invokeMethod("onImageCaptured", imagePath)
            }else{
                val imageList: ArrayList<ImageModel>? = data?.getParcelableArrayListExtra("image_list")
                val imageListMap = imageList?.map { image ->
                    mapOf("id" to image.id, "path" to image.path)
                }
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger,
                    CHANNEL).invokeMethod("onImageCapturedList", imageListMap)
            }
        }
    }

    companion object {
        const val CAMERA_REQUEST_CODE = 101
    }
}

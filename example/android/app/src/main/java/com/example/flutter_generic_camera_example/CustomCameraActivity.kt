package com.example.flutter_generic_camera_example

import android.Manifest
import android.content.pm.PackageManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Toast
import androidx.activity.viewModels
import androidx.camera.core.ImageCapture
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.flutter_generic_camera_example.databinding.ActivityCustomCameraBinding
import com.example.flutter_generic_camera_example.utils.costString
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class CustomCameraActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCustomCameraBinding
    var flashmode = ImageCapture.FLASH_MODE_OFF
    var cameramode = costString.CAMERAMODEVALUE
    private var cameraId = costString.CAMERA_BACK
    private val viewModel: CameraViewModel by viewModels()
    private val requestCodePermissions = 10
    private val requiredPermissions = arrayOf(Manifest.permission.CAMERA)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityCustomCameraBinding.inflate(layoutInflater)
        setContentView(binding.root)

        initData()
    }
    fun initData(){
        val intent = intent
        cameraId = intent.getStringExtra(costString.CAMERAID).toString()
        cameramode = intent.getStringExtra(costString.CAMERAMODE).toString()
        flashmode = intent.getIntExtra(costString.FLASHMODE,ImageCapture.FLASH_MODE_OFF)

        if (allPermissionsGranted()) {
            viewModel.initializeCamera(this, cameraId,flashmode, binding.viewFinder)
        } else {
            ActivityCompat.requestPermissions(this, requiredPermissions, requestCodePermissions)
        }
    }
    private fun allPermissionsGranted() = requiredPermissions.all {
        ContextCompat.checkSelfPermission(baseContext, it) == PackageManager.PERMISSION_GRANTED
    }
}
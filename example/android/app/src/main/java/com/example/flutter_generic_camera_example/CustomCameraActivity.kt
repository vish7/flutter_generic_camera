package com.example.flutter_generic_camera_example

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorManager
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.os.Build
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.ImageCapture
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import com.example.flutter_generic_camera_example.adapter.ImageItemAdapter
import com.example.flutter_generic_camera_example.databinding.ActivityCustomCameraBinding
import com.example.flutter_generic_camera_example.model.ImageModel
import com.example.flutter_generic_camera_example.utils.costString
import com.example.flutter_generic_camera_example.utils.costString.AUTO
import com.example.flutter_generic_camera_example.utils.costString.BACK
import com.example.flutter_generic_camera_example.utils.costString.FRONT
import com.example.flutter_generic_camera_example.utils.costString.MUTE
import com.example.flutter_generic_camera_example.utils.costString.OFF
import com.example.flutter_generic_camera_example.utils.costString.ON
import com.example.flutter_generic_camera_example.utils.costString.PHOTO
import com.example.flutter_generic_camera_example.utils.costString.VIDEO
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class CustomCameraActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCustomCameraBinding
    private val REQUEST_RECORD_AUDIO_PERMISSION = 200
    var flashtype: Int? = -1
    var flashmode: String? = null
    var zoomlevel: String? = null
    var microphonemode: String? = null
    var isMultiCapture = false
    var cameramode = costString.CAMERAMODEVALUE
    private var cameraId = costString.CAMERA_BACK
    private val viewModel: CameraViewModel by viewModels()
    private val requestCodePermissions = 10
    private val requiredPermissions = arrayOf(Manifest.permission.CAMERA)
    private val imageList: ArrayList<ImageModel> = ArrayList()
    private val adapter = ImageItemAdapter()
    var zoomRatio = 0.0f
    private lateinit var timer: CountDownTimer
    private var isAudioEnable: Boolean? = true
    private var mSensorManager: SensorManager? = null
    private var mLightSensor: Sensor? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCustomCameraBinding.inflate(layoutInflater)
        setContentView(binding.root)
        initData()
    }

    fun initData() {
        val intent = intent
        cameraId = intent.getStringExtra(costString.CAMERAID).toString()
        cameramode = intent.getStringExtra(costString.CAMERAMODE).toString()
        flashmode = intent.getStringExtra(costString.FLASHMODE).toString()
        zoomlevel = intent.getStringExtra(costString.ZOOMLEVEL).toString()
        isMultiCapture = intent.getBooleanExtra(costString.ISMULTICAPTURE, false)
        microphonemode = intent.getStringExtra(costString.MICROPHONEMODE).toString()

        initLightSensor()
        getSupportedZoomLevels()

        if (flashmode.equals(AUTO)) {
            flashtype = ImageCapture.FLASH_MODE_AUTO
            selectFlashItem(binding.tvAuto)
        } else if (flashmode.equals(ON)) {
            flashtype = ImageCapture.FLASH_MODE_ON
            selectFlashItem(binding.tvOn)
        } else if (flashmode.equals(OFF)) {
            flashtype = ImageCapture.FLASH_MODE_OFF
            selectFlashItem(binding.tvOff)
        }

        if (cameraId == FRONT) {
            cameraId = costString.CAMERA_FRONT
            selectCameraItem(binding.tvFront)
        } else if (cameraId == BACK) {
            cameraId = costString.CAMERA_BACK
            selectCameraItem(binding.tvBack)
        }

        when (zoomlevel) {
            "oneX" -> {
                zoomRatio = 1.0f
                selectZoomItem(binding.tvOneX)
            }
            "zeroPointFiveX" -> {
                zoomRatio = 0.5f
                selectZoomItem(binding.tvZeroPointFiveX)
            }
            "twoX" -> {
                zoomRatio = 2.0f
                selectZoomItem(binding.tvTwoX)
            }
        }

        if (microphonemode == MUTE) {
            isAudioEnable = false
            selectMicrophoneItem(binding.tvMute)
        } else {
            isAudioEnable = true
            selectMicrophoneItem(binding.tvUnmute)
        }

        if (cameramode == VIDEO) {
            binding.tvPhoto.text = resources.getString(R.string.Video)
            binding.rlVideo.visibility = View.VISIBLE
            binding.rlPhotos.visibility = View.GONE
            binding.llDisplayImage.visibility = View.INVISIBLE
            binding.tvDone.visibility = View.INVISIBLE
            binding.textViewTimer.visibility = View.VISIBLE

        } else {
            binding.tvPhoto.text = resources.getString(R.string.Photo)
            binding.rlVideo.visibility = View.GONE
            binding.rlPhotos.visibility = View.VISIBLE
            binding.llDisplayImage.visibility = View.VISIBLE
            binding.tvDone.visibility = View.VISIBLE
            binding.textViewTimer.visibility = View.GONE
            if (isMultiCapture) {
                binding.tvDone.visibility = View.VISIBLE
            } else {
                binding.tvDone.visibility = View.INVISIBLE
            }
        }

        timer = object : CountDownTimer(3600000, 1000) {
            var textval: String? = null
            override fun onTick(millisUntilFinished: Long) {
                val secondsUntilFinished = millisUntilFinished / 1000
                val secondsElapsed = 3000000 - secondsUntilFinished

                val seconds = (((3600000 - millisUntilFinished) / 1000) % 60)
                val minutes = ((3600000 - millisUntilFinished) / (1000 * 60)) % 60
                val hours = (3600000 - millisUntilFinished) / (1000 * 60 * 60)


                binding.textViewTimer.text =
                    String.format("%02d:%02d:%02d", hours, minutes, seconds)
            }

            override fun onFinish() {
                binding.textViewTimer.text = "00:00"
                binding.textViewTimer.setBackgroundColor(resources.getColor(R.color.black))
            }
        }


        if (allPermissionsGranted()) {
            viewModel.initializeCamera(this,
                cameraId,
                flashtype!!,
                zoomRatio,
                binding.viewFinder)
        } else {
            ActivityCompat.requestPermissions(this, requiredPermissions, requestCodePermissions)
        }

        binding.recyclerView.adapter = adapter
        binding.recyclerView.layoutManager =
            LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)

        binding.cameraCaptureButton.setOnClickListener { viewModel.takePhoto(this) }
        binding.tvClose.setOnClickListener { finish() }

        viewModel.photoFile.observe(this) { photoFile ->
            Glide.with(this)
                .load(photoFile.absolutePath)
                .apply(RequestOptions()
                    .placeholder(R.drawable.ic_img_gallery)
                    .error(R.drawable.ic_img_gallery)
                )
                .into(binding.ivImage)
            if (isMultiCapture) {
                imageList.add(ImageModel(imageList.size + 1, photoFile.absolutePath))
                imageList.size
                viewModel.setItems(imageList)
            } else {
                setResult(RESULT_OK, intent.putExtra("image_path", photoFile.absolutePath))
                finish()
            }
        }

        viewModel.videoFile.observe(this) { videoFile ->
            Log.e("video uri", videoFile.path.toString())
            setResult(RESULT_OK, intent.putExtra("image_path", videoFile.path))
            finish()
        }
        binding.tvDone.setOnClickListener {
            setResult(RESULT_OK, intent.putParcelableArrayListExtra("image_list", imageList))
            finish()
        }
        viewModel.imageItems.observe(this) { imageItems ->
            adapter.setItems(imageItems)
        }

        binding.startRecordingButton.setOnClickListener {
            binding.textViewTimer.setBackgroundColor(resources.getColor(R.color.red))
            if (checkPermissions()) {
                binding.llFilter.visibility = View.GONE
                binding.ivFilter.visibility = View.GONE
                viewModel.startRecording(this,
                    isAudioEnable!!,
                    cameramode,
                    flashtype,
                    mSensorManager!!,
                    mLightSensor!!)
                binding.startRecordingButton.visibility = View.GONE
                binding.stopRecordingButton.visibility = View.VISIBLE
                binding.textViewTimer.visibility = View.VISIBLE
                timer.start()
            } else {
                requestPermissions()
            }
        }

        binding.stopRecordingButton.setOnClickListener {
            binding.ivFilter.visibility = View.VISIBLE
            viewModel.stopRecording()
            binding.startRecordingButton.visibility = View.VISIBLE
            binding.stopRecordingButton.visibility = View.GONE
            timer.cancel()
            binding.textViewTimer.text = "00:00"
            binding.textViewTimer.setBackgroundColor(resources.getColor(R.color.black))
        }

        binding.ivFilter.setOnClickListener {
            if (binding.llFilter.isVisible) {
                binding.llFilter.visibility = View.GONE
            } else {
                binding.llFilter.visibility = View.VISIBLE
            }
        }
        binding.tvAuto.setOnClickListener {
            flashtype = ImageCapture.FLASH_MODE_AUTO
            selectFlashItem(binding.tvAuto)
            if (cameramode == PHOTO) {
                viewModel.setFlashMood(flashtype!!)
            }
        }
        binding.tvOn.setOnClickListener {
            flashtype = ImageCapture.FLASH_MODE_ON
            selectFlashItem(binding.tvOn)
            if (cameramode == VIDEO) {
                viewModel.enableTorch(true)
            } else {
                viewModel.setFlashMood(flashtype!!)
            }
        }
        binding.tvOff.setOnClickListener {
            flashtype = ImageCapture.FLASH_MODE_OFF
            selectFlashItem(binding.tvOff)
            if (cameramode == VIDEO) {
                viewModel.enableTorch(false)
            } else {
                viewModel.setFlashMood(flashtype!!)
            }
        }
        binding.tvFront.setOnClickListener {
            cameraId = costString.CAMERA_FRONT
            selectCameraItem(binding.tvFront)
            viewModel.initializeCamera(this,
                cameraId,
                flashtype!!,
                zoomRatio,
                binding.viewFinder)
        }
        binding.tvBack.setOnClickListener {
            cameraId = costString.CAMERA_BACK
            selectCameraItem(binding.tvBack)
            viewModel.initializeCamera(this,
                cameraId,
                flashtype!!,
                zoomRatio,
                binding.viewFinder)
        }
        binding.tvZeroPointFiveX.setOnClickListener {
            zoomRatio = 0.5f
            selectZoomItem(binding.tvZeroPointFiveX)
            viewModel.setZooming(this, zoomRatio, binding.viewFinder)
        }
        binding.tvOneX.setOnClickListener {
            zoomRatio = 1.0f
            selectZoomItem(binding.tvOneX)
            viewModel.setZooming(this, zoomRatio, binding.viewFinder)
        }
        binding.tvTwoX.setOnClickListener {
            zoomRatio = 2.0f
            selectZoomItem(binding.tvTwoX)
            viewModel.setZooming(this, zoomRatio, binding.viewFinder)
        }
        binding.tvMute.setOnClickListener {
            isAudioEnable = false
            selectMicrophoneItem(binding.tvMute)
        }
        binding.tvUnmute.setOnClickListener {
            isAudioEnable = true
            selectMicrophoneItem(binding.tvUnmute)
        }
    }

    private fun initLightSensor() {
        mSensorManager = getSystemService(AppCompatActivity.SENSOR_SERVICE) as SensorManager
        mLightSensor = mSensorManager!!.getDefaultSensor(Sensor.TYPE_LIGHT)
    }

    private fun selectFlashItem(textId: TextView) {
        binding.tvAuto.setBackgroundResource(0)
        binding.tvOn.setBackgroundResource(0)
        binding.tvOff.setBackgroundResource(0)
        textId.setBackgroundResource(R.drawable.ic_selected_item)
    }

    private fun selectCameraItem(textId: TextView) {
        binding.tvFront.setBackgroundResource(0)
        binding.tvBack.setBackgroundResource(0)
        textId.setBackgroundResource(R.drawable.ic_selected_item)
    }

    private fun selectZoomItem(textId: TextView) {
        binding.tvZeroPointFiveX.setBackgroundResource(0)
        binding.tvOneX.setBackgroundResource(0)
        binding.tvTwoX.setBackgroundResource(0)
        textId.setBackgroundResource(R.drawable.ic_selected_item)
    }

    private fun selectMicrophoneItem(textId: TextView) {
        binding.tvMute.setBackgroundResource(0)
        binding.tvUnmute.setBackgroundResource(0)
        textId.setBackgroundResource(R.drawable.ic_selected_item)
    }

    private fun allPermissionsGranted() = requiredPermissions.all {
        ContextCompat.checkSelfPermission(baseContext, it) == PackageManager.PERMISSION_GRANTED
    }

    private fun checkPermissions(): Boolean {
        val permission = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
        return permission == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermissions() {
        ActivityCompat.requestPermissions(this,
            arrayOf(Manifest.permission.RECORD_AUDIO),
            REQUEST_RECORD_AUDIO_PERMISSION)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            REQUEST_RECORD_AUDIO_PERMISSION -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // Permission granted, start recording
                    binding.llFilter.visibility = View.GONE
                    binding.ivFilter.visibility = View.GONE
                    viewModel.startRecording(this, isAudioEnable!!, cameramode, flashtype,
                        mSensorManager!!, mLightSensor!!)

                    binding.startRecordingButton.visibility = View.GONE
                    binding.stopRecordingButton.visibility = View.VISIBLE
                    timer.start()
                } else {
                    // Permission denied, handle accordingly
                    Toast.makeText(this, "Permission denied to record audio", Toast.LENGTH_SHORT)
                        .show()
                }
                return
            }
            requestCodePermissions -> {
                if (allPermissionsGranted()) {
                    viewModel.initializeCamera(this,
                        cameraId,
                        flashtype!!,
                        zoomRatio,
                        binding.viewFinder)
                } else {
                    finish()
                }
            }
        }
    }

    private fun getSupportedZoomLevels() {
        val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager

        try {
            for (cameraId in cameraManager.cameraIdList) {
                val characteristics = cameraManager.getCameraCharacteristics(cameraId)
                val lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING)
                if (lensFacing != null && lensFacing == CameraCharacteristics.LENS_FACING_BACK) {
                    val maxZoom =
                        characteristics.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM)
                    val zoomRatioRange = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        characteristics.get(CameraCharacteristics.CONTROL_ZOOM_RATIO_RANGE)
                    } else {
                        null
                    }

                    // Check for support of 0.6x zoom
                    val supportsSixTenthsZoom = zoomRatioRange?.let { range ->
                        range.lower <= 0.6 && 0.6 <= range.upper
                    } ?: (maxZoom != null && maxZoom >= 0.6)

                    // Display the zoom support information
                    maxZoom?.let { maxZoomLevel ->
                        println("Max Digital Zoom Level: $maxZoomLevel")
                    }

                    zoomRatioRange?.let { range ->
                        println("Zoom Ratio Range: ${range.lower} to ${range.upper}")
                        if (range.lower >= 1.0) {
                            binding.tvZeroPointFiveX.visibility = View.GONE
                        } else {
                            binding.tvZeroPointFiveX.visibility = View.VISIBLE
                        }
                    } ?: run {
                        binding.tvZeroPointFiveX.visibility = View.GONE
                    }

                    if (supportsSixTenthsZoom) {
                        println("Supports 0.6x zoom")
                    } else {
                        println("Does not support 0.6x zoom")
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
package com.example.flutter_generic_camera_example

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.util.Log
import android.view.ScaleGestureDetector
import android.widget.Toast
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.video.*
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.flutter_generic_camera_example.model.ImageModel
import com.example.flutter_generic_camera_example.utils.costString.VIDEO
import com.google.common.util.concurrent.ListenableFuture
import dagger.hilt.android.lifecycle.HiltViewModel
import java.io.File
import javax.inject.Inject


@HiltViewModel
class CameraViewModel @Inject constructor() : ViewModel()/*, SensorEventListener*/ {

    lateinit var videoCapture: VideoCapture<Recorder>
    private val _photoFile = MutableLiveData<File>()
    val photoFile: LiveData<File> get() = _photoFile
    private val _imageItems = MutableLiveData<List<ImageModel>>()
    val imageItems: LiveData<List<ImageModel>> get() = _imageItems
    var currentRecording: Recording? = null
    var isRecording = false
    private val _videoFile = MutableLiveData<Uri>()
    val videoFile: LiveData<Uri> get() = _videoFile
    var flashtype: Int? = -1
    private lateinit var cameraProvider: ProcessCameraProvider
    private lateinit var cameraProviderFuture: ListenableFuture<ProcessCameraProvider>
    private lateinit var preview: Preview
    private lateinit var cameraSelector: CameraSelector
    var camera: androidx.camera.core.Camera? = null
    private lateinit var imageCapture: ImageCapture
    private var mLightQuantity = 0f

    fun initializeCamera(
        context: Context,
        cameraId: String,
        flashmode: Int,
        zoomRatio: Float,
        previewView: PreviewView
    ) {
        cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()
            preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }
            imageCapture = ImageCapture.Builder().build()
            setFlashMood(flashmode)
            val recorder = Recorder.Builder()
                .setQualitySelector(QualitySelector.from(Quality.HIGHEST))
                .build()
            val videoCapture = VideoCapture.withOutput(recorder)

            cameraSelector = if (cameraId == "1") {
                CameraSelector.DEFAULT_FRONT_CAMERA
            } else {
                CameraSelector.DEFAULT_BACK_CAMERA
            }
            try {
                cameraProvider.unbindAll()
                setZooming(context, zoomRatio, previewView)
            } catch (exc: Exception) {
                // Handle exception
            }
            camera = cameraProvider.bindToLifecycle(
                context as CustomCameraActivity,
                cameraSelector,
                preview,
                imageCapture,
                videoCapture
            )
            setFlashMood(flashmode)
            this.imageCapture = imageCapture
            this.videoCapture = videoCapture
        }, ContextCompat.getMainExecutor(context))
    }

    fun setFlashMood(flashmode: Int) {
        imageCapture.flashMode = flashmode
    }

    fun enableTorch(enable: Boolean) {
        camera!!.cameraControl.enableTorch(enable)
    }

    fun setZooming(context: Context, zoomRatio: Float, previewView: PreviewView) {
        val cameraControl = camera!!.cameraControl
        val cameraInfo = camera!!.cameraInfo
        val zoomState = cameraInfo.zoomState.value
        println("Min Zoom: ${zoomState!!.minZoomRatio}, Max Zoom: ${zoomState.maxZoomRatio}")

        cameraControl.setZoomRatio(zoomRatio).addListener({
            // Zoom changed successfully
        }, ContextCompat.getMainExecutor(context))
        if (zoomRatio.equals(0.5f)) {
            cameraControl.setLinearZoom(0.25f)
        }
        // Listen to pinch gestures
        val listener = object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
            override fun onScale(detector: ScaleGestureDetector): Boolean {
                val currentZoomRatio = cameraInfo.zoomState.value?.zoomRatio ?: 0F
                val delta = detector.scaleFactor
                cameraControl.setZoomRatio(currentZoomRatio * delta)
                return true
            }
        }
        val scaleGestureDetector = ScaleGestureDetector(context, listener)
        previewView.setOnTouchListener { _, event ->
            scaleGestureDetector.onTouchEvent(event)
            return@setOnTouchListener true
        }
    }

    fun takePhoto(context: Context) {
        val imageCapture = imageCapture

        val photoFile =
            File(context.externalMediaDirs.firstOrNull(), "${System.currentTimeMillis()}.jpg")
        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()

        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(context),
            object : ImageCapture.OnImageSavedCallback {
                override fun onError(exc: ImageCaptureException) {
                    // Handle error
                }

                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    _photoFile.postValue(photoFile)
                }
            }
        )
    }

    fun setItems(items: List<ImageModel>) {
        _imageItems.value = items
    }

    private fun getLightLevelEvent(
        mSensorManager: SensorManager,
        mLightSensor: Sensor,
    ) {
        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                if (mLightQuantity != 0f) {
                    return
                }
                mLightQuantity = event.values[0]
                if (mLightQuantity < 70) {
                    enableTorch(true)
                } else {
                    enableTorch(false)
                }
                Log.d("SENSOREVENT", mLightQuantity.toString())
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
                // Handle accuracy changes if needed
            }
        }
        mSensorManager.registerListener(
            listener, mLightSensor, SensorManager.SENSOR_DELAY_UI
        )
    }


    fun startRecording(
        context: Context,
        isAudioEnable: Boolean,
        cameramode: String?,
        flashmode: Int?,
        mSensorManager: SensorManager,
        mLightSensor: Sensor,
    ) {
        val videoFile =
            File(context.externalMediaDirs.firstOrNull(), "${System.currentTimeMillis()}.mp4")
        val outputOptions = FileOutputOptions.Builder(videoFile).build()

        if (cameramode == VIDEO) {
            if (flashmode == ImageCapture.FLASH_MODE_AUTO) {
                getLightLevelEvent(mSensorManager, mLightSensor)
            }
        }
        if (isAudioEnable) {
            currentRecording = videoCapture.output
                .prepareRecording(context, outputOptions)
                .withAudioEnabled()
                .start(ContextCompat.getMainExecutor(context)) { recordEvent ->
                    when (recordEvent) {
                        is VideoRecordEvent.Start -> {
                            isRecording = true
                            Log.d("viewmodel", "Video recording started")
                        }
                        is VideoRecordEvent.Finalize -> {
                            isRecording = false
                            Log.d("viewmodel", "Video recording finalized")
                            if (!recordEvent.hasError()) {
                                val savedUri = recordEvent.outputResults.outputUri
                                _videoFile.postValue(savedUri)
                                Log.d("viewmodel", "Video capture succeeded: $savedUri")
                            } else {
                                Log.e("viewmodel", "Recording failed: ${recordEvent.error}")
                                Toast.makeText(context,
                                    "Recording failed: ${recordEvent.error}",
                                    Toast.LENGTH_SHORT).show()
                                //   handleEncoderError()
                            }
                        }
                        is VideoRecordEvent.Pause -> {

                            Log.d("viewmodel", "Video recording paused")
                        }
                        is VideoRecordEvent.Resume -> {
                            Log.d("viewmodel", "Video recording resumed")
                        }
                        is VideoRecordEvent.Status -> {
                            Log.d("viewmodel",
                                "Video recording status: ${recordEvent.recordingStats}")
                        }
                        else -> {
                            Log.w("viewmodel", "Unknown video record event")
                        }
                    }
                }
        } else {
            currentRecording = videoCapture.output
                .prepareRecording(context, outputOptions)
                .start(ContextCompat.getMainExecutor(context)) { recordEvent ->
                    when (recordEvent) {
                        is VideoRecordEvent.Start -> {
                            isRecording = true
                            Log.d("viewmodel", "Video recording started")
                        }
                        is VideoRecordEvent.Finalize -> {
                            isRecording = false
                            Log.d("viewmodel", "Video recording finalized")
                            if (!recordEvent.hasError()) {
                                val savedUri = recordEvent.outputResults.outputUri
                                _videoFile.postValue(savedUri)
                                Log.d("viewmodel", "Video capture succeeded: $savedUri")
                            } else {
                                Log.e("viewmodel", "Recording failed: ${recordEvent.error}")
                                Toast.makeText(context,
                                    "Recording failed: ${recordEvent.error}",
                                    Toast.LENGTH_SHORT).show()
                                //   handleEncoderError()
                            }
                        }
                        is VideoRecordEvent.Pause -> {

                            Log.d("viewmodel", "Video recording paused")
                        }
                        is VideoRecordEvent.Resume -> {
                            Log.d("viewmodel", "Video recording resumed")
                        }
                        is VideoRecordEvent.Status -> {
                            Log.d("viewmodel",
                                "Video recording status: ${recordEvent.recordingStats}")
                        }
                        else -> {
                            Log.w("viewmodel", "Unknown video record event")
                        }
                    }
                }
        }

    }

    fun stopRecording() {
        if (isRecording) {
            currentRecording?.stop()
            //  isRecording = false
        }
    }
}



package com.example.flutter_generic_camera_example

import android.content.Context
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.video.Quality
import androidx.camera.video.QualitySelector
import androidx.camera.video.Recorder
import androidx.camera.video.VideoCapture
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class CameraViewModel @Inject constructor() : ViewModel() {

    private var imageCapture: ImageCapture? = null
    lateinit var videoCapture: VideoCapture<Recorder>

    fun initializeCamera(context: Context, cameraId: String, flashmode:Int, previewView: PreviewView) {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)

        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()

            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }
            val imageCapture = ImageCapture.Builder().build()

            val recorder = Recorder.Builder()
                .setQualitySelector(QualitySelector.from(Quality.HIGHEST))
                .build()
            val videoCapture = VideoCapture.withOutput(recorder)

            val cameraSelector = if (cameraId == "1") {
                CameraSelector.DEFAULT_FRONT_CAMERA
            } else {
                CameraSelector.DEFAULT_BACK_CAMERA
            }

            try {
                cameraProvider.unbindAll()
                val camera = cameraProvider.bindToLifecycle(
                    context as CustomCameraActivity,
                    cameraSelector,
                    preview,
                    imageCapture,
                    videoCapture
                )
            } catch (exc: Exception) {
                // Handle exception
            }

            this.imageCapture = imageCapture
            this.videoCapture = videoCapture
        }, ContextCompat.getMainExecutor(context))
    }
}
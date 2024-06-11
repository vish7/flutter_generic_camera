package com.example.flutter_generic_camera_example

import android.content.Context
import android.net.Uri
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
import dagger.hilt.android.lifecycle.HiltViewModel
import java.io.File
import javax.inject.Inject

@HiltViewModel
class CameraViewModel @Inject constructor() : ViewModel() {

    private var imageCapture: ImageCapture? = null
    lateinit var videoCapture: VideoCapture<Recorder>

    private val _photoFile = MutableLiveData<File>()
    val photoFile: LiveData<File> get() = _photoFile

    private val _imageItems = MutableLiveData<List<ImageModel>>()
    val imageItems: LiveData<List<ImageModel>> get() = _imageItems

    lateinit var currentRecording: Recording
    var isRecording = false

    private val _videoFile = MutableLiveData<Uri>()
    val videoFile: LiveData<Uri> get() = _videoFile

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

    fun takePhoto(context: Context) {
        val imageCapture = imageCapture ?: return

        val photoFile = File(context.externalMediaDirs.firstOrNull(), "${System.currentTimeMillis()}.jpg")
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

    fun startRecording(context: Context) {
        val videoCapture = videoCapture ?: return

        val videoFile = File(context.externalMediaDirs.firstOrNull(), "${System.currentTimeMillis()}.mp4")
        val outputOptions = FileOutputOptions.Builder(videoFile).build()

        currentRecording = videoCapture.output
            .prepareRecording(context, outputOptions)
            .withAudioEnabled()
            .start(ContextCompat.getMainExecutor(context)) { recordEvent ->
                when (recordEvent) {
                    is VideoRecordEvent.Start -> {
                        isRecording = true
                        // Handle UI updates for recording start
                    }
                    is VideoRecordEvent.Finalize -> {
                        isRecording = false
                        // Handle UI updates for recording stop
                        if (!recordEvent.hasError()) {
                            val savedUri = recordEvent.outputResults.outputUri
                            _videoFile.postValue(savedUri)
                            // Video capture succeeded
                        } else {
                            // Video capture failed
                        }
                    }
                }
            }
        // Show countdown timer

    }

    fun stopRecording() {
        if (isRecording) {
            currentRecording.stop()
            // currentRecording = null
        }
    }

}
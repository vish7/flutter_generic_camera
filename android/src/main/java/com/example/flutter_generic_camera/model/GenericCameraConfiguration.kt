package com.example.flutter_generic_camera.model

import com.example.flutter_generic_camera.enum.AssetType
import com.example.flutter_generic_camera.enum.CameraPosition
import com.example.flutter_generic_camera.enum.FlashMode
import com.example.flutter_generic_camera.enum.TorchMode

data class GenericCameraConfiguration(
    var captureMode: AssetType /*= AssetType.PHOTO*/,
    var canCaptureMultiplePhotos: Boolean /*= false*/,
    var cameraPosition: Int /*= CameraPosition.BACK*/,
    var cameraPhotoFlash: Int /*= FlashMode.AUTO*/,
    var cameraVideoTorch: Int /*= TorchMode.AUTO*/
) : java.io.Serializable {
    fun toJson(): Map<String, Any> {
        return mapOf(
            "captureMode" to captureMode.ordinal,
            "canCaptureMultiplePhotos" to canCaptureMultiplePhotos,
            "cameraPosition" to cameraPosition,
            "cameraPhotoFlash" to cameraPhotoFlash,
            "cameraVideoTorch" to cameraVideoTorch
        )
    }
}

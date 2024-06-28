package com.example.flutter_generic_camera.enum

object CameraPosition {
    const val BACK = 1
    const val FRONT = 2

    fun fromInt(value: Int?): Int {
        return when (value) {
            FRONT -> FRONT
            else -> BACK
        }
    }
}

object FlashMode {
    const val OFF = 0
    const val ON = 1
    const val AUTO = 2

    fun fromInt(value: Int?): Int {
        return when (value) {
            ON -> ON
            OFF -> OFF
            else -> AUTO
        }
    }
}

object TorchMode {
    const val OFF = 0
    const val ON = 1
    const val AUTO = 2

    fun fromInt(value: Int?): Int {
        return when (value) {
            ON -> ON
            OFF -> OFF
            else -> AUTO
        }
    }
}
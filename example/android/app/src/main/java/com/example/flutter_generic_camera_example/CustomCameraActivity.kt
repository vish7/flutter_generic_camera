package com.example.flutter_generic_camera_example

import android.Manifest
import android.content.pm.PackageManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.CountDownTimer
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.activity.viewModels
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
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class CustomCameraActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCustomCameraBinding
    private val REQUEST_RECORD_AUDIO_PERMISSION = 200
  //  var flashmode = ImageCapture.FLASH_MODE_OFF
    var flashtype : Int? = -1
    var flashmode : String? = null
    var zoomlevel : String? = null
    var isMultiCapture = false
    var cameramode = costString.CAMERAMODEVALUE
    private var cameraId = costString.CAMERA_BACK
    private val viewModel: CameraViewModel by viewModels()
    private val requestCodePermissions = 10
    private val requiredPermissions = arrayOf(Manifest.permission.CAMERA)
    private val imageList: ArrayList<ImageModel> = ArrayList()
    private val adapter = ImageItemAdapter()

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
        flashmode = intent.getStringExtra(costString.FLASHMODE).toString()
        zoomlevel = intent.getStringExtra(costString.ZOOMLEVEL).toString()
        isMultiCapture = intent.getBooleanExtra(costString.ISMULTICAPTURE,false)


        if(flashmode.equals("auto")){
            flashtype = ImageCapture.FLASH_MODE_AUTO
            selectFlashItem(binding.tvAuto)
        }else if(flashmode.equals("on")){
            flashtype = ImageCapture.FLASH_MODE_ON
            selectFlashItem(binding.tvOn)
        }else if(flashmode.equals("off")){
            flashtype = ImageCapture.FLASH_MODE_OFF
            selectFlashItem(binding.tvOff)
        }


        val timer = object: CountDownTimer(3600000, 1000) {
            var textval : String? = null
            override fun onTick(millisUntilFinished: Long) {
                val secondsUntilFinished = millisUntilFinished / 1000
                val secondsElapsed = 3000000- secondsUntilFinished

                val seconds = (((3600000 - millisUntilFinished) / 1000) % 60)
                val minutes = ((3600000 - millisUntilFinished) / (1000 * 60)) % 60
                val hours = (3600000 - millisUntilFinished) / (1000 * 60 * 60)


                binding.textViewTimer.text = String.format("%02d:%02d:%02d", hours, minutes, seconds)
            }

            override fun onFinish() {
                binding.textViewTimer.text = "00:00"
                binding.textViewTimer.setBackgroundColor(resources.getColor(R.color.black))
            }
        }

        if(cameramode == "video"){
            binding.tvPhoto.text = "Video"
            binding.rlVideo.visibility = View.VISIBLE
            binding.rlPhotos.visibility = View.GONE
            binding.llDisplayImage.visibility = View.INVISIBLE
            binding.tvDone.visibility = View.INVISIBLE
            binding.textViewTimer.visibility = View.VISIBLE

        }else{
            binding.tvPhoto.text = "Photo"
            binding.rlVideo.visibility = View.GONE
            binding.rlPhotos.visibility = View.VISIBLE
            binding.llDisplayImage.visibility = View.VISIBLE
            binding.tvDone.visibility = View.VISIBLE
            binding.textViewTimer.visibility = View.GONE
            if (isMultiCapture){
                binding.tvDone.visibility = View.VISIBLE
            }else{
                binding.tvDone.visibility = View.INVISIBLE
            }
        }



        if (allPermissionsGranted()) {
            viewModel.initializeCamera(this, cameraId,flashtype!!, binding.viewFinder)
        } else {
            ActivityCompat.requestPermissions(this, requiredPermissions, requestCodePermissions)
        }

        binding.recyclerView.adapter = adapter
        binding.recyclerView.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)


        binding.cameraCaptureButton.setOnClickListener { viewModel.takePhoto(this) }

        viewModel.photoFile.observe(this) { photoFile ->
            Glide.with(this)
                .load(photoFile.absolutePath)
                .apply(RequestOptions()
                    .placeholder(R.drawable.ic_img_gallery)
                    .error(R.drawable.ic_img_gallery)
                )
                .into(binding.ivImage)
            if (isMultiCapture) {
                imageList.add(ImageModel(imageList.size + 1 ,photoFile.absolutePath))
                Toast.makeText(this,imageList.size.toString(),Toast.LENGTH_SHORT).show()
                imageList.size
                viewModel.setItems(imageList)
            }else{
                setResult(RESULT_OK, intent.putExtra("image_path", photoFile.absolutePath))
                finish()
            }
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
                viewModel.startRecording(this)
                binding.startRecordingButton.visibility = View.GONE
                binding.stopRecordingButton.visibility = View.VISIBLE
                binding.textViewTimer.visibility = View.VISIBLE

                timer.start()


            } else {
                requestPermissions()
            }

        }

        binding.stopRecordingButton.setOnClickListener {
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
            }else{
                binding.llFilter.visibility = View.VISIBLE
            }
        }
        binding.tvAuto.setOnClickListener {
            flashtype = ImageCapture.FLASH_MODE_AUTO
            selectFlashItem(binding.tvAuto)
            viewModel.initializeCamera(this, cameraId,flashtype!!, binding.viewFinder)
        }
        binding.tvOn.setOnClickListener {
            flashtype = ImageCapture.FLASH_MODE_ON
            selectFlashItem(binding.tvOn)
            viewModel.initializeCamera(this, cameraId,flashtype!!, binding.viewFinder)
        }
        binding.tvOff.setOnClickListener {
            flashtype = ImageCapture.FLASH_MODE_OFF
            selectFlashItem(binding.tvOff)
            viewModel.initializeCamera(this, cameraId,flashtype!!, binding.viewFinder)
        }
        binding.tvFront.setOnClickListener {
            selectCameraItem(binding.tvFront)
        }
        binding.tvBack.setOnClickListener {
            selectCameraItem(binding.tvBack)
        }
        binding.tvZeroPointFiveX.setOnClickListener {
            selectZoomItem(binding.tvZeroPointFiveX)
        }
        binding.tvOneX.setOnClickListener {
            selectZoomItem(binding.tvOneX)
        }
        binding.tvTwoX.setOnClickListener {
            selectZoomItem(binding.tvTwoX)
        }
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
                    viewModel.startRecording(this)

                    binding.startRecordingButton.visibility = View.GONE
                    binding.stopRecordingButton.visibility = View.VISIBLE
                } else {
                    // Permission denied, handle accordingly
                    Toast.makeText(this, "Permission denied to record audio", Toast.LENGTH_SHORT)
                        .show()
                }
                return
            }
            requestCodePermissions -> {
                if (allPermissionsGranted()) {
                    viewModel.initializeCamera(this, cameraId,flashtype!!, binding.viewFinder)
                } else {
                    finish()
                }
            }
        }
    }
}
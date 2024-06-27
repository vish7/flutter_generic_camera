package com.example.flutter_generic_camera.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.flutter_generic_camera.databinding.ItemImageListBinding
import com.example.flutter_generic_camera.model.ImageModel

class ImageItemAdapter : RecyclerView.Adapter<ImageItemAdapter.ItemViewHolder>() {

//    private var items: List<ImageModel> = emptyList()
    private var items: List<String> = listOf()

    class ItemViewHolder(val binding: ItemImageListBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        val binding = ItemImageListBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ItemViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
//        holder.binding.(items[position])
        holder.binding.item = items[position]
        holder.binding.executePendingBindings()
    }

    override fun getItemCount(): Int {
        return items.size
    }

    fun setItems(items: List<String>) {
        this.items = items
        notifyDataSetChanged()
    }
}
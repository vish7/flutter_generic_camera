package com.example.flutter_generic_camera_example.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.flutter_generic_camera_example.databinding.ItemImageListBinding
import com.example.flutter_generic_camera_example.model.ImageModel

class ImageItemAdapter : RecyclerView.Adapter<ImageItemAdapter.ItemViewHolder>() {

    private var items: List<ImageModel> = emptyList()

    class ItemViewHolder(val binding: ItemImageListBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val binding = ItemImageListBinding.inflate(layoutInflater, parent, false)
        return ItemViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
        holder.binding.item = items[position]
        holder.binding.executePendingBindings()
    }

    override fun getItemCount(): Int {
        return items.size
    }

    fun setItems(items: List<ImageModel>) {
        this.items = items
        notifyDataSetChanged()
    }
}
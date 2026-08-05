package com.demo.lebyy.ui

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.demo.lebyy.databinding.ActivitySwipesHubBinding
import com.demo.lebyy.databinding.ItemComponentBinding

class SwipesHubActivity : AppCompatActivity() {
    private lateinit var binding: ActivitySwipesHubBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySwipesHubBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "swipes")

        data class Topic(
            val title: String,
            val subtitle: String,
            val id: String,
            val target: Class<out Activity>,
        )

        val topics = listOf(
            Topic(
                "Horizontal Carousel",
                "Swipe cards left & right",
                "test-SwipeNav-Horizontal",
                SwipeHorizontalActivity::class.java,
            ),
            Topic(
                "Vertical List",
                "Scroll a long list",
                "test-SwipeNav-Vertical",
                SwipeVerticalActivity::class.java,
            ),
        )

        binding.swipeTopicsList.layoutManager = LinearLayoutManager(this)
        binding.swipeTopicsList.adapter = object : RecyclerView.Adapter<TopicVH>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TopicVH {
                val b = ItemComponentBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                return TopicVH(b)
            }

            override fun onBindViewHolder(holder: TopicVH, position: Int) {
                val t = topics[position]
                holder.binding.componentTitle.text = t.title
                holder.binding.componentSubtitle.text = t.subtitle
                holder.binding.root.contentDescription = t.id
                holder.binding.root.setOnClickListener {
                    startActivity(Intent(this@SwipesHubActivity, t.target))
                }
            }

            override fun getItemCount(): Int = topics.size
        }
    }

    private class TopicVH(val binding: ItemComponentBinding) : RecyclerView.ViewHolder(binding.root)
}

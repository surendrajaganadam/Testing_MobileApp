package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.demo.lebyy.databinding.ActivityFormControlsHubBinding
import com.demo.lebyy.databinding.ItemComponentBinding

class FormControlsHubActivity : AppCompatActivity() {
    private lateinit var binding: ActivityFormControlsHubBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityFormControlsHubBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "forms")

        data class Topic(val title: String, val subtitle: String, val id: String, val extra: String)

        val topics = listOf(
            Topic("Text Fields", "Plain, secure, email, multiline", "test-FormTopic-textFields", "text"),
            Topic("Switches", "Default, labeled, checkbox-style", "test-FormTopic-switches", "switches"),
            Topic("Sliders", "Continuous & stepped values", "test-FormTopic-sliders", "sliders"),
            Topic("Date & Time", "Date picker & time picker", "test-FormTopic-pickers", "pickers"),
            Topic("Selection Controls", "Dropdown, checkboxes, radios", "test-FormTopic-selection", "selection"),
            Topic("Validation", "Inline errors on submit", "test-FormTopic-validation", "validation"),
            Topic("OTP / PIN", "4-digit PIN entry", "test-FormTopic-otp", "otp"),
        )

        binding.formTopicsList.layoutManager = LinearLayoutManager(this)
        binding.formTopicsList.adapter = object : RecyclerView.Adapter<TopicVH>() {
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
                    startActivity(
                        Intent(this@FormControlsHubActivity, FormsActivity::class.java)
                            .putExtra(FormsActivity.EXTRA_TOPIC, t.extra),
                    )
                }
            }

            override fun getItemCount(): Int = topics.size
        }
    }

    private class TopicVH(val binding: ItemComponentBinding) : RecyclerView.ViewHolder(binding.root)
}

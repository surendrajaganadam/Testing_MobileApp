package com.lebyy.app.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import com.lebyy.app.R
import com.lebyy.app.databinding.ActivitySwipeHorizontalBinding
import com.lebyy.app.databinding.ItemSwipeCardBinding

class SwipeHorizontalActivity : AppCompatActivity() {
    private lateinit var binding: ActivitySwipeHorizontalBinding

    private data class CourseCard(
        val title: String,
        val body: String,
        val imageRes: Int,
    )

    private val cards = listOf(
        CourseCard("Playwright", "Swipe left for more Lebyy courses", R.drawable.course_swipe_1),
        CourseCard("Appium", "Mobile automation carousel card", R.drawable.course_swipe_2),
        CourseCard("API Testing", "Practice horizontal swipe here", R.drawable.course_swipe_3),
        CourseCard("Selenium", "Like WebdriverIO swipe demo", R.drawable.course_swipe_4),
        CourseCard("CI/CD for QA", "Keep swiping left / right", R.drawable.course_swipe_5),
        CourseCard("Mobilewright", "Last card — swipe right to go back", R.drawable.course_swipe_6),
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySwipeHorizontalBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "swipe_h")

        binding.swipePager.adapter = object : RecyclerView.Adapter<CardVH>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CardVH {
                val item = ItemSwipeCardBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                return CardVH(item)
            }

            override fun onBindViewHolder(holder: CardVH, position: Int) {
                val card = cards[position]
                holder.binding.cardImage.setImageResource(card.imageRes)
                holder.binding.cardImage.contentDescription = "course"
                holder.binding.cardTitle.text = card.title
                holder.binding.cardBody.text = card.body
                // Universal label for every card — use getByLabel('course') (+ .first / swipe).
                holder.binding.root.contentDescription = "course"
            }

            override fun getItemCount(): Int = cards.size
        }

        binding.swipePager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                binding.swipeHStatus.text = "Card ${position + 1} / ${cards.size}"
            }
        })
    }

    private class CardVH(val binding: ItemSwipeCardBinding) : RecyclerView.ViewHolder(binding.root)
}

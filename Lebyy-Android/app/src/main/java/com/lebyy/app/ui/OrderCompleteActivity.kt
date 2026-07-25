package com.lebyy.app.ui

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.lebyy.app.databinding.ActivityOrderCompleteBinding

class OrderCompleteActivity : AppCompatActivity() {
    private lateinit var binding: ActivityOrderCompleteBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityOrderCompleteBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.buttonBackHome.setOnClickListener {
            startActivity(Intent(this, CatalogActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            })
            finish()
        }
    }
}

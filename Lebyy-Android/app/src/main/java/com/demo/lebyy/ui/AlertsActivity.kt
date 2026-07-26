package com.demo.lebyy.ui

import android.os.Bundle
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.databinding.ActivityAlertsBinding
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class AlertsActivity : AppCompatActivity() {
    private lateinit var binding: ActivityAlertsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAlertsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "alerts")

        binding.buttonSimpleAlert.setOnClickListener {
            MaterialAlertDialogBuilder(this)
                .setTitle("Alert")
                .setMessage("This is a simple Lebyy alert")
                .setPositiveButton("OK") { _, _ ->
                    binding.alertResult.text = "Result: Alert OK"
                }
                .show()
        }

        binding.buttonConfirmAlert.setOnClickListener {
            MaterialAlertDialogBuilder(this)
                .setTitle("Confirm")
                .setMessage("Do you want to continue?")
                .setPositiveButton("OK") { _, _ ->
                    binding.alertResult.text = "Result: Confirm OK"
                }
                .setNegativeButton("CANCEL") { _, _ ->
                    binding.alertResult.text = "Result: Confirm CANCEL"
                }
                .show()
        }

        binding.buttonPromptAlert.setOnClickListener {
            val input = EditText(this).apply {
                hint = "Enter text"
                contentDescription = "test-PromptInput"
                setTextColor(0xFF0F2144.toInt())
                setHintTextColor(0xFF6B7F99.toInt())
                setPadding(48, 32, 48, 32)
            }
            MaterialAlertDialogBuilder(this)
                .setTitle("Prompt")
                .setMessage("Please type something")
                .setView(input)
                .setPositiveButton("OK") { _, _ ->
                    binding.alertResult.text = "Result: Prompt ${input.text}"
                }
                .setNegativeButton("CANCEL") { _, _ ->
                    binding.alertResult.text = "Result: Prompt CANCEL"
                }
                .show()
        }
    }
}

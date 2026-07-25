package com.lebyy.app.ui

import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.lebyy.app.R
import com.lebyy.app.databinding.ActivityFormsBinding

class FormsActivity : AppCompatActivity() {
    private lateinit var binding: ActivityFormsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityFormsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "forms")

        val options = listOf(
            "Select an item...",
            "This app is awesome",
            "webdriver.io is awesome",
            "Appium is awesome",
            "Lebyy is awesome",
        )
        val adapter = ArrayAdapter(this, R.layout.item_dropdown, options)
        adapter.setDropDownViewResource(R.layout.item_dropdown)
        binding.dropdown.setAdapter(adapter)
        binding.dropdown.setText(options[0], false)
        binding.dropdown.setDropDownBackgroundResource(R.color.lebyy_surface_2)
        binding.dropdown.threshold = 1
        binding.dropdown.setOnClickListener { binding.dropdown.showDropDown() }
        binding.dropdown.setOnFocusChangeListener { _, hasFocus ->
            if (hasFocus) binding.dropdown.showDropDown()
        }
        binding.dropdown.setOnItemClickListener { _, _, position, _ ->
            binding.formsResult.text = "Result: Dropdown ${options[position]}"
        }

        fun renderSwitchStatus(isChecked: Boolean) {
            val label = if (isChecked) "ON" else "OFF"
            binding.switchStatus.text = "Switch status: $label"
            binding.switchStatus.contentDescription = "test-SwitchStatus-$label"
            binding.formsResult.text = "Result: Switch $label"
        }
        renderSwitchStatus(binding.switchNotifications.isChecked)
        binding.switchNotifications.setOnCheckedChangeListener { _, isChecked ->
            renderSwitchStatus(isChecked)
        }

        binding.checkboxOne.setOnCheckedChangeListener { _, _ -> updateChecks() }
        binding.checkboxTwo.setOnCheckedChangeListener { _, _ -> updateChecks() }

        binding.radioGroup.setOnCheckedChangeListener { _, checkedId ->
            val label = when (checkedId) {
                binding.radioOne.id -> "Radio 1"
                binding.radioTwo.id -> "Radio 2"
                else -> "—"
            }
            binding.formsResult.text = "Result: $label"
        }

        binding.buttonActive.setOnClickListener {
            val typed = binding.inputText.text?.toString().orEmpty()
            binding.formsResult.text = "Result: Active tapped ($typed)"
            Toast.makeText(this, "Active button clicked", Toast.LENGTH_SHORT).show()
        }

        // Visually muted but still tappable so automation / demo can verify the control
        binding.buttonInactive.isEnabled = true
        binding.buttonInactive.alpha = 0.45f
        binding.buttonInactive.setOnClickListener {
            binding.formsResult.text = "Result: Inactive tapped"
            Toast.makeText(this, "Inactive button", Toast.LENGTH_SHORT).show()
        }
    }

    private fun updateChecks() {
        val selected = buildList {
            if (binding.checkboxOne.isChecked) add("A")
            if (binding.checkboxTwo.isChecked) add("B")
        }.joinToString(",").ifEmpty { "none" }
        binding.formsResult.text = "Result: Checkbox $selected"
    }
}

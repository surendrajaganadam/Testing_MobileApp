package com.demo.lebyy.ui

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.ArrayAdapter
import android.widget.EditText
import android.widget.SeekBar
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.R
import com.demo.lebyy.databinding.ActivityFormsBinding
import java.util.Calendar
import java.util.Locale

class FormsActivity : AppCompatActivity() {
    companion object {
        const val EXTRA_TOPIC = "form_topic"
    }

    private lateinit var binding: ActivityFormsBinding
    private val calendar = Calendar.getInstance()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityFormsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "forms")

        val topic = intent.getStringExtra(EXTRA_TOPIC).orEmpty()
        if (topic.isNotEmpty()) {
            binding.toolbar.title = when (topic) {
                "switches" -> "Switches"
                "sliders" -> "Sliders"
                "pickers" -> "Date & Time"
                "selection" -> "Selection Controls"
                "validation" -> "Validation"
                "otp" -> "OTP / PIN"
                "text" -> "Text Fields"
                else -> "Forms"
            }
        }

        val options = listOf(
            "Select an item...",
            "surendra is awesome",
            "lebyy is awesome",
            "i love your content",
            "i refer this course to my friends",
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

        binding.buttonInactive.isEnabled = true
        binding.buttonInactive.alpha = 0.45f
        binding.buttonInactive.setOnClickListener {
            binding.formsResult.text = "Result: Inactive tapped"
            Toast.makeText(this, "Inactive button", Toast.LENGTH_SHORT).show()
        }

        binding.buttonPickDate.setOnClickListener {
            DatePickerDialog(
                this,
                { _, y, m, d ->
                    val text = String.format(Locale.US, "%04d-%02d-%02d", y, m + 1, d)
                    binding.dateValue.text = "Selected date: $text"
                    binding.dateValue.contentDescription = "Selected date: $text"
                    binding.formsResult.text = "Result: Date $text"
                },
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH),
            ).show()
        }

        binding.buttonPickTime.setOnClickListener {
            TimePickerDialog(
                this,
                { _, hour, minute ->
                    val text = String.format(Locale.US, "%02d:%02d", hour, minute)
                    binding.timeValue.text = "Selected time: $text"
                    binding.timeValue.contentDescription = "Selected time: $text"
                    binding.formsResult.text = "Result: Time $text"
                },
                calendar.get(Calendar.HOUR_OF_DAY),
                calendar.get(Calendar.MINUTE),
                true,
            ).show()
        }

        binding.slider.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                binding.sliderValue.text = "Slider value: $progress"
                binding.sliderValue.contentDescription = "Slider value: $progress"
                binding.slider.contentDescription = "test-Slider"
                binding.formsResult.text = "Result: Slider $progress"
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        binding.validationSubmit.setOnClickListener {
            val name = binding.validationName.text?.toString()?.trim().orEmpty()
            val email = binding.validationEmail.text?.toString()?.trim().orEmpty()
            val errors = mutableListOf<String>()
            if (name.isEmpty()) errors += "Name is required"
            if (!email.contains("@") || !email.contains(".")) errors += "Email is invalid"
            binding.validationError1.visibility = View.GONE
            binding.validationError2.visibility = View.GONE
            binding.validationSuccess.visibility = View.GONE
            if (errors.isEmpty()) {
                binding.validationSuccess.visibility = View.VISIBLE
                binding.formsResult.text = "Result: Validation OK"
            } else {
                binding.formsResult.text = "Result: Validation failed"
                errors.getOrNull(0)?.let {
                    binding.validationError1.text = it
                    binding.validationError1.visibility = View.VISIBLE
                }
                errors.getOrNull(1)?.let {
                    binding.validationError2.text = it
                    binding.validationError2.visibility = View.VISIBLE
                }
            }
        }

        val otps = listOf(binding.otp1, binding.otp2, binding.otp3, binding.otp4)
        otps.forEachIndexed { index, field ->
            field.addTextChangedListener(simpleWatcher {
                updateOtpValue(otps)
                if (field.text?.length == 1 && index < otps.lastIndex) {
                    otps[index + 1].requestFocus()
                }
            })
        }
        binding.otpVerify.setOnClickListener {
            val code = otps.joinToString("") { it.text?.toString().orEmpty() }
            binding.formsResult.text = when {
                code.length < 4 -> "Result: OTP incomplete"
                code == "1234" -> "Result: OTP success"
                else -> "Result: OTP wrong"
            }
        }
    }

    private fun updateOtpValue(otps: List<EditText>) {
        val code = otps.joinToString("") { it.text?.toString().orEmpty() }
        binding.otpValue.text = "OTP value: $code"
        binding.otpValue.contentDescription = "OTP value: $code"
        binding.formsResult.text = "Result: OTP $code"
    }

    private fun simpleWatcher(onChange: () -> Unit) = object : TextWatcher {
        override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
        override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
        override fun afterTextChanged(s: Editable?) { onChange() }
    }

    private fun updateChecks() {
        val selected = buildList {
            if (binding.checkboxOne.isChecked) add("A")
            if (binding.checkboxTwo.isChecked) add("B")
        }.joinToString(",").ifEmpty { "none" }
        binding.formsResult.text = "Result: Checkbox $selected"
    }
}

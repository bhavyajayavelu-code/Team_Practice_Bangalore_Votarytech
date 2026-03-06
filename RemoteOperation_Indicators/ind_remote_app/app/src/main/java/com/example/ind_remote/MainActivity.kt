/*package com.example.ind_remote

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.ind_remote.databinding.ActivityMainBinding
import com.google.firebase.database.FirebaseDatabase

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val dbRef = FirebaseDatabase.getInstance(
        "https://remote-operation-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).getReference("ind_remote")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnLeft.setOnClickListener { updateIndicators(left = true) }
        binding.btnRight.setOnClickListener { updateIndicators(right = true) }
        binding.btnHazard.setOnClickListener { updateIndicators(hazard = true) }
        binding.btnOff.setOnClickListener { updateIndicators() }
    }

    private fun updateIndicators(left: Boolean = false, right: Boolean = false, hazard: Boolean = false) {
        dbRef.child("left").setValue(left)
        dbRef.child("right").setValue(right)
        dbRef.child("hazard").setValue(hazard)
    }
}
*/
/*package com.example.ind_remote

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.example.ind_remote.databinding.ActivityMainBinding
import com.google.firebase.database.FirebaseDatabase

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    // Firebase reference
    private val dbRef = FirebaseDatabase.getInstance(
        "https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app//"
    ).getReference("ind_remote")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // 🔥 Test write (confirms Firebase connection)
        dbRef.child("status").setValue("App Connected")
            .addOnSuccessListener {
                Log.d("FIREBASE", "Connected to Firebase")
            }
            .addOnFailureListener {
                Log.e("FIREBASE", "Firebase connection failed", it)
            }

        // Button listeners
        binding.btnLeft.setOnClickListener {
            updateIndicators(left = true)
        }

        binding.btnRight.setOnClickListener {
            updateIndicators(right = true)
        }

        binding.btnHazard.setOnClickListener {
            updateIndicators(hazard = true)
        }

        binding.btnOff.setOnClickListener {
            updateIndicators()
        }
    }

    private fun updateIndicators(
        left: Boolean = false,
        right: Boolean = false,
        hazard: Boolean = false
    ) {
        dbRef.child("left").setValue(left)
        dbRef.child("right").setValue(right)
        dbRef.child("hazard").setValue(hazard)

        Log.d(
            "FIREBASE",
            "Updated → left=$left right=$right hazard=$hazard"
        )
    }
}*/

package com.example.ind_remote

import android.graphics.Color
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.database.FirebaseDatabase

class MainActivity : AppCompatActivity() {

    // Firebase database reference
    private val dbRef = FirebaseDatabase.getInstance(
        "https://edge-data-filtering-default-rtdb.asia-southeast1.firebasedatabase.app//"
    ).getReference("car_indicators")

    // Indicator states
    private var isLeftOn = false
    private var isRightOn = false
    private var isHazardOn = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Buttons
        val btnLeft = findViewById<Button>(R.id.btnLeft)
        val btnRight = findViewById<Button>(R.id.btnRight)
        val btnHazard = findViewById<Button>(R.id.btnHazard)
        val btnOff = findViewById<Button>(R.id.btnOff)

        // LEFT Indicator
        btnLeft.setOnClickListener {
            isLeftOn = true
            isRightOn = false
            isHazardOn = false

            updateIndicators(btnLeft, btnRight, btnHazard)
        }

        // RIGHT Indicator
        btnRight.setOnClickListener {
            isRightOn = true
            isLeftOn = false
            isHazardOn = false

            updateIndicators(btnLeft, btnRight, btnHazard)
        }

        // HAZARD Indicator
        btnHazard.setOnClickListener {
            isHazardOn = true
            isLeftOn = true
            isRightOn = true

            updateIndicators(btnLeft, btnRight, btnHazard)
        }

        // OFF Button
        btnOff.setOnClickListener {
            isLeftOn = false
            isRightOn = false
            isHazardOn = false

            updateIndicators(btnLeft, btnRight, btnHazard)
        }
    }

    // Function to update button UI and Firebase
    private fun updateIndicators(btnLeft: Button, btnRight: Button, btnHazard: Button) {
        // Update Left button
        btnLeft.text = if (isLeftOn) "Left ON" else "Left OFF"
        btnLeft.setBackgroundColor(Color.parseColor(if (isLeftOn) "#2E7D32" else "#4CAF50"))

        // Update Right button
        btnRight.text = if (isRightOn) "Right ON" else "Right OFF"
        btnRight.setBackgroundColor(Color.parseColor(if (isRightOn) "#2E7D32" else "#4CAF50"))

        // Update Hazard button
        btnHazard.text = if (isHazardOn) "Hazard ON" else "Hazard OFF"
        btnHazard.setBackgroundColor(Color.parseColor(if (isHazardOn) "#FFA000" else "#FFC107"))

        // Update Firebase
        dbRef.child("left_indicator").setValue(isLeftOn)
        dbRef.child("right_indicator").setValue(isRightOn)
        dbRef.child("hazard").setValue(isHazardOn)
    }
}

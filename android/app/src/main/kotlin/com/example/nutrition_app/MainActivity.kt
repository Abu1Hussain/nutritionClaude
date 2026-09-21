package com.example.nutrition_app

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) is required by the `health`
// plugin's Health Connect permission flow on Android 14+, which uses
// registerForActivityResult and needs a ComponentActivity.
class MainActivity : FlutterFragmentActivity()

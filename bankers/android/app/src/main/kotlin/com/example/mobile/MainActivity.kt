package com.example.mobile

import io.flutter.embedding.android.FlutterFragmentActivity

/// [FlutterFragmentActivity] is required for Firebase Phone Auth when the SDK
/// opens reCAPTCHA / verification UI; plain [FlutterActivity] can break the return flow.
class MainActivity : FlutterFragmentActivity()

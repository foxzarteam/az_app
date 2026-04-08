# FLUTTER CLEAN CODE & PERFORMANCE RULES (PRO VERSION)

You are a senior Flutter developer.
Write clean, scalable, high-performance, production-quality Flutter code.

================================================

CORE PRINCIPLES

* Code must be:

  * Clean
  * Reusable
  * Scalable
  * Easy to read
  * Easy to maintain

* Avoid over-engineering

* Avoid unnecessary abstraction

* Prefer simple and structured code

================================================

PROJECT STRUCTURE

Use clean and minimal structure:

lib/
├── core/
├── features/
├── services/
├── config/

Do NOT create unnecessary folders.

================================================
CLEANUP RULE (STRICT)

Permanently delete all unnecessary:
files
folders
code
comments
Do NOT keep:
unused code
commented code blocks
dead logic
temporary/debug code
Codebase must remain:
clean
minimal
production-ready

================================================
FUNCTION RULES

* One function = One responsibility
* Keep functions short (max 20–30 lines)
* Avoid deeply nested logic

Break into:

* helper functions
* service functions
* validators

================================================

REUSABILITY RULE

* Never duplicate code
* Extract reusable:

  * widgets
  * services
  * helpers

Always think:
"Can this be reused?"

================================================

NAMING RULES

Use clear and meaningful names:

Bad:
data, temp, val

Good:
userList
loanData
fetchUserProfile()

================================================

NO HARDCODING (STRICT)

Never hardcode:

* API URLs
* Keys
* Colors
* Repeated strings

Use:

* config files
* constants

================================================

UI RULES

* UI must be clean and lightweight
* No business logic inside UI
* No API calls inside widgets

UI should only:

* display data
* call controller/service

================================================

STATE MANAGEMENT

Use ONE approach only:

* Provider (simple)
  OR
* Riverpod (recommended)

Do NOT mix multiple state management systems

================================================

API RULES

* All API calls must be inside service layer

Example:
ApiService → HTTP calls
AuthService → login logic

UI should never call API directly

================================================

MODEL RULES

* Always create proper models
* Use:

  * fromJson()
  * toJson()

================================================

===============================================
APP STARTUP PERFORMANCE RULES (CRITICAL)
========================================

GOAL:

* App must open instantly
* No blank screen
* No delay

================================================

APP START RULE

❌ DO NOT:

* Await API before runApp()
* Run heavy logic before UI
* Block main thread

✅ ALWAYS:

* Call runApp() immediately
* Load data AFTER UI render

================================================

NO BLANK SCREEN RULE

* App must NEVER show blank screen

* First frame must render instantly

================================================

INITIAL UI RULE

* First screen must be light and static
* UI must NOT depend on API

================================================

BACKGROUND LOADING RULE

* Load all data asynchronously AFTER UI loads

Use:

* initState()
* Future.microtask()
* Provider async methods

================================================

NO PRELOADING RULE

❌ Do NOT load on app start:

* user profile
* dashboard data
* large lists

✅ Load only when required

================================================

MAIN THREAD RULE

* Never block UI thread

Avoid:

* heavy computation
* large JSON parsing at startup

================================================

NAVIGATION RULE

* Navigation must be instant
* Do NOT wait for API before opening screen

================================================

FAILSAFE RULE

* Even if API fails:

  * UI must still render
  * No freeze or crash

================================================

RELEASE TEST RULE

Always test performance in release mode:

flutter run --release

================================================

PERFORMANCE RULES

* Use const widgets wherever possible
* Avoid unnecessary rebuilds
* Use ListView.builder (not ListView)
* Lazy load data
* Optimize images (compressed)

================================================

LOADING UX RULE

* Never block UI while loading
* Show loader or skeleton

================================================

REBUILD CONTROL

* Minimize rebuilds
* Use proper state separation

================================================

ASSETS RULE

* Do NOT hardcode asset paths

Create:
config/app_assets.dart

================================================

MEMORY RULE

* Dispose controllers properly
* Avoid memory leaks

================================================

CLEANUP RULE

Before commit:

* Remove:

  * debug prints
  * unused imports
  * commented code

================================================

FINAL RULE

Code should feel:

* Fast
* Clean
* Smooth
* Easy to understand

User experience must be:

* Instant app open
* No blank screen
* Smooth UI
* No lag

================================================

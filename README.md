Pulse Feed

Flutter + Riverpod + Supabase infinite scroll feed app.

Setup
1. Create Supabase project, run provided SQL for tables and toggle_like RPC, create public media bucket.
2. Run Python seeding script to upload images.
3. Add Supabase URL and anon key in lib/core/constants.dart.
4. Run flutter pub get then flutter run.

Riverpod Approach
All feed state lives in one AsyncNotifierProvider called FeedNotifier. It handles pagination with loadMore, pull to refresh with refresh, and optimistic likes with toggleLike.

Optimistic likes and spam click fix
Tapping Like instantly flips the UI state and starts a 600ms debounce timer. Only when taps go quiet does it sync with the server. If net taps are odd, one toggle_like RPC call is sent. If even, no call is needed since local state already matches the server. This means tapping Like 15 times fast never desyncs the database.

Offline revert
Before a tap burst starts, the original post state is saved. If the RPC call fails because of no internet, the state reverts back to that saved version and a snackbar error message shows up.

RepaintBoundary Verification
Ran the app in profile mode and opened DevTools Performance tab with Highlight repaints turned on. Scrolling fast showed only new cards flashing on repaint while existing cards stayed static. This confirms RepaintBoundary is caching the rasterized shadow instead of recalculating it every frame.

memCacheWidth Verification
memCacheWidth is set to the card width in logical pixels multiplied by device pixel ratio, matching the exact display size. Verified using DevTools Memory tab, memory stayed flat while scrolling through many posts instead of climbing up from full resolution decoded images.

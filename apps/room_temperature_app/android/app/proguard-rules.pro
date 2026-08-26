# Keep App Widget providers so the launcher and lock-screen host can
# instantiate them after R8 minification.
-keep public class com.comma.room_temperature.RoomTempWidgetProvider { *; }
-keep public class com.comma.room_temperature.RoomTempLockWidgetProvider { *; }
-keep public class com.comma.room_temperature.RoomTempWidgetViews { *; }

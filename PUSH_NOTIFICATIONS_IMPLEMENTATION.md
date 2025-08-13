# TaskMate Push Notifications - Technical Implementation Guide

## Quick Start

This guide walks through implementing push notifications in TaskMate using Supabase Edge Functions, OneSignal, and Firebase Cloud Messaging.

## Prerequisites

- Flutter project with Supabase integration
- OneSignal account
- Firebase project
- Supabase project with Edge Functions enabled

## Step 1: OneSignal Setup

### 1.1 Create OneSignal App
```bash
# Go to OneSignal Dashboard
https://app.onesignal.com/

# Create new app: TaskMate
# Platform: Google Android (FCM)
# SDK: Flutter
```

### 1.2 Get Credentials
```dart
// lib/core/services/onesignal_service.dart
class OneSignalService {
  // Replace with your actual OneSignal App ID
  static String get _oneSignalAppId => 'YOUR_ONESIGNAL_APP_ID';
}
```

## Step 2: Firebase Configuration

### 2.1 Add Android App
```bash
# Firebase Console → Project Settings
# Add app → Android
# Package name: com.example.taskmate
# Download google-services.json
```

### 2.2 Generate Service Account Key
```bash
# Firebase Console → Project Settings → Service Accounts
# Generate new private key
# Download JSON file for OneSignal
```

### 2.3 Update OneSignal FCM Settings
```bash
# OneSignal Dashboard → Settings → Mobile Push
# Upload Service Account JSON
# Verify Firebase Project ID: taskmate-5b7e4
```

## Step 3: Flutter Dependencies

### 3.1 Add Packages
```yaml
# pubspec.yaml
dependencies:
  onesignal_flutter: ^5.0.0
  supabase_flutter: ^2.0.0
  http: ^1.4.0
```

### 3.2 Install Dependencies
```bash
flutter pub get
```

## Step 4: OneSignal Service Implementation

### 4.1 Create OneSignal Service
```dart
// lib/core/services/onesignal_service.dart
import 'dart:async';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OneSignalService {
  static String get _oneSignalAppId => 'YOUR_ONESIGNAL_APP_ID';
  static String? _cachedPlayerId;
  static Completer<String?>? _playerIdCompleter;

  static Future<void> initialize() async {
    print('=== OneSignal Initialization Start ===');
    
    try {
      // Initialize OneSignal
      OneSignal.initialize(_oneSignalAppId);
      
      // Request notification permission
      await OneSignal.Notifications.requestPermission(true);
      
      // Setup notification handlers
      _setupNotificationHandlers();
      
      // Trigger device registration
      await OneSignal.User.pushSubscription.optedIn;
      
      // Wait for initialization
      await Future.delayed(Duration(seconds: 8));
      
      // Check final state
      final finalDeviceState = OneSignal.User.pushSubscription;
      if (finalDeviceState.id != null && finalDeviceState.id!.isNotEmpty) {
        _cachedPlayerId = finalDeviceState.id;
        print('Device successfully registered with ID: $_cachedPlayerId');
      }
      
      print('=== OneSignal Initialization Complete ===');
    } catch (e) {
      print('Error during OneSignal initialization: $e');
    }
  }

  static void _setupNotificationHandlers() {
    // Click handler
    OneSignal.Notifications.addClickListener((event) {
      _handleNotificationClick(event.notification);
    });

    // Foreground display handler
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('Notification will display: ${event.notification.jsonRepresentation()}');
    });

    // Push subscription change handler
    OneSignal.User.pushSubscription.addObserver((state) {
      print('Push subscription changed: ${state.jsonRepresentation()}');
      _cachedPlayerId = state.current.id;
      if (_cachedPlayerId != null && _cachedPlayerId!.isNotEmpty) {
        if (_playerIdCompleter != null && !_playerIdCompleter!.isCompleted) {
          _playerIdCompleter!.complete(_cachedPlayerId);
        }
      }
      _handlePushSubscriptionChange(state);
    });
  }

  static Future<String?> getPlayerId() async {
    try {
      // Use cached ID if available
      if (_cachedPlayerId != null && _cachedPlayerId!.isNotEmpty) {
        return _cachedPlayerId;
      }

      // Wait for initialization
      await Future.delayed(Duration(seconds: 2));

      // Get current state
      final deviceState = OneSignal.User.pushSubscription;
      final playerId = deviceState.id;

      if (playerId != null && playerId.isNotEmpty) {
        _cachedPlayerId = playerId;
        return playerId;
      }

      // Wait for observer
      if (_playerIdCompleter == null || _playerIdCompleter!.isCompleted) {
        _playerIdCompleter = Completer<String?>();
      }

      final awaitedPlayerId = await _playerIdCompleter!.future
          .timeout(const Duration(seconds: 30), onTimeout: () => null);

      if (awaitedPlayerId != null && awaitedPlayerId.isNotEmpty) {
        _cachedPlayerId = awaitedPlayerId;
        return awaitedPlayerId;
      }

      return null;
    } catch (e) {
      print('Error getting OneSignal player ID: $e');
      return null;
    }
  }

  static Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      print('OneSignal external user ID set: $userId');

      final playerId = await getPlayerId();
      if (playerId != null) {
        await _registerDeviceWithSupabase(playerId);
      }
    } catch (e) {
      print('Error setting OneSignal external user ID: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await OneSignal.logout();
      await _unregisterDeviceFromSupabase();
    } catch (e) {
      print('Error logging out from OneSignal: $e');
    }
  }

  static Future<void> _registerDeviceWithSupabase(String playerId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Check if device exists
      final result = await supabase
          .from('user_devices')
          .select('id')
          .eq('onesignal_player_id', playerId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (result == null) {
        // Insert new device
        await supabase.from('user_devices').insert({
          'user_id': user.id,
          'onesignal_player_id': playerId,
          'device_type': 'mobile',
          'is_active': true,
        });
      } else {
        // Update existing device
        await supabase.from('user_devices').update({
          'is_active': true,
          'last_seen': DateTime.now().toIso8601String(),
        }).eq('onesignal_player_id', playerId);
      }
    } catch (e) {
      print('Error registering device with Supabase: $e');
    }
  }

  static Future<void> _unregisterDeviceFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final currentPlayerId = OneSignal.User.pushSubscription.id;
      if (currentPlayerId == null || currentPlayerId.isEmpty) return;

      await supabase
          .from('user_devices')
          .update({
            'is_active': false,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('onesignal_player_id', currentPlayerId);
    } catch (e) {
      print('Error unregistering device from Supabase: $e');
    }
  }

  static void _handleNotificationClick(OSNotification notification) {
    final additionalData = notification.additionalData;
    if (additionalData != null) {
      final taskId = additionalData['taskId'];
      final type = additionalData['type'];

      if (type == 'task_reminder' && taskId != null) {
        // Navigate to task detail
        print('Navigate to task: $taskId');
      }
    }
  }

  static void _handlePushSubscriptionChange(OSPushSubscriptionChangedState state) {
    if (state.current.id != null) {
      _registerDeviceWithSupabase(state.current.id!);
    } else {
      _unregisterDeviceFromSupabase();
    }
  }
}
```

## Step 5: Reminder Service Implementation

### 5.1 Create Reminder Service
```dart
// lib/core/services/reminder_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'onesignal_service.dart';

class ReminderService {
  static String get _supabaseUrl => 'YOUR_SUPABASE_URL';
  static String get _supabaseAnonKey => 'YOUR_SUPABASE_ANON_KEY';

  static Future<void> scheduleTaskReminder(TaskModel task) async {
    if (!task.hasReminder || task.reminderAt == null) return;

    try {
      await _schedulePushReminder(task);
      print('Push notification scheduled for task: ${task.name}');
    } catch (e) {
      print('Error scheduling push notification: $e');
    }
  }

  static Future<void> _schedulePushReminder(TaskModel task) async {
    try {
      // Get OneSignal player ID
      final playerId = await OneSignalService.getPlayerId();
      if (playerId == null || playerId.isEmpty) {
        print('Error: Could not get OneSignal player ID');
        return;
      }

      // Calculate reminder time (for testing: 5 seconds from now)
      final scheduledDate = DateTime.now().add(Duration(seconds: 5));

      // Prepare request
      final requestBody = {
        'taskId': task.id,
        'userId': task.userId,
        'title': 'Task Reminder: ${task.name}',
        'message': 'Your task "${task.name}" is due soon!',
        'scheduledAt': scheduledDate.toIso8601String(),
        'priority': task.priority,
        'reminderType': task.reminderType ?? '1hour',
        'playerId': playerId,
      };

      // Call Edge Function
      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/schedule_task_reminder'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Push notification scheduled successfully: ${result['notificationId']}');
      } else {
        print('Error scheduling push notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error scheduling push notification: $e');
    }
  }
}
```

## Step 6: Supabase Edge Function

### 6.1 Create Edge Function
```bash
# In your Supabase project
supabase functions new schedule_task_reminder
```

### 6.2 Implement Function
```typescript
// supabase/functions/schedule_task_reminder/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestBody = await req.json()
    const { taskId, userId, title, message, scheduledAt, priority, reminderType, playerId } = requestBody

    // Validate required fields
    if (!taskId || !userId || !title || !message || !scheduledAt || !playerId) {
      throw new Error('Missing required fields')
    }

    // Get OneSignal credentials
    const oneSignalAppId = Deno.env.get('ONESIGNAL_APP_ID')
    const oneSignalRestApiKey = Deno.env.get('ONESIGNAL_REST_API_KEY')

    if (!oneSignalAppId || !oneSignalRestApiKey) {
      throw new Error('OneSignal configuration missing')
    }

    // Create notification data
    const notificationData = {
      app_id: oneSignalAppId,
      include_player_ids: [playerId],
      headings: { en: title },
      contents: { en: message },
      // Remove send_after for immediate delivery
      data: {
        taskId,
        userId,
        priority,
        reminderType,
        type: 'task_reminder'
      },
      priority: 10
    }

    // Send to OneSignal
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${oneSignalRestApiKey}`
      },
      body: JSON.stringify(notificationData)
    })

    if (!response.ok) {
      const responseText = await response.text()
      throw new Error(`OneSignal API error: ${responseText}`)
    }

    const result = await response.json()

    // Store notification record
    await storeScheduledNotification({
      taskId,
      userId,
      title,
      message,
      scheduledAt,
      oneSignalNotificationId: result.id
    })

    return new Response(
      JSON.stringify({ 
        success: true, 
        notificationId: result.id,
        message: 'Task reminder scheduled successfully' 
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    console.error('Error scheduling task reminder:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})

async function storeScheduledNotification(data: {
  taskId: string
  userId: string
  title: string
  message: string
  scheduledAt: string
  oneSignalNotificationId: string
}) {
  console.log('Storing scheduled notification:', data)
  // Implement database storage here
}
```

### 6.3 Deploy Function
```bash
supabase functions deploy schedule_task_reminder
```

## Step 7: Integration in Flutter App

### 7.1 Initialize in Main
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Initialize OneSignal
  await OneSignalService.initialize();

  runApp(const MyApp());
}
```

### 7.2 Integrate with Auth
```dart
// lib/cubit/auth_cubit.dart
import 'package:taskmate/core/services/onesignal_service.dart';

class AuthCubit extends Cubit<AuthState> {
  // ... existing code ...

  void login({required String name, required String email, required String password}) async {
    try {
      emit(AuthLoading());
      
      final userModel = await authRemoteRepository.login(
        name: name,
        email: email,
        password: password,
      );

      // Link OneSignal to user
      await OneSignalService.setExternalUserId(userModel.id);
      
      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void logout() async {
    try {
      // Logout from OneSignal
      await OneSignalService.logout();
      
      await spService.removeToken();
      emit(AuthInitial());
    } catch (e) {
      print('Error during logout: $e');
      emit(AuthInitial());
    }
  }
}
```

### 7.3 Use in Task Creation
```dart
// lib/cubit/add_new_task_cubit.dart
import 'package:taskmate/core/services/reminder_service.dart';

class AddNewTaskCubit extends Cubit<AddNewTaskState> {
  Future<void> createNewTask({...}) async {
    try {
      // ... existing task creation code ...

      // Schedule reminder
      final taskWithReminder = taskModel.copyWith(
        hasReminder: true,
        reminderAt: taskModel.dueAt,
        reminderType: '1hour',
      );

      await ReminderService.scheduleTaskReminder(taskWithReminder);
      
      emit(AddNewTakSucess(taskModel));
    } catch (e) {
      emit(AddNewTakError(e.toString()));
    }
  }
}
```

## Step 8: Database Setup

### 8.1 Create Tables
```sql
-- User devices table
CREATE TABLE user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  onesignal_player_id TEXT NOT NULL,
  device_type TEXT DEFAULT 'mobile',
  is_active BOOLEAN DEFAULT true,
  last_seen TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Scheduled notifications table
CREATE TABLE scheduled_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  scheduled_at TIMESTAMP NOT NULL,
  onesignal_notification_id TEXT NOT NULL,
  status TEXT DEFAULT 'scheduled',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_devices_player_id ON user_devices(onesignal_player_id);
CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);
CREATE INDEX idx_scheduled_notifications_task_id ON scheduled_notifications(task_id);
```

## Step 9: Testing

### 9.1 Test Device Registration
```dart
// In your app
final playerId = await OneSignalService.getPlayerId();
print('Player ID: $playerId'); // Should show UUID
```

### 9.2 Test Notification
1. Create a task in your app
2. Check OneSignal dashboard for scheduled message
3. Verify notification appears on device
4. Check delivery status

### 9.3 Test Edge Function
```bash
curl -X POST https://your-project.supabase.co/functions/v1/schedule_task_reminder \
  -H "Authorization: Bearer your_anon_key" \
  -H "Content-Type: application/json" \
  -d '{"taskId":"test","userId":"test","title":"Test","message":"Test","scheduledAt":"2025-08-13T14:50:20.997Z","priority":"Medium","reminderType":"1hour","playerId":"your_player_id"}'
```

## Troubleshooting

### Common Issues

#### 1. Empty Player ID
- Check OneSignal FCM configuration
- Verify google-services.json package name
- Clear app data and reinstall

#### 2. Notifications Not Delivering
- Check OneSignal delivery logs
- Verify FCM server key in OneSignal
- Test with direct OneSignal notification

#### 3. Edge Function Errors
- Check environment variables
- Verify OneSignal credentials
- Check function deployment status

### Debug Steps
1. **Check Flutter logs** for OneSignal initialization
2. **Verify OneSignal dashboard** for device registration
3. **Check Edge Function logs** for API calls
4. **Test direct from OneSignal** to isolate issues

## Security Notes

- Store OneSignal REST API key in Supabase environment variables
- Never expose API keys in client-side code
- Implement proper user authentication
- Use Row Level Security (RLS) in Supabase

## Performance Tips

- Cache OneSignal player ID in app memory
- Implement device ID persistence
- Use Supabase connection pooling
- Implement proper error handling and retries

---

**Next Steps:**
1. Implement real scheduling logic
2. Add notification management (cancel, update)
3. Implement notification analytics
4. Add iOS support
5. Implement rich notifications

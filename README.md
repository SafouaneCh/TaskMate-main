# TaskMate - Push Notification System Documentation

## Overview
TaskMate implements a robust push notification system using **Supabase Edge Functions**, **OneSignal**, and **Firebase Cloud Messaging (FCM)** to deliver real-time task reminders to users' mobile devices.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │───▶│  Supabase Edge   │───▶│    OneSignal    │───▶│  User Device    │
│                 │    │     Function     │    │                 │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘    └─────────────────┘
```

### Components
1. **Flutter App**: Collects OneSignal player ID and triggers notification scheduling
2. **Supabase Edge Function**: Processes notification requests and calls OneSignal API
3. **OneSignal**: Manages device registration and FCM delivery
4. **Firebase**: Provides FCM infrastructure for Android push notifications

## Setup Guide

### 1. OneSignal Configuration

#### Create OneSignal App
1. Go to [OneSignal Dashboard](https://app.onesignal.com/)
2. Create new app: **TaskMate**
3. Select platform: **Google Android (FCM)**
4. Choose SDK: **Flutter**

#### FCM Configuration
1. **Package Name**: `com.example.taskmate`
2. **Google Project Number**: `470358511139`
3. **Service Account JSON**: Upload Firebase service account key

#### Get Credentials
- **App ID**: `703bd8e3-08be-4f1f-b706-299651407f5a`
- **REST API Key**: From OneSignal dashboard

### 2. Firebase Setup

#### Project Configuration
- **Project ID**: `taskmate-5b7e4`
- **Package Name**: `com.example.taskmate`

#### Service Account
1. Go to Firebase Console → Project Settings
2. Service Accounts tab
3. Generate new private key
4. Download JSON file for OneSignal

#### google-services.json
Place in `android/app/google-services.json`:
```json
{
  "project_info": {
    "project_number": "470358511139",
    "project_id": "taskmate-5b7e4"
  },
  "client": [{
    "client_info": {
      "android_client_info": {
        "package_name": "com.example.taskmate"
      }
    }
  }]
}
```

### 3. Supabase Configuration

#### Environment Variables
Set in Supabase dashboard:
```bash
ONESIGNAL_APP_ID=703bd8e3-08be-4f1f-b706-299651407f5a
ONESIGNAL_REST_API_KEY=your_rest_api_key_here
```

#### Edge Function
Deploy `schedule_task_reminder` function:
```bash
supabase functions deploy schedule_task_reminder
```

### 4. Flutter App Configuration

#### Dependencies
```yaml
dependencies:
  onesignal_flutter: ^5.0.0
  supabase_flutter: ^2.0.0
  http: ^1.4.0
```

#### OneSignal Service
```dart
// lib/core/services/onesignal_service.dart
class OneSignalService {
  static String get _oneSignalAppId => '703bd8e3-08be-4f1f-b706-299651407f5a';
  
  static Future<void> initialize() async {
    OneSignal.initialize(_oneSignalAppId);
    await OneSignal.Notifications.requestPermission(true);
    // ... setup handlers
  }
}
```

## How It Works

### 1. Device Registration
```dart
// App startup
await OneSignalService.initialize();

// After user login
await OneSignalService.setExternalUserId(user.id);
```

**What happens:**
1. OneSignal initializes with your app ID
2. Requests notification permission from user
3. Registers device with OneSignal
4. Gets unique player ID for the device
5. Links device to user account

### 2. Task Creation & Notification
```dart
// When creating a task
await ReminderService.scheduleTaskReminder(task);
```

**Flow:**
1. **Flutter App** → Gets OneSignal player ID
2. **ReminderService** → Calls Supabase Edge Function
3. **Edge Function** → Validates request and calls OneSignal API
4. **OneSignal** → Sends notification via FCM
5. **User Device** → Receives push notification

### 3. Edge Function Processing
```typescript
// supabase/functions/schedule_task_reminder/index.ts
const notificationData = {
  app_id: oneSignalAppId,
  include_player_ids: [playerId],
  headings: { en: title },
  contents: { en: message },
  data: { taskId, userId, priority, type: 'task_reminder' }
};

const response = await fetch('https://onesignal.com/api/v1/notifications', {
  method: 'POST',
  headers: { 'Authorization': `Basic ${oneSignalRestApiKey}` },
  body: JSON.stringify(notificationData)
});
```

## API Endpoints

### Schedule Task Reminder
```
POST /functions/v1/schedule_task_reminder
```

**Request Body:**
```json
{
  "taskId": "uuid",
  "userId": "uuid", 
  "title": "Task Reminder: Task Name",
  "message": "Your task \"Task Name\" is due soon!",
  "scheduledAt": "2025-08-13T14:50:20.997Z",
  "priority": "Medium priority",
  "reminderType": "1hour",
  "playerId": "onesignal_player_id"
}
```

**Response:**
```json
{
  "success": true,
  "notificationId": "onesignal_notification_id",
  "message": "Task reminder scheduled successfully"
}
```

## Database Schema

### User Devices Table
```sql
CREATE TABLE user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  onesignal_player_id TEXT NOT NULL,
  device_type TEXT DEFAULT 'mobile',
  is_active BOOLEAN DEFAULT true,
  last_seen TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_user_devices_player_id ON user_devices(onesignal_player_id);
CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);
```

### Scheduled Notifications Table
```sql
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
```

## Troubleshooting

### Common Issues

#### 1. Device Not Getting Player ID
**Symptoms:** Empty player ID in logs
**Solutions:**
- Check OneSignal FCM configuration
- Verify google-services.json package name
- Ensure notification permissions are granted
- Clear app data and reinstall

#### 2. Notifications Not Delivering
**Symptoms:** Scheduled but not received
**Solutions:**
- Check OneSignal delivery logs
- Verify FCM server key in OneSignal
- Check device notification settings
- Test with direct OneSignal notification

#### 3. Edge Function Errors
**Symptoms:** 400/500 responses
**Solutions:**
- Check environment variables
- Verify OneSignal credentials
- Check function deployment status
- Review function logs

### Debug Logs

#### Flutter App
```dart
// Enable detailed logging
print('=== OneSignal Debug Info ===');
print('Device state ID: ${deviceState.id}');
print('Raw player ID: "$playerId"');
```

#### Edge Function
```typescript
console.log('Received request body:', JSON.stringify(requestBody, null, 2));
console.log('OneSignal API response:', responseText);
```

#### OneSignal Dashboard
- **Delivery** → **Message History**
- **Audience** → **Users** → Device details
- **Settings** → **Message & Notifications** → Error logs

## Testing

### 1. Test Device Registration
```dart
final playerId = await OneSignalService.getPlayerId();
print('Player ID: $playerId'); // Should show UUID, not empty
```

### 2. Test Notification Delivery
1. Create a task in your app
2. Check OneSignal dashboard for scheduled message
3. Verify notification appears on device
4. Check delivery status in OneSignal

### 3. Test Edge Function
```bash
curl -X POST https://your-project.supabase.co/functions/v1/schedule_task_reminder \
  -H "Authorization: Bearer your_anon_key" \
  -H "Content-Type: application/json" \
  -d '{"taskId":"test","userId":"test","title":"Test","message":"Test","scheduledAt":"2025-08-13T14:50:20.997Z","priority":"Medium","reminderType":"1hour","playerId":"your_player_id"}'
```

## Security Considerations

### 1. API Key Protection
- Store OneSignal REST API key in Supabase environment variables
- Never expose API keys in client-side code
- Use Row Level Security (RLS) in Supabase

### 2. User Authentication
- Verify user ownership before scheduling notifications
- Validate player ID belongs to authenticated user
- Implement proper user session management

### 3. Rate Limiting
- Implement request throttling in Edge Function
- Monitor OneSignal API usage
- Set reasonable limits per user

## Performance Optimization

### 1. Caching
- Cache OneSignal player ID in app memory
- Implement device ID persistence
- Use Supabase connection pooling

### 2. Batch Processing
- Group multiple notifications when possible
- Use OneSignal's batch API for bulk operations
- Implement notification queuing

### 3. Error Handling
- Implement retry logic for failed notifications
- Graceful degradation when services unavailable
- User feedback for notification failures

## Future Enhancements

### 1. Advanced Scheduling
- Recurring notifications
- Time zone support
- Custom notification sounds
- Rich media notifications

### 2. Analytics
- Notification open rates
- User engagement tracking
- A/B testing for notification content
- Delivery success metrics

### 3. Multi-Platform
- iOS push notifications
- Web push notifications
- Email fallbacks
- SMS integration

## Support & Resources

### Documentation
- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

### Community
- [OneSignal Community](https://community.onesignal.com/)
- [Supabase Discord](https://discord.supabase.com/)
- [Flutter Community](https://flutter.dev/community)

---

**Last Updated:** August 13, 2025  
**Version:** 1.0.0  
**Maintainer:** TaskMate Development Team

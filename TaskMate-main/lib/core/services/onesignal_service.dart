import 'dart:async';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Commented out temporarily

class OneSignalService {
  // Temporarily hardcoded - replace with your actual OneSignal App ID
  static String get _oneSignalAppId => '703bd8e3-08be-4f1f-b706-299651407f5a';

  // Removed fallback player ID to avoid masking registration issues
  static String? _cachedPlayerId;
  static Completer<String?>? _playerIdCompleter;

  static Future<void> initialize() async {
    print('=== OneSignal Initialization Start ===');
    print('OneSignal App ID: $_oneSignalAppId');

    try {
      // Do not force logout; it delays registration and clears state

      // Set OneSignal App ID with Android configuration
      OneSignal.initialize(_oneSignalAppId);

      print('OneSignal.initialize() called successfully');

      // Request notification permission once
      print('Requesting notification permission...');
      await OneSignal.Notifications.requestPermission(true);
      print('Notification permission requested');

      // Check if permission was granted
      final permissionStatus = OneSignal.Notifications.permission;
      print('Notification permission status: $permissionStatus');

      // Set up notification handlers
      print('Setting up notification handlers...');
      OneSignal.Notifications.addClickListener((event) {
        // Handle notification click
        print(
            'Push notification clicked: ${event.notification.jsonRepresentation()}');
        _handleNotificationClick(event.notification);
      });

      // Set up notification will display handler
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        // Handle notification display when app is in foreground
        print(
            'Push notification will display: ${event.notification.jsonRepresentation()}');
        // You can customize the notification display here
      });

      // Set up push subscription change handler
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

      // Explicitly trigger device registration
      print('Triggering device registration...');
      OneSignal.User.pushSubscription.optedIn;
      print('Device registration triggered');

      // Wait for OneSignal to be fully ready
      print('Waiting for OneSignal to be fully initialized...');
      await Future.delayed(Duration(seconds: 8));

      // Check final state
      final finalDeviceState = OneSignal.User.pushSubscription;
      print(
          'Final device state - ID: "${finalDeviceState.id}", OptedIn: ${finalDeviceState.optedIn}');
      if (finalDeviceState.id != null && finalDeviceState.id!.isNotEmpty) {
        _cachedPlayerId = finalDeviceState.id;
        print('Device successfully registered with ID: $_cachedPlayerId');
      }

      print('OneSignal initialized with App ID: $_oneSignalAppId');
      print('=== OneSignal Initialization Complete ===');
    } catch (e) {
      print('Error during OneSignal initialization: $e');
      print('=== OneSignal Initialization Failed ===');
    }
  }

  static void _handleNotificationClick(OSNotification notification) {
    // Extract data from notification
    final additionalData = notification.additionalData;
    if (additionalData != null) {
      final taskId = additionalData['taskId'];
      final type = additionalData['type'];

      print('Notification clicked - Task ID: $taskId, Type: $type');

      // Navigate to specific screen based on notification data
      // You can implement navigation logic here
      if (type == 'task_reminder' && taskId != null) {
        // Navigate to task detail screen
        print('Navigate to task: $taskId');
      }
    }
  }

  static void _handlePushSubscriptionChange(
    OSPushSubscriptionChangedState state,
  ) {
    // Handle when user enables/disables push notifications
    if (state.current.id != null) {
      print('Push subscription enabled: ${state.current.id}');
      _registerDeviceWithSupabase(state.current.id!);
    } else {
      print('Push subscription disabled');
      _unregisterDeviceFromSupabase();
    }
  }

  static Future<void> _registerDeviceWithSupabase(String playerId) async {
    try {
      final supabase = Supabase.instance.client;

      // Get current user
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Check if device already exists
      final result = await supabase
          .from('user_devices')
          .select('id')
          .eq('onesignal_player_id', playerId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (result == null) {
        // Insert new device record
        await supabase.from('user_devices').insert({
          'user_id': user.id,
          'onesignal_player_id': playerId,
          'device_type': 'mobile',
          'is_active': true,
        });
        print('Device registered with Supabase: $playerId');
      } else {
        // Update existing device
        await supabase.from('user_devices').update({
          'is_active': true,
          'last_seen': DateTime.now().toIso8601String(),
        }).eq('onesignal_player_id', playerId);
        print('Device updated in Supabase: $playerId');
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

      // Mark only the current device as inactive to avoid deactivating all devices
      final currentPlayerId = OneSignal.User.pushSubscription.id;
      if (currentPlayerId == null || currentPlayerId.isEmpty) {
        print('Skip unregister: missing current OneSignal player ID');
        return;
      }

      await supabase
          .from('user_devices')
          .update({
            'is_active': false,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('onesignal_player_id', currentPlayerId);

      print('Device unregistered from Supabase');
    } catch (e) {
      print('Error unregistering device from Supabase: $e');
    }
  }

  static Future<String?> getPlayerId() async {
    try {
      print('=== OneSignal Debug Info ===');
      print('Checking OneSignal initialization...');

      if (_cachedPlayerId != null && _cachedPlayerId!.isNotEmpty) {
        print('Using cached OneSignal player ID: $_cachedPlayerId');
        return _cachedPlayerId;
      }

      // Wait longer for OneSignal to be fully initialized and registered
      await Future.delayed(Duration(seconds: 2));

      print('Getting push subscription state...');
      final deviceState = OneSignal.User.pushSubscription;
      print('Device state ID: ${deviceState.id}');

      final playerId = deviceState.id;
      print('Raw player ID: "$playerId"');

      if (playerId != null && playerId.isNotEmpty) {
        print('Successfully got OneSignal player ID: $playerId');
        _cachedPlayerId = playerId;
        return playerId;
      } else {
        print('OneSignal player ID is null or empty, waiting for observer...');
        if (_playerIdCompleter == null || _playerIdCompleter!.isCompleted) {
          _playerIdCompleter = Completer<String?>();
        }
        final awaitedPlayerId = await _playerIdCompleter!.future
            .timeout(const Duration(seconds: 30), onTimeout: () => null);
        if (awaitedPlayerId != null && awaitedPlayerId.isNotEmpty) {
          print('Got OneSignal player ID via observer: $awaitedPlayerId');
          _cachedPlayerId = awaitedPlayerId;
          return awaitedPlayerId;
        }
        print('Timed out waiting for OneSignal player ID');
        print('=== End OneSignal Debug Info ===');
        return null;
      }
    } catch (e) {
      print('Error getting OneSignal player ID: $e');
      print('=== End OneSignal Debug Info ===');
      return null;
    }
  }

  static Future<void> setExternalUserId(String userId) async {
    try {
      print('Setting OneSignal external user ID: $userId');
      await OneSignal.login(userId);
      print('OneSignal external user ID set: $userId');

      // Register device with Supabase after login
      final playerId = await getPlayerId();
      if (playerId != null) {
        print('Player ID available, registering device with Supabase...');
        await _registerDeviceWithSupabase(playerId);
      } else {
        print(
            'Player ID not available yet, device not registered with Supabase');
      }
    } catch (e) {
      print('Error setting OneSignal external user ID: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await OneSignal.logout();
      print('OneSignal logout successful');

      // Unregister device from Supabase after logout
      await _unregisterDeviceFromSupabase();
    } catch (e) {
      print('Error logging out from OneSignal: $e');
    }
  }

  static Future<bool> isPushEnabled() async {
    try {
      final deviceState = OneSignal.User.pushSubscription;
      return deviceState.id != null;
    } catch (e) {
      print('Error checking push notification status: $e');
      return false;
    }
  }

  static Future<void> requestNotificationPermission() async {
    try {
      await OneSignal.Notifications.requestPermission(true);
      print('Notification permission requested');
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }
}

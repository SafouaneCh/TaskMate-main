import 'package:shared_preferences/shared_preferences.dart';

class SpService {
  // Token management
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('x-auth-token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-auth-token');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-auth-token');
  }

  // Settings management
  Future<void> setNotificationSettings({
    required bool pushNotifications,
    required bool emailNotifications,
    required bool taskReminders,
    required bool dailyDigest,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', pushNotifications);
    await prefs.setBool('email_notifications', emailNotifications);
    await prefs.setBool('task_reminders', taskReminders);
    await prefs.setBool('daily_digest', dailyDigest);
  }

  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'push_notifications': prefs.getBool('push_notifications') ?? true,
      'email_notifications': prefs.getBool('email_notifications') ?? false,
      'task_reminders': prefs.getBool('task_reminders') ?? true,
      'daily_digest': prefs.getBool('daily_digest') ?? false,
    };
  }

  Future<void> setSecuritySettings({
    required bool biometricAuth,
    required bool autoLock,
    required bool dataSync,
    required bool analytics,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_auth', biometricAuth);
    await prefs.setBool('auto_lock', autoLock);
    await prefs.setBool('data_sync', dataSync);
    await prefs.setBool('analytics', analytics);
  }

  Future<Map<String, bool>> getSecuritySettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'biometric_auth': prefs.getBool('biometric_auth') ?? false,
      'auto_lock': prefs.getBool('auto_lock') ?? true,
      'data_sync': prefs.getBool('data_sync') ?? true,
      'analytics': prefs.getBool('analytics') ?? false,
    };
  }
}

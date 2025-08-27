# 🔧 Backend Configuration Guide

## Overview
This guide helps you configure the correct backend URL for your TaskMate app based on your development environment.

## 🚀 Quick Setup

### 1. **Android Emulator** (Default)
```dart
// In lib/core/constants/constants.dart
static const String androidBaseUrl = 'http://10.0.2.2:8000';
```
- ✅ **Default setting** - works out of the box
- ✅ **No changes needed** if using Android emulator

### 2. **iOS Simulator**
```dart
// In lib/core/constants/constants.dart
static const String iosBaseUrl = 'http://localhost:8000';
```
- 🔧 **Change required**: Update `baseUrl` getter to return `iosBaseUrl`

### 3. **Physical Device**
```dart
// In lib/core/constants/constants.dart
static const String deviceBaseUrl = 'http://192.168.1.100:8000';
```
- 🔧 **Change required**: 
  1. Find your computer's IP address
  2. Update `deviceBaseUrl` with your actual IP
  3. Update `baseUrl` getter to return `deviceBaseUrl`

## 📱 Environment Detection (Optional)

For automatic environment detection, you can enhance the constants file:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class BackendConfig {
  static const String androidBaseUrl = 'http://10.0.2.2:8000';
  static const String iosBaseUrl = 'http://localhost:8000';
  static const String deviceBaseUrl = 'http://192.168.1.100:8000';
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000'; // Web
    }
    
    if (Platform.isAndroid) {
      return androidBaseUrl; // Android emulator
    }
    
    if (Platform.isIOS) {
      return iosBaseUrl; // iOS simulator
    }
    
    return deviceBaseUrl; // Physical device (fallback)
  }
}
```

## 🔍 Find Your Computer's IP Address

### **Windows:**
```cmd
ipconfig
```
Look for "IPv4 Address" under your active network adapter.

### **macOS/Linux:**
```bash
ifconfig
# or
ip addr
```
Look for "inet" followed by your IP address.

### **Common IP Ranges:**
- **Home WiFi**: `192.168.1.xxx` or `192.168.0.xxx`
- **Office**: `10.0.0.xxx` or `172.16.0.xxx`

## 🧪 Test Your Configuration

### 1. **Start Your Backend**
```bash
cd backend
docker compose up --build
```

### 2. **Test Health Endpoint**
```bash
# Android Emulator
curl http://10.0.2.2:8000/health

# iOS Simulator
curl http://localhost:8000/health

# Physical Device (replace with your IP)
curl http://192.168.1.100:8000/health
```

### 3. **Expected Response**
```json
{
  "status": "ok",
  "timestamp": "2025-01-26T12:30:00.000Z",
  "service": "TaskMate Backend",
  "version": "1.0.0"
}
```

## 🐛 Troubleshooting

### **"Connection refused" Error**
- ✅ **Check**: Is your backend running?
- ✅ **Solution**: Start with `docker compose up --build`

### **"Network error"**
- ✅ **Check**: Is the IP address correct?
- ✅ **Solution**: Verify IP with `ipconfig` or `ifconfig`

### **"Timeout" Error**
- ✅ **Check**: Firewall blocking port 8000?
- ✅ **Solution**: Allow port 8000 in firewall settings

### **"Cannot connect" on Physical Device**
- ✅ **Check**: Are both devices on same network?
- ✅ **Solution**: Ensure phone and computer are on same WiFi

## 🔄 Update Configuration

### **Step 1: Edit Constants File**
```bash
# Open the file
code TaskMate-main/lib/core/constants/constants.dart
```

### **Step 2: Update Base URL**
```dart
// Change this line to your preferred URL
static String get baseUrl {
  return androidBaseUrl; // or iosBaseUrl or deviceBaseUrl
}
```

### **Step 3: Restart App**
```bash
# Hot reload won't work for constant changes
flutter run
```

## 📋 Configuration Checklist

- [ ] Backend is running on port 8000
- [ ] Correct IP address is configured
- [ ] Health endpoint responds with status "ok"
- [ ] App can connect to backend
- [ ] AI task creation works

## 🚀 Next Steps

Once configured:
1. **Test AI Task Creation** in your app
2. **Verify Task Creation** works end-to-end
3. **Check Error Handling** with network issues
4. **Test on Different Devices** if needed

---

**💡 Pro Tip**: Use the connection status indicator in the AI Task modal to verify your configuration is working correctly!

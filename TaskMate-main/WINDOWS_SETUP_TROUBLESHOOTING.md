# 🪟 Windows Setup Troubleshooting Guide

## ❌ **Supabase CLI Installation Issues**

### **Problem**: `npm install -g supabase` fails
**Error**: "Installing Supabase CLI as a global module is not supported"

### **Solution**: Use Windows Package Manager
```bash
# Method 1: Windows Package Manager (Recommended)
winget install Supabase.CLI

# Method 2: Chocolatey (if you have it installed)
choco install supabase

# Method 3: Manual Download
# 1. Go to: https://github.com/supabase/cli/releases
# 2. Download: supabase_windows_amd64.exe
# 3. Rename to: supabase.exe
# 4. Place in: C:\Windows\System32\ or add to PATH
```

## 🔧 **Alternative: Skip Supabase CLI for Now**

If you don't need to deploy Edge Functions immediately:

1. **Focus on running the app first**
2. **Edge Functions are already deployed** in the project
3. **You can still test push notifications** without CLI

## 🚀 **Quick Setup Without Supabase CLI**

```bash
# 1. Clone and setup
git clone <your-repo-url>
cd TaskMate-main
flutter pub get

# 2. Create .env file
copy env.example .env

# 3. Get google-services.json from team lead
# 4. Place in: android/app/google-services.json

# 5. Run the app
flutter run
```

## 🔍 **Common Windows Issues**

### **Issue 1**: Flutter not found
```bash
# Add Flutter to PATH
# 1. Open System Properties → Environment Variables
# 2. Add Flutter SDK path to PATH
# 3. Restart terminal
```

### **Issue 2**: Android SDK not found
```bash
# Set ANDROID_HOME environment variable
# 1. Open System Properties → Environment Variables
# 2. Add new: ANDROID_HOME = C:\Users\YourUser\AppData\Local\Android\Sdk
# 3. Add to PATH: %ANDROID_HOME%\platform-tools
```

### **Issue 3**: Permission denied
```bash
# Run PowerShell as Administrator
# Right-click PowerShell → Run as Administrator
```

## 📱 **Test Push Notifications (No CLI Needed)**

1. **Run the app**: `flutter run`
2. **Sign in** to the app
3. **Create a task** with reminder
4. **Wait for notification** (test mode: 5 seconds)
5. **Check OneSignal dashboard** - your device should appear

## 🆘 **Still Having Issues?**

1. **Check Flutter doctor**: `flutter doctor -v`
2. **Verify Android setup**: `flutter doctor --android-licenses`
3. **Clear Flutter cache**: `flutter clean && flutter pub get`
4. **Ask your team lead** for help

## ✅ **Success Checklist**

- [ ] Flutter SDK installed and in PATH
- [ ] Android Studio with Android SDK
- [ ] Project cloned and dependencies installed
- [ ] `.env` file created
- [ ] `google-services.json` in place
- [ ] App runs without errors
- [ ] Push notifications working

---

**🎯 Goal**: Get the app running with push notifications, CLI can be added later!



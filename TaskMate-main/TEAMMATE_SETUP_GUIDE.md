# 🚀 TaskMate Setup Guide for Teammates

## 📋 **Prerequisites**
- Flutter SDK (3.3.0 or higher)
- Android Studio / Xcode
- Git
- Windows Package Manager (winget) or Chocolatey (for Supabase CLI)

## 🔧 **Step 1: Project Setup**

### Clone and Install
```bash
git clone <your-repository-url>
cd TaskMate-main
flutter pub get
```

## 🔑 **Step 2: Environment Configuration**

### Create Environment File
1. Copy `env.example` to `.env`
2. Fill in the values (they're already correct in the example)

```bash
cp env.example .env
```

**Your .env file should contain:**
```
SUPABASE_URL=https://zipxfbleyssjmevkicrm.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InppcHhmYmxleXNzam1ldmtpY3JtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NDY2OTgsImV4cCI6MjA3MDIyMjY5OH0.AisljHcyHbZujvPdwCtRKKpJ3LBaBUTnYsswZjn3G34
ONESIGNAL_APP_ID=703bd8e3-08be-4f1f-b706-299651407f5a
```

## 🔥 **Step 3: Firebase Configuration**

### Download google-services.json
1. Ask your team lead for the `google-services.json` file
2. Place it in: `android/app/google-services.json`
3. **Firebase Project ID**: `taskmate-5b7e4`

## 📱 **Step 4: OneSignal Setup**

### OneSignal Dashboard Access
- **App ID**: `703bd8e3-08be-4f1f-b706-299651407f5a`
- Ask your team lead to add you as a team member
- Or get the dashboard login credentials

### Verify Configuration
- Go to OneSignal Dashboard
- Check that your device appears in "Audience" after running the app
- Verify FCM settings are configured

## 🗄️ **Step 5: Supabase Access**

### Project Details
- **URL**: `https://zipxfbleyssjmevkicrm.supabase.co`
- **Project Ref**: `zipxfbleyssjmevkicrm`

### Edge Functions Access
```bash
# Install Supabase CLI (choose one method)

# Method 1: Using Windows Package Manager (recommended for Windows)
winget install Supabase.CLI

# Method 2: Using Chocolatey
choco install supabase

# Method 3: Download from GitHub releases
# Go to: https://github.com/supabase/cli/releases
# Download the latest Windows executable

# After installation, login to the project
supabase login
supabase link --project-ref zipxfbleyssjmevkicrm

# Deploy functions (if needed)
supabase functions deploy schedule_task_reminder
```

## 🧪 **Step 6: Testing Push Notifications**

### Run the App
```bash
flutter run
```

### Test Device Registration
1. Open the app and sign in
2. Check Flutter console for OneSignal initialization logs
3. Verify device appears in OneSignal dashboard

### Test Push Notification
1. Create a task with reminder
2. Check if notification appears
3. Verify in OneSignal delivery logs

## 🔍 **Troubleshooting**

### Common Issues

#### 1. OneSignal Player ID is Empty
- Check internet connection
- Verify OneSignal App ID is correct
- Clear app data and reinstall
- Check Android permissions

#### 2. Push Notifications Not Working
- Verify device is registered in OneSignal
- Check notification permissions in device settings
- Verify FCM configuration in OneSignal

#### 3. Supabase Connection Issues
- Check internet connection
- Verify Supabase URL and anon key
- Check if Supabase project is active

### Debug Steps
1. **Check Flutter logs** for OneSignal initialization
2. **Verify OneSignal dashboard** for device registration
3. **Check Edge Function logs** for API calls
4. **Test direct from OneSignal** to isolate issues

## 📱 **Platform-Specific Notes**

### Android
- Package name: `com.example.taskmate`
- Permissions already configured
- Uses the same `google-services.json`

### iOS (if needed)
- Bundle identifier should match your team lead's
- Push notification capabilities enabled
- Provisioning profile required

## 🚨 **Important Notes**

1. **Never commit `.env` file** to version control
2. **Use the same Firebase project** for FCM
3. **OneSignal App ID must match** exactly
4. **Supabase credentials are shared** across the team
5. **Edge Functions** need to be deployed to the same project

## 📞 **Support**

If you encounter issues:
1. Check this guide first
2. Review the main `PUSH_NOTIFICATIONS_IMPLEMENTATION.md`
3. Ask your team lead for help
4. Check OneSignal and Supabase documentation

## ✅ **Verification Checklist**

- [ ] Project cloned and dependencies installed
- [ ] `.env` file created with correct values
- [ ] `google-services.json` placed in correct location
- [ ] OneSignal dashboard access granted
- [ ] Supabase project linked
- [ ] App runs without errors
- [ ] Device appears in OneSignal dashboard
- [ ] Push notification test successful

---

**🎯 Goal**: Your teammate should be able to run the app and receive push notifications using the same infrastructure as you.

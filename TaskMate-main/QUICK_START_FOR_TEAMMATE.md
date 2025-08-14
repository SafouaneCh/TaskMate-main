# 🚀 Quick Start for Teammate

## ⚡ **5-Minute Setup**

### 1. **Clone & Setup**
```bash
git clone <your-repo-url>
cd TaskMate-main
flutter pub get
```

### 2. **Environment Setup**
```bash
# Copy environment file
copy env.example .env
```

### 3. **Firebase Setup**
- Get `google-services.json` from your team lead
- Place it in: `android/app/google-services.json`

### 4. **Run the App**
```bash
flutter run
```

## 🔑 **What You Get**

✅ **Same Supabase Database** - All data shared  
✅ **Same OneSignal Push Notifications** - App ID: `703bd8e3-08be-4f1f-b706-299651407f5a`  
✅ **Same Firebase Project** - Project ID: `taskmate-5b7e4`  
✅ **Working Push Notifications** - Test by creating a task with reminder  

## 📱 **Test Push Notifications**

1. **Sign in** to the app
2. **Create a task** with reminder
3. **Wait for notification** (test mode: 5 seconds)
4. **Check OneSignal dashboard** - your device should appear

## 🆘 **Need Help?**

- **Full Guide**: `TEAMMATE_SETUP_GUIDE.md`
- **Windows Issues**: `WINDOWS_SETUP_TROUBLESHOOTING.md`
- **Push Notifications**: `PUSH_NOTIFICATIONS_IMPLEMENTATION.md`
- **Ask your team lead** for credentials

---

**🎯 Goal**: Run the same app with working push notifications in under 10 minutes!

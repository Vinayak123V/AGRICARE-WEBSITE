# Logo Setup Instructions

## 📸 Save Your Logo

To add the AgriCare logo to your app:

### Step 1: Save the Logo Image

1. **Right-click** on the logo image you uploaded
2. **Save the image as:**
   - Filename: `logo.png`
   - Location: `c:\ANNADATHA\android\ios\lib\assets\images\logo.png`
3. Make sure the file is named **exactly** `logo.png`

### Step 2: Verify File Location

The logo should be located at:
```
c:\ANNADATHA\android\ios\lib\assets\images\logo.png
```

### Step 3: Run the App

```bash
flutter run -d chrome
```

The logo will automatically appear in the top-left corner of your app!

---

## 🎨 Logo Specifications

- **Recommended Size:** 512x512 pixels
- **Format:** PNG with transparent background (preferred) or JPG
- **Aspect Ratio:** Square (1:1)
- **File Size:** Keep under 500KB for best performance

---

## ✅ Features

- ✅ Logo displays in app header
- ✅ Fallback icon if logo not found
- ✅ Responsive sizing
- ✅ Professional appearance
- ✅ Works on all platforms

---

## 🔧 Troubleshooting

**Logo not showing?**
1. Check file path is correct: `assets/images/logo.png`
2. Verify pubspec.yaml includes assets
3. Run `flutter clean` then `flutter pub get`
4. Restart the app

**Logo too large/small?**
- Adjust size in `lib/widgets/header.dart` (width/height properties)

---

## 📝 Alternative: Use a Different Image

You can use any image you want! Just name it `logo.png` and place it in `assets/images/`

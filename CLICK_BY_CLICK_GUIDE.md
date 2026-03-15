# 🖱️ Click-by-Click Guide to Fix Google Maps

## Follow these exact steps. Don't skip any!

---

## Step 1: Open Google Cloud Console

**Action:** Open your web browser and go to:
```
https://console.cloud.google.com/
```

**What you'll see:** Google Cloud Console homepage

**Next:** Click on the project selector (top left, next to "Google Cloud")

**Select:** `agricare-c9542` (your project)

---

## Step 2: Enable Maps JavaScript API

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/apis/library/maps-backend.googleapis.com
```

**What you'll see:** Maps JavaScript API page

**Click:** The blue "ENABLE" button

**Wait:** Until you see "API enabled" message (5-10 seconds)

**✅ Done!** API 1 of 5 enabled

---

## Step 3: Enable Maps SDK for Android

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/apis/library/maps-android-backend.googleapis.com
```

**What you'll see:** Maps SDK for Android page

**Click:** The blue "ENABLE" button

**Wait:** Until you see "API enabled" message

**✅ Done!** API 2 of 5 enabled

---

## Step 4: Enable Directions API

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/apis/library/directions-backend.googleapis.com
```

**What you'll see:** Directions API page

**Click:** The blue "ENABLE" button

**Wait:** Until you see "API enabled" message

**✅ Done!** API 3 of 5 enabled

---

## Step 5: Enable Geocoding API

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/apis/library/geocoding-backend.googleapis.com
```

**What you'll see:** Geocoding API page

**Click:** The blue "ENABLE" button

**Wait:** Until you see "API enabled" message

**✅ Done!** API 4 of 5 enabled

---

## Step 6: Enable Places API

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/apis/library/places-backend.googleapis.com
```

**What you'll see:** Places API page

**Click:** The blue "ENABLE" button

**Wait:** Until you see "API enabled" message

**✅ Done!** API 5 of 5 enabled - All APIs enabled!

---

## Step 7: Enable Billing

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/billing
```

**What you'll see:** Billing page

**If you see "No billing account":**
1. Click "Link a billing account"
2. Click "Create billing account"
3. Fill in your details
4. Add payment method (credit/debit card)
5. Click "Submit and enable billing"

**If you already have a billing account:**
1. Just verify it's linked to your project
2. You should see "Billing account: [account name]"

**Note:** You get $200 free credit per month. You won't be charged for development usage.

**✅ Done!** Billing enabled

---

## Step 8: Remove API Restrictions (Temporary - For Testing)

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/apis/credentials
```

**What you'll see:** Credentials page with list of API keys

**Find:** Your API key (should show `AIzaSyBSS-aWY_K3C0Y-BJgQ4Lb-AdAxdPrjgZc` or similar)

**Click:** The pencil icon (✏️) next to your API key

**What you'll see:** Edit API key page

**Scroll down to "Application restrictions":**
- Click the radio button: ○ **None**

**Scroll down to "API restrictions":**
- Click the radio button: ○ **Don't restrict key**

**Click:** The blue "SAVE" button at the bottom

**✅ Done!** API restrictions removed (for testing)

---

## Step 9: Wait (Important!)

**Action:** Wait 10 minutes

**Why:** Google needs time to activate the APIs across their servers

**What to do while waiting:**
- Get a coffee ☕
- Check your email 📧
- Stretch 🤸
- Just wait...

**⏰ Set a timer for 10 minutes**

---

## Step 10: Clean and Rebuild App

**Action:** Open your terminal/command prompt

**Run these commands one by one:**

```bash
flutter clean
```
**Wait:** Until it says "Deleting build..."

```bash
flutter pub get
```
**Wait:** Until it says "Got dependencies!"

```bash
flutter run
```
**Wait:** Until app launches on your device/emulator

**✅ Done!** App is rebuilt with fresh configuration

---

## Step 11: Test Live Tracking

**In the app:**

1. **Tap:** "My Bookings" (bottom navigation)
2. **Tap:** Any booking in the list
3. **Tap:** "Live Tracking" button (green button)
4. **If prompted:** Grant location permission → Tap "Allow"
5. **Wait:** 2-3 seconds for map to load

**What you should see:**
- ✅ Google Map (no error!)
- ✅ Tractor marker (provider)
- ✅ Home marker (customer)
- ✅ Blue route line
- ✅ ETA and distance
- ✅ Provider info card

**If you still see the error:**
- Wait another 5 minutes (APIs might still be activating)
- Try closing and reopening the app
- Check Step 12 below

---

## Step 12: Verify APIs Are Enabled

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/apis/dashboard
```

**What you should see:**
- A list of enabled APIs
- Should include all 5 APIs you enabled
- Each should show "Enabled" status
- May show usage graphs (even if zero)

**If you don't see all 5 APIs:**
- Go back to Steps 2-6 and enable them again
- Make sure you're in the correct project (agricare-c9542)

---

## Step 13: Check Billing Status

**Action:** Copy and paste this URL in your browser:
```
https://console.cloud.google.com/billing
```

**What you should see:**
- "Billing account: [your account name]"
- Status: "Active"
- Free tier: "$200 remaining" or similar

**If billing is not enabled:**
- Go back to Step 7
- Make sure you completed all substeps

---

## Troubleshooting

### Still seeing error after 15 minutes?

**Try this:**
1. Close the app completely
2. Clear app cache (in device settings)
3. Reopen the app
4. Try Live Tracking again

### Error says "API not activated"?

**Solution:**
- Go to https://console.cloud.google.com/apis/dashboard
- Verify all 5 APIs are listed
- If not, enable them again (Steps 2-6)

### Error says "Billing not enabled"?

**Solution:**
- Go to https://console.cloud.google.com/billing
- Verify billing account is linked
- If not, complete Step 7 again

### Map shows gray screen?

**Solution:**
- Check internet connection
- Verify location permission is granted
- Wait another 5 minutes

---

## Success Checklist

Before declaring success, verify:

- [ ] All 5 APIs show "Enabled" in dashboard
- [ ] Billing account is linked and active
- [ ] API restrictions are set to "None" (temporarily)
- [ ] Waited at least 10 minutes after enabling APIs
- [ ] Ran `flutter clean && flutter pub get && flutter run`
- [ ] Location permission granted in app
- [ ] Map loads without error
- [ ] Markers and route are visible

---

## Time Tracking

| Step | Time | Status |
|------|------|--------|
| 1. Open Console | 1 min | ⬜ |
| 2-6. Enable APIs | 5 min | ⬜ |
| 7. Enable Billing | 3 min | ⬜ |
| 8. Remove Restrictions | 2 min | ⬜ |
| 9. Wait | 10 min | ⬜ |
| 10. Rebuild App | 2 min | ⬜ |
| 11. Test | 2 min | ⬜ |
| **Total** | **25 min** | |

---

## Quick Reference URLs

Copy these URLs - you'll need them:

```
Console Home:
https://console.cloud.google.com/

Enable APIs:
https://console.cloud.google.com/apis/library

Check API Status:
https://console.cloud.google.com/apis/dashboard

Enable Billing:
https://console.cloud.google.com/billing

Configure API Key:
https://console.cloud.google.com/apis/credentials
```

---

## Final Notes

- **Don't skip steps** - Each one is necessary
- **Wait the full 10 minutes** - APIs need time to activate
- **Check each URL** - Make sure you're in the right project
- **Verify billing** - This is required even for free tier
- **Be patient** - It will work after following all steps!

---

**You've got this! Follow each step carefully and your Live Tracking will work perfectly!** 🚀

Good luck! 💪

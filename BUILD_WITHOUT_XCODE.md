# Building IPA Without Xcode (100% Free Options)

Yes! You can build the IPA without having Xcode installed. Here are the best options:

## Option 1: GitHub Actions (FREE - Recommended) ⭐

This is the easiest and completely free option. GitHub provides free macOS runners for public repositories.

### Steps:

1. **Create a GitHub repository** (make it public for free builds):
   ```bash
   cd OllamaChat
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/ollama-chat-ios.git
   git push -u origin main
   ```

2. **Push the code to GitHub**

3. **Go to Actions tab** in your GitHub repository

4. **Run the workflow**:
   - Click on "Build IPA" workflow
   - Click "Run workflow"
   - Wait 5-10 minutes for the build to complete

5. **Download the IPA**:
   - Go to the completed workflow run
   - Scroll down to "Artifacts"
   - Download "OllamaChat-IPA"
   - Extract the ZIP file to get the `.ipa` file

6. **Sideload the IPA** using AltStore, Sideloadly, or similar tool

### Note:
- For **private repos**, GitHub Actions is free but has limited minutes (2000/month)
- For **public repos**, it's completely free with unlimited minutes
- The build takes about 5-10 minutes

---

## Option 2: Use a Cloud Mac Service

### MacStadium / MacinCloud
- Paid service (~$20-50/month)
- Rent a Mac in the cloud
- Access via Remote Desktop
- Build using Xcode or command line

### GitHub Codespaces (Limited)
- Currently doesn't support macOS
- Only Linux/Windows

---

## Option 3: Use a Friend's Mac

If you know someone with a Mac:

1. **Send them the project folder**
2. **They run these commands**:
   ```bash
   cd OllamaChat
   xcodebuild -project OllamaChat.xcodeproj \
     -scheme OllamaChat \
     -configuration Release \
     -archivePath ./build/OllamaChat.xcarchive \
     CODE_SIGN_IDENTITY="" \
     CODE_SIGNING_REQUIRED=NO
   
   xcodebuild -exportArchive \
     -archivePath ./build/OllamaChat.xcarchive \
     -exportPath ./build \
     -exportOptionsPlist exportOptions.plist
   ```
3. **Get the IPA** from the `build` folder

---

## Option 4: Use CI/CD Services (Free Tiers)

### Codemagic
- Free tier: 500 build minutes/month
- Supports iOS builds
- Sign up at codemagic.io
- Connect your GitHub repo
- Configure build settings

### AppCircle
- Free tier available
- iOS build support
- Connect GitHub repo

### Bitrise
- Free tier: 200 builds/month
- iOS build support

---

## Option 5: Command Line Build Script (If You Have Access to macOS)

If you get access to any macOS machine (even temporarily), you can use this script:

```bash
#!/bin/bash
# build-ipa.sh

cd OllamaChat

# Clean
xcodebuild clean -project OllamaChat.xcodeproj -scheme OllamaChat

# Archive (unsigned, for sideloading)
xcodebuild archive \
  -project OllamaChat.xcodeproj \
  -scheme OllamaChat \
  -configuration Release \
  -archivePath ./build/OllamaChat.xcarchive \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# Export IPA
xcodebuild -exportArchive \
  -archivePath ./build/OllamaChat.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist exportOptions.plist \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

echo "IPA built at: ./build/OllamaChat.ipa"
```

---

## Recommended: GitHub Actions

**I recommend GitHub Actions** because:
- ✅ Completely free for public repos
- ✅ No Mac needed
- ✅ Automatic builds
- ✅ Easy to use
- ✅ IPA ready to download

Just push your code to GitHub and the workflow will build it automatically!

---

## After Building the IPA

1. **Download the IPA** from GitHub Actions artifacts
2. **Use a sideloading tool**:
   - **AltStore** (free, requires AltServer on Windows/Mac)
   - **Sideloadly** (free, Windows/Mac)
   - **3uTools** (Windows)
   - **iMazing** (paid, but reliable)

3. **Install on your iPhone**:
   - Connect iPhone via USB
   - Open sideloading tool
   - Drag and drop the IPA
   - Follow the installation prompts
   - Trust the developer certificate on your iPhone (Settings > General > VPN & Device Management)

---

## Troubleshooting

### GitHub Actions Build Fails
- Make sure the Xcode project file is correct
- Check that all Swift files are included
- Review the build logs in GitHub Actions

### IPA Won't Install
- Make sure you're using a recent sideloading tool
- Check that your iPhone is trusted
- Try a different sideloading method

### Code Signing Errors
- The workflow uses unsigned builds (for sideloading)
- If you need signed builds, you'll need an Apple Developer account ($99/year)

---

## Quick Start (GitHub Actions)

1. Push code to GitHub (public repo)
2. Go to Actions tab
3. Run "Build IPA" workflow
4. Download IPA from artifacts
5. Sideload to iPhone

That's it! No Xcode needed! 🎉


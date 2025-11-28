# Ollama Chat iOS App

A native iOS chat application that connects to your local Ollama instance running on Windows (or any machine on your network).

## Features

- ✅ Chat with your local Ollama models
- ✅ Select from available Ollama models
- ✅ Edit sent messages
- ✅ Upload images (supports vision models)
- ✅ Upload files
- ✅ Web search integration
- ✅ Modern SwiftUI interface
- ✅ Settings to configure Ollama server URL

## Setup Instructions

### 1. Configure Ollama on Windows

Make sure Ollama is running and accessible on your network:

1. Install Ollama on your Windows machine: https://ollama.ai
2. Start Ollama (it runs on `http://localhost:11434` by default)
3. Find your Windows machine's local IP address:
   - Open PowerShell and run: `ipconfig`
   - Look for "IPv4 Address" under your active network adapter
   - Example: `192.168.1.100`

### 2. Make Ollama Accessible on Network

By default, Ollama only listens on localhost. To make it accessible from your iPhone:

**Option A: Use ngrok (easiest for testing)**
```bash
ngrok http 11434
```
This will give you a public URL you can use.

**Option B: Configure Ollama to listen on network (Windows)**

1. Set environment variable:
   ```powershell
   $env:OLLAMA_HOST="0.0.0.0:11434"
   ```
2. Restart Ollama service

**Option C: Use Windows Firewall port forwarding**
- Allow port 11434 through Windows Firewall
- Use your Windows machine's local IP address

### 3. Build and Install the iOS App

#### Option 1: Build with GitHub Actions (NO XCODE NEEDED!) ⭐ Recommended

**This is the easiest way - completely free and no Mac required!**

1. Create a GitHub account (if you don't have one)
2. Create a new **public** repository (public = free unlimited builds)
3. Push this project to GitHub:
   ```bash
   cd OllamaChat
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/ollama-chat-ios.git
   git push -u origin main
   ```
4. Go to your repository on GitHub
5. Click the **Actions** tab
6. Click **"Build IPA"** workflow
7. Click **"Run workflow"** button
8. Wait 5-10 minutes for the build
9. Download the IPA from the **Artifacts** section
10. Sideload to your iPhone using AltStore, Sideloadly, etc.

**See `BUILD_WITHOUT_XCODE.md` for detailed instructions and other options!**

#### Option 2: Build with Xcode (If you have a Mac)

1. Open `OllamaChat.xcodeproj` in Xcode
2. Connect your iPhone via USB
3. Select your iPhone as the build target
4. Click "Run" (or press Cmd+R)
5. Trust the developer certificate on your iPhone if prompted

#### Option 3: Build IPA with Xcode for Sideloading

1. Open the project in Xcode
2. Select "Any iOS Device" as the target
3. Go to Product > Archive
4. Once archived, click "Distribute App"
5. Choose "Ad Hoc" or "Development" distribution
6. Export the IPA file
7. Use AltStore, Sideloadly, or similar tool to install on your iPhone

### 4. Configure the App

1. Open the app on your iPhone
2. Go to Settings tab
3. Enter your Ollama URL:
   - Local network: `http://192.168.1.100:11434` (replace with your Windows IP)
   - ngrok: `https://your-ngrok-url.ngrok.io`
4. Tap "Test Connection"
5. Select a model from the list
6. Start chatting!

## Usage

### Chatting
- Type messages and tap send
- Messages are sent to your selected Ollama model
- Conversation history is maintained

### Editing Messages
- Tap the pencil icon on any of your messages
- Edit the text and send again

### Uploading Images
- Tap the photo icon
- Select images from your library
- Images are sent to the model (if it supports vision)

### Uploading Files
- Tap the document icon
- Select a file
- Files are attached to messages

### Web Search
- Toggle the search icon before sending
- The app will search the web and include results in the context
- Useful for getting current information

## Troubleshooting

### Can't Connect to Ollama
1. Make sure Ollama is running on your Windows machine
2. Check that the IP address is correct
3. Ensure both devices are on the same network
4. Try pinging the Windows machine from your iPhone's network settings
5. Check Windows Firewall settings

### No Models Available
1. Make sure you have downloaded models in Ollama:
   ```bash
   ollama pull llama2
   ollama pull mistral
   ```
2. Tap "Refresh Models" in Settings

### Images Not Working
- Make sure your selected model supports vision (e.g., `llava`, `bakllava`)
- Check that images are being sent (they appear in the message preview)

## Requirements

- iOS 17.0 or later
- iPhone or iPad
- Ollama running on a machine accessible from your network
- Same Wi-Fi network (for local connections)

## Notes

- The app stores settings locally on your device
- Conversation history is kept in memory (cleared when app closes)
- For production use, consider adding conversation persistence
- Web search uses DuckDuckGo API (free, no key required)

## License

This is a personal project. Use as you wish!


# Quick Guide: Push to GitHub

✅ **Done so far:**
- Git repository initialized
- All files committed
- Ready to push!

## Next Steps:

### 1. Create GitHub Repository

1. Go to: **https://github.com/new**
2. **Repository name:** `ollama-chat-ios` (or any name you prefer)
3. **Make it PUBLIC** ⚠️ (required for free GitHub Actions builds)
4. **DO NOT** check:
   - ❌ Add a README file
   - ❌ Add .gitignore
   - ❌ Choose a license
5. Click **"Create repository"**

### 2. Push Your Code

After creating the repository, GitHub will show you commands. Use these (replace YOUR_USERNAME):

```powershell
cd "D:\Documents\ai 2\aibot\OllamaChat"
git remote add origin https://github.com/YOUR_USERNAME/ollama-chat-ios.git
git push -u origin main
```

**OR** if you have GitHub CLI installed:

```powershell
gh repo create ollama-chat-ios --public --source=. --remote=origin --push
```

### 3. If Authentication is Required

**Option A: Use GitHub CLI (Easiest)**
```powershell
# Install GitHub CLI
winget install GitHub.cli

# Login
gh auth login
```

**Option B: Use Personal Access Token**
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (full control of private repositories)
4. Copy the token
5. Use it in the remote URL:
```powershell
git remote set-url origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/ollama-chat-ios.git
git push -u origin main
```

### 4. Build the IPA

Once pushed:

1. Go to your repository on GitHub
2. Click the **"Actions"** tab
3. You'll see **"Build IPA"** workflow
4. Click **"Run workflow"** → **"Run workflow"** button
5. Wait 5-10 minutes
6. Download the IPA from **Artifacts** section

---

## Quick Commands (Copy & Paste)

Replace `YOUR_USERNAME` with your GitHub username:

```powershell
cd "D:\Documents\ai 2\aibot\OllamaChat"
git remote add origin https://github.com/YOUR_USERNAME/ollama-chat-ios.git
git push -u origin main
```

If remote already exists, use:
```powershell
git remote set-url origin https://github.com/YOUR_USERNAME/ollama-chat-ios.git
git push -u origin main
```

---

**That's it!** Once you push, the GitHub Actions will automatically build your IPA! 🎉


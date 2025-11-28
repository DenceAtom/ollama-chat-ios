#!/bin/bash
# Bash script to set up GitHub repository for OllamaChat
# Run this script to automatically push your code to GitHub

echo "=== OllamaChat GitHub Setup ==="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "✗ Git is not installed. Please install Git first."
    exit 1
fi

echo "✓ Git found: $(git --version)"
echo ""

# Navigate to script directory
cd "$(dirname "$0")"

echo "Current directory: $(pwd)"
echo ""

# Check if already a git repository
if [ -d .git ]; then
    echo "✓ Git repository already initialized"
else
    echo "Initializing git repository..."
    git init
    echo "✓ Git repository initialized"
fi

# Check if .gitignore exists, if not create one
if [ ! -f .gitignore ]; then
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Xcode
build/
*.xcworkspace
!default.xcworkspace
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
*.xcuserstate
*.xcuserdatad
.DS_Store

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Archives
*.ipa
*.dSYM.zip
*.dSYM

# User-specific files
*.swp
*~.nib
EOF
    echo "✓ .gitignore created"
fi

# Add all files
echo ""
echo "Adding files to git..."
git add .
echo "✓ Files added"

# Check if there are changes to commit
if [ -n "$(git status --porcelain)" ]; then
    echo ""
    echo "Committing changes..."
    git commit -m "Initial commit: OllamaChat iOS app"
    echo "✓ Changes committed"
else
    echo ""
    echo "No changes to commit"
fi

# Check if remote already exists
if git remote get-url origin &> /dev/null; then
    echo ""
    echo "Remote already configured: $(git remote get-url origin)"
    read -p "Use existing remote? (y/n) " useExisting
    if [ "$useExisting" != "y" ]; then
        git remote remove origin
    fi
fi

if ! git remote get-url origin &> /dev/null; then
    echo ""
    echo "=== GitHub Repository Setup ==="
    echo ""
    echo "You need to create a GitHub repository first:"
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: ollama-chat-ios (or any name you want)"
    echo "3. Make it PUBLIC (required for free GitHub Actions)"
    echo "4. DO NOT initialize with README, .gitignore, or license"
    echo "5. Click 'Create repository'"
    echo ""
    
    read -p "Enter your GitHub username: " githubUsername
    read -p "Enter repository name (default: ollama-chat-ios): " repoName
    if [ -z "$repoName" ]; then
        repoName="ollama-chat-ios"
    fi
    
    repoUrl="https://github.com/$githubUsername/$repoName.git"
    
    echo ""
    echo "Adding remote: $repoUrl"
    git remote add origin "$repoUrl"
    echo "✓ Remote added"
fi

# Get current branch name
branch=$(git branch --show-current)
if [ -z "$branch" ]; then
    branch="main"
    git branch -M main
fi

echo ""
echo "=== Ready to Push ==="
echo ""
echo "Current branch: $branch"
echo "Remote: $(git remote get-url origin)"
echo ""

read -p "Push to GitHub now? (y/n) " push
if [ "$push" = "y" ]; then
    echo ""
    echo "Pushing to GitHub..."
    
    if git push -u origin "$branch"; then
        echo ""
        echo "✓ Successfully pushed to GitHub!"
        echo ""
        echo "=== Next Steps ==="
        echo "1. Go to your repository on GitHub"
        echo "2. Click the 'Actions' tab"
        echo "3. Click 'Build IPA' workflow"
        echo "4. Click 'Run workflow' button"
        echo "5. Wait 5-10 minutes for the build"
        echo "6. Download the IPA from Artifacts"
        echo ""
        echo "Repository URL: $(git remote get-url origin)"
    else
        echo ""
        echo "✗ Push failed. Common issues:"
        echo "  - Authentication required (use GitHub CLI or Personal Access Token)"
        echo "  - Repository doesn't exist yet"
        echo ""
        echo "To fix authentication:"
        echo "1. Install GitHub CLI or use:"
        echo "   gh auth login"
        echo "2. Or use a Personal Access Token:"
        echo "   git remote set-url origin https://YOUR_TOKEN@github.com/USERNAME/REPO.git"
    fi
else
    echo ""
    echo "To push manually, run:"
    echo "  git push -u origin $branch"
    echo ""
    echo "If you need to set up authentication:"
    echo "  gh auth login  (if using GitHub CLI)"
    echo "  Or use: git remote set-url origin https://TOKEN@github.com/USER/REPO.git"
fi

echo ""
echo "Done!"


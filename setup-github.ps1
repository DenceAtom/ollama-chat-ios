# PowerShell script to set up GitHub repository for OllamaChat
# Run this script to automatically push your code to GitHub

Write-Host "=== OllamaChat GitHub Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Host "✓ Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Navigate to OllamaChat directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray
Write-Host ""

# Check if already a git repository
if (Test-Path .git) {
    Write-Host "✓ Git repository already initialized" -ForegroundColor Green
} else {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
}

# Check if .gitignore exists, if not create one
if (-not (Test-Path .gitignore)) {
    Write-Host "Creating .gitignore..." -ForegroundColor Yellow
    @"
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
"@ | Out-File -FilePath .gitignore -Encoding UTF8
    Write-Host "✓ .gitignore created" -ForegroundColor Green
}

# Add all files
Write-Host ""
Write-Host "Adding files to git..." -ForegroundColor Yellow
git add .
Write-Host "✓ Files added" -ForegroundColor Green

# Check if there are changes to commit
$status = git status --porcelain
if ($status) {
    Write-Host ""
    Write-Host "Committing changes..." -ForegroundColor Yellow
    git commit -m "Initial commit: OllamaChat iOS app"
    Write-Host "✓ Changes committed" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "No changes to commit" -ForegroundColor Gray
}

# Check if remote already exists
$remote = git remote get-url origin 2>$null
if ($remote) {
    Write-Host ""
    Write-Host "Remote already configured: $remote" -ForegroundColor Yellow
    $useExisting = Read-Host "Use existing remote? (y/n)"
    if ($useExisting -ne "y") {
        git remote remove origin
        $remote = $null
    }
}

if (-not $remote) {
    Write-Host ""
    Write-Host "=== GitHub Repository Setup ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You need to create a GitHub repository first:" -ForegroundColor Yellow
    Write-Host "1. Go to https://github.com/new" -ForegroundColor White
    Write-Host "2. Repository name: ollama-chat-ios (or any name you want)" -ForegroundColor White
    Write-Host "3. Make it PUBLIC (required for free GitHub Actions)" -ForegroundColor Yellow
    Write-Host "4. DO NOT initialize with README, .gitignore, or license" -ForegroundColor Yellow
    Write-Host "5. Click 'Create repository'" -ForegroundColor White
    Write-Host ""
    
    $githubUsername = Read-Host "Enter your GitHub username"
    $repoName = Read-Host "Enter repository name (default: ollama-chat-ios)"
    if ([string]::IsNullOrWhiteSpace($repoName)) {
        $repoName = "ollama-chat-ios"
    }
    
    $repoUrl = "https://github.com/$githubUsername/$repoName.git"
    
    Write-Host ""
    Write-Host "Adding remote: $repoUrl" -ForegroundColor Yellow
    git remote add origin $repoUrl
    Write-Host "✓ Remote added" -ForegroundColor Green
}

# Get current branch name
$branch = git branch --show-current
if (-not $branch) {
    $branch = "main"
    git branch -M main
}

Write-Host ""
Write-Host "=== Ready to Push ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Current branch: $branch" -ForegroundColor Gray
Write-Host "Remote: $(git remote get-url origin)" -ForegroundColor Gray
Write-Host ""

$push = Read-Host "Push to GitHub now? (y/n)"
if ($push -eq "y") {
    Write-Host ""
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    
    # Try to push, handle errors
    try {
        git push -u origin $branch
        Write-Host ""
        Write-Host "✓ Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host ""
        Write-Host "=== Next Steps ===" -ForegroundColor Cyan
        Write-Host "1. Go to your repository on GitHub" -ForegroundColor White
        Write-Host "2. Click the 'Actions' tab" -ForegroundColor White
        Write-Host "3. Click 'Build IPA' workflow" -ForegroundColor White
        Write-Host "4. Click 'Run workflow' button" -ForegroundColor White
        Write-Host "5. Wait 5-10 minutes for the build" -ForegroundColor White
        Write-Host "6. Download the IPA from Artifacts" -ForegroundColor White
        Write-Host ""
        Write-Host "Repository URL: $(git remote get-url origin)" -ForegroundColor Cyan
    } catch {
        Write-Host ""
        Write-Host "✗ Push failed. Common issues:" -ForegroundColor Red
        Write-Host "  - Authentication required (use GitHub CLI or Personal Access Token)" -ForegroundColor Yellow
        Write-Host "  - Repository doesn't exist yet" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To fix authentication:" -ForegroundColor Yellow
        Write-Host "1. Install GitHub CLI: winget install GitHub.cli" -ForegroundColor White
        Write-Host "2. Run: gh auth login" -ForegroundColor White
        Write-Host "3. Or use a Personal Access Token:" -ForegroundColor White
        Write-Host "   git remote set-url origin https://YOUR_TOKEN@github.com/USERNAME/REPO.git" -ForegroundColor Gray
    }
} else {
    Write-Host ""
    Write-Host "To push manually, run:" -ForegroundColor Yellow
    Write-Host "  git push -u origin $branch" -ForegroundColor White
    Write-Host ""
    Write-Host "If you need to set up authentication:" -ForegroundColor Yellow
    Write-Host "  gh auth login  (if using GitHub CLI)" -ForegroundColor White
    Write-Host "  Or use: git remote set-url origin https://TOKEN@github.com/USER/REPO.git" -ForegroundColor White
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green


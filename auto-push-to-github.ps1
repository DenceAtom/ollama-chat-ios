# Auto-push to GitHub script
# This will create the repo and push your code automatically

Write-Host "=== Auto-Push to GitHub ===" -ForegroundColor Cyan
Write-Host ""

# Navigate to project directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Try to find gh in common locations or refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$ghPath = Get-Command gh -ErrorAction SilentlyContinue

if (-not $ghPath) {
    Write-Host "GitHub CLI not found in PATH. Trying to locate..." -ForegroundColor Yellow
    $possiblePaths = @(
        "$env:ProgramFiles\GitHub CLI\gh.exe",
        "${env:ProgramFiles(x86)}\GitHub CLI\gh.exe",
        "$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $env:Path += ";$(Split-Path $path)"
            break
        }
    }
}

# Check authentication
Write-Host "Checking GitHub authentication..." -ForegroundColor Yellow
$authStatus = & gh auth status 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "⚠ Not authenticated with GitHub" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You need to authenticate first. Choose method:" -ForegroundColor Cyan
    Write-Host "1. Browser (recommended - opens browser)" -ForegroundColor White
    Write-Host "2. Token (paste a personal access token)" -ForegroundColor White
    Write-Host ""
    $method = Read-Host "Enter choice (1 or 2)"
    
    if ($method -eq "1") {
        Write-Host ""
        Write-Host "Opening browser for authentication..." -ForegroundColor Yellow
        & gh auth login
    } elseif ($method -eq "2") {
        Write-Host ""
        Write-Host "Get a token from: https://github.com/settings/tokens" -ForegroundColor Yellow
        Write-Host "Select scopes: repo (full control)" -ForegroundColor Yellow
        Write-Host ""
        $token = Read-Host "Paste your token here" -AsSecureString
        $tokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
        )
        $tokenPlain | & gh auth login --with-token
    } else {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
    
    # Verify authentication
    $authCheck = & gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Authentication failed. Please try again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "✓ Authenticated with GitHub" -ForegroundColor Green
Write-Host ""

# Get GitHub username
$username = & gh api user -q .login
Write-Host "GitHub username: $username" -ForegroundColor Cyan
Write-Host ""

# Check if remote already exists
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "Remote already exists: $existingRemote" -ForegroundColor Yellow
    $useExisting = Read-Host "Use existing remote? (y/n)"
    if ($useExisting -ne "y") {
        git remote remove origin
        $existingRemote = $null
    }
}

if (-not $existingRemote) {
    # Create repository
    $repoName = "ollama-chat-ios"
    Write-Host "Creating GitHub repository: $repoName" -ForegroundColor Yellow
    Write-Host "(This will be PUBLIC for free GitHub Actions)" -ForegroundColor Gray
    Write-Host ""
    
    $createRepo = Read-Host "Create repository '$repoName'? (y/n)"
    if ($createRepo -eq "y") {
        & gh repo create $repoName --public --source=. --remote=origin --push
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Successfully created repository and pushed code!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Repository URL: https://github.com/$username/$repoName" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "=== Next Steps ===" -ForegroundColor Yellow
            Write-Host "1. Go to: https://github.com/$username/$repoName/actions" -ForegroundColor White
            Write-Host "2. Click 'Build IPA' workflow" -ForegroundColor White
            Write-Host "3. Click 'Run workflow' button" -ForegroundColor White
            Write-Host "4. Wait 5-10 minutes" -ForegroundColor White
            Write-Host "5. Download IPA from Artifacts" -ForegroundColor White
        } else {
            Write-Host ""
            Write-Host "❌ Failed to create repository. Error:" -ForegroundColor Red
            Write-Host "The repository might already exist, or there was an authentication issue." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "You can manually create it at: https://github.com/new" -ForegroundColor Yellow
            Write-Host "Then run: git remote add origin https://github.com/$username/$repoName.git" -ForegroundColor Gray
            Write-Host "And: git push -u origin main" -ForegroundColor Gray
        }
    } else {
        Write-Host "Skipped repository creation." -ForegroundColor Yellow
        Write-Host "You can create it manually at: https://github.com/new" -ForegroundColor Yellow
    }
} else {
    # Just push to existing remote
    Write-Host "Pushing to existing remote..." -ForegroundColor Yellow
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Successfully pushed code!" -ForegroundColor Green
        $repoUrl = git remote get-url origin
        Write-Host "Repository: $repoUrl" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "❌ Push failed. Check your authentication." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green


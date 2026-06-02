# LocoGames — PR Setup Script
# Run this AFTER: gh auth login
#
# Usage:
#   .\setup_pr.ps1 -RepoOwner "your-username"
#   .\setup_pr.ps1 -RepoUrl "https://github.com/username/loco-g"
#
# This script will:
#   1. Set the remote origin
#   2. Push the feature/ride-the-bus-and-i18n branch
#   3. Create a PR to main with the prepared description

param(
    [string]$RepoOwner = "",
    [string]$RepoUrl = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$git = "C:\Program Files\Git\bin\git.exe"
$gh = "C:\Program Files\GitHub CLI\gh.exe"

$repoName = "loco-g"

if (-not (Test-Path $gh)) {
    Write-Host "ERROR: GitHub CLI not found at $gh" -ForegroundColor Red
    exit 1
}

if ($RepoUrl) {
    $remoteUrl = $RepoUrl
} elseif ($RepoOwner) {
    $remoteUrl = "https://github.com/$RepoOwner/$repoName"
} else {
    Write-Host "Please provide -RepoOwner (GitHub username) or -RepoUrl (full URL)" -ForegroundColor Yellow
    Write-Host "Example: .\setup_pr.ps1 -RepoOwner octocat" -ForegroundColor DarkGray
    exit 1
}

Write-Host "Setting remote origin to: $remoteUrl" -ForegroundColor Cyan
& $git remote add origin $remoteUrl 2>$null
& $git remote set-url origin $remoteUrl

Write-Host "Pushing branch feature/ride-the-bus-and-i18n..." -ForegroundColor Cyan
& $git push -u origin feature/ride-the-bus-and-i18n

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Push failed. If the repo doesn't exist yet, create it first:" -ForegroundColor Yellow
    Write-Host "  gh repo create $repoName --public --source=. --remote=origin --push" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Or run this interactive command:" -ForegroundColor Yellow
    Write-Host "  gh repo create $repoName --public --source=. --remote=origin" -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}

Write-Host "Creating Pull Request..." -ForegroundColor Cyan
$prBody = Get-Content ".kilo\pr_body.md" -Raw

& $gh pr create `
    --base main `
    --head feature/ride-the-bus-and-i18n `
    --title "feat: Ride the Bus game + i18n Phase 0.5 completion" `
    --body $prBody

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "PR created successfully!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "PR creation failed. You can create it manually:" -ForegroundColor Yellow
    Write-Host "  gh pr create --base main --head feature/ride-the-bus-and-i18n --title 'feat: Ride the Bus game + i18n Phase 0.5 completion'" -ForegroundColor DarkGray
}

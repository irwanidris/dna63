# DNA63 GitHub Actions Setup Guide

## Overview
This guide walks you through setting up GitHub Actions CI/CD for building DNA63 Android AAB files automatically.

## Prerequisites
- GitHub account
- Repository on GitHub (public or private)

---

## Step 1: Create GitHub Repository

### Option A: Push existing code to GitHub

```bash
# From project root (/data/.openclaw/workspace/dna63/project)
cd /data/.openclaw/workspace/dna63/project

# Initialize git (if not already)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: DNA63 Flutter project"

# Add remote (replace with your GitHub repo URL)
git remote add origin https://github.com/YOUR_USERNAME/dna63.git

# Push to main branch
git push -u origin main
```

### Option B: Using GitHub CLI

```bash
# Install gh CLI first if needed
git push origin main

# Or create repo via CLI
gh repo create dna63 --public --source=. --push
```

---

## Step 2: Configure Repository Secrets (Optional but Recommended)

If your app needs signing for release builds:

1. Go to **GitHub → Repository → Settings → Secrets and variables → Actions**
2. Click **New repository secret** and add:

| Secret Name | Description |
|-------------|-------------|
| `KEYSTORE_BASE64` | Base64-encoded keystore file |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias |
| `KEY_PASSWORD` | Key password |

### Generate base64 keystore:
```bash
base64 -w 0 your-keystore.jks | pbcopy  # macOS
# or
base64 -w 0 your-keystore.jks | xclip -selection clipboard  # Linux
```

---

## Step 3: Trigger Workflow

### Automatic triggers:
- Push to `main`, `master`, or `develop` branches
- Pull requests to `main` or `master`

### Manual trigger:
1. Go to GitHub → Repository → Actions tab
2. Click "DNA63 Android Build" workflow
3. Click "Run workflow" button
4. Select branch and click "Run workflow"

---

## Step 4: Download Build Artifacts

After workflow completes:
1. Go to Actions tab
2. Click the workflow run
3. Scroll down to "Artifacts" section
4. Download `dna63-release-aab.zip`

---

## Workflow Features

### Caching
- **Pub dependencies**: Cached based on `pubspec.lock`
- **Gradle**: Cached based on Gradle files
- **Flutter SDK**: Cached via `flutter-action`

### Build Optimizations
- Single ABI (`android-arm64`) for faster builds
- Obfuscation enabled
- Debug symbols generated
- 6GB Gradle heap allocation

### Outputs
```
build/app/outputs/bundle/release/
└── app-release.aab
```

---

## Troubleshooting

### Workflow fails with "No valid Android SDK platform found"
The `subosito/flutter-action` handles Android SDK setup automatically.

### Build fails with memory errors
GitHub Actions runners have 7GB RAM. The workflow uses:
- Single ABI build (reduces load)
- 6GB Gradle heap (`-Xmx6g`)

### AAB not uploading
Check if the build script paths match your project structure.

---

## Cost Considerations

GitHub Actions free tier:
- **Public repos**: Unlimited minutes
- **Private repos**: 2,000 minutes/month

This workflow takes ~15-20 minutes per build.

---

## Next Steps

1. ✅ Setup complete - now builds happen on GitHub
2. Upload AAB to Google Play Console (Internal Testing)
3. Setup Play Store signing (if not using GitHub signing)

For questions, check GitHub Actions documentation: https://docs.github.com/en/actions

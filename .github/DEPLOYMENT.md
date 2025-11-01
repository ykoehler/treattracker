# GitHub Actions Setup for Firebase Hosting

This guide shows you how to set up automatic deployment to Firebase Hosting when you push to the `main` branch.

## 🚀 Quick Setup

### Option 1: Automatic Setup (Recommended)

Run this command in your project directory:

```bash
firebase init hosting:github
```

This will:
- Set up GitHub Actions workflow automatically
- Add the required Firebase service account secret to GitHub
- Configure deployment for both pull requests (preview) and main branch (production)

### Option 2: Manual Setup

If the automatic setup doesn't work, follow these steps:

#### Step 1: Get Firebase Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts?project=treattracker-app)
2. Or run:
   ```bash
   firebase login:ci
   ```
   This generates a CI token

3. Copy the token or service account JSON

#### Step 2: Add GitHub Secret

1. Go to your GitHub repository: https://github.com/ykoehler/treattracker
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the secret:
   - **Name:** `FIREBASE_SERVICE_ACCOUNT_TREATTRACKER_APP`
   - **Value:** Paste the service account JSON or CI token

#### Step 3: Test the Workflow

1. Commit and push to the `main` branch
2. Go to **Actions** tab in GitHub
3. Watch the deployment workflow run

## 📋 Available Workflows

We have two workflow files:

### 1. `firebase-hosting-deploy.yml` (Simple - Recommended)
- Deploys on push to `main`
- Automatically generates Firebase config
- Single deployment to production

### 2. `deploy.yml` (Advanced)
- Deploys on push to `main` (production)
- Creates preview channels for pull requests
- Runs tests and code analysis
- More comprehensive but requires additional secrets

## 🔑 Required Secrets

### For Simple Workflow (`firebase-hosting-deploy.yml`)

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `FIREBASE_SERVICE_ACCOUNT_TREATTRACKER_APP` | Service account for deployment | Run `firebase init hosting:github` |
| `GITHUB_TOKEN` | Automatically provided | No action needed |

### For Advanced Workflow (`deploy.yml`)

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `FIREBASE_SERVICE_ACCOUNT` | Service account JSON | Google Cloud Console → IAM |
| `FIREBASE_PROJECT_ID` | Your Firebase project ID | Set to: `treattracker-app` |
| `FIREBASE_TOKEN` | CI token | Run: `firebase login:ci` |
| `GITHUB_TOKEN` | Automatically provided | No action needed |

## 🛠️ Setting Up Secrets

### Method 1: Using Firebase CLI (Easiest)

```bash
# This will automatically set up everything
firebase init hosting:github
```

Follow the prompts:
- Select your repository: `ykoehler/treattracker`
- Set up workflow for `main` branch: **Yes**
- Set up workflow for pull requests: **Yes** (optional)

### Method 2: Manual Setup

1. **Generate Service Account:**
   ```bash
   # Login and get CI token
   firebase login:ci
   
   # Or create service account in Google Cloud Console
   # Go to: https://console.cloud.google.com/iam-admin/serviceaccounts?project=treattracker-app
   ```

2. **Add to GitHub:**
   - Repository → Settings → Secrets and variables → Actions
   - New repository secret
   - Name: `FIREBASE_SERVICE_ACCOUNT_TREATTRACKER_APP`
   - Value: Paste the service account JSON

3. **Verify Secret:**
   - Should appear in the secrets list
   - Value will be hidden (shows as `***`)

## 🧪 Testing Deployment

### Local Test (Without GitHub Actions)

```bash
# Build the app
flutter build web --release

# Deploy manually
firebase deploy --only hosting
```

### Test GitHub Actions

1. **Make a small change:**
   ```bash
   echo "# Test deployment" >> README.md
   git add README.md
   git commit -m "test: trigger deployment"
   git push origin main
   ```

2. **Watch the deployment:**
   - Go to: https://github.com/ykoehler/treattracker/actions
   - Click on the latest workflow run
   - Monitor progress

3. **Check the deployed site:**
   - Production: https://treattracker-app.web.app
   - Or: https://treattracker-app.firebaseapp.com

## 📊 Workflow Features

### What Happens on Push to `main`:

1. ✅ Checkout code
2. ✅ Set up Flutter environment
3. ✅ Install dependencies (`flutter pub get`)
4. ✅ Generate Firebase configuration
5. ✅ Build web app (`flutter build web`)
6. ✅ Deploy to Firebase Hosting (production)
7. ✅ Comment on PR with preview URL (for PRs)

### Build Time:
- First build: ~3-5 minutes
- Cached builds: ~2-3 minutes

## 🔧 Customizing Deployment

### Change Flutter Version

Edit `.github/workflows/firebase-hosting-deploy.yml`:

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.27.x'  # Change version here
    channel: 'stable'
```

### Add Build Optimizations

```yaml
- name: Build Flutter web
  run: |
    flutter build web \
      --release \
      --web-renderer canvaskit \
      --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### Deploy to Different Channels

```yaml
# Preview channel
firebase hosting:channel:deploy preview-${{ github.event.number }}

# Specific version
firebase hosting:channel:deploy v${{ github.run_number }}
```

## 🐛 Troubleshooting

### Workflow Fails: "Secret not found"

**Solution:** Add the required secret to GitHub:
1. Settings → Secrets and variables → Actions
2. New repository secret
3. Name: `FIREBASE_SERVICE_ACCOUNT_TREATTRACKER_APP`

### Workflow Fails: "Firebase CLI not authenticated"

**Solution:** The service account secret is invalid
1. Regenerate: `firebase login:ci`
2. Update the secret in GitHub

### Workflow Fails: "FlutterFire configure failed"

**Solution:** The Firebase project might not exist
1. Verify project exists: `firebase projects:list`
2. Check project ID is correct: `treattracker-app`

### Build Succeeds but Site Doesn't Update

**Solution:** Check caching
1. Clear browser cache
2. Try incognito/private mode
3. Check Firebase Console → Hosting for deployment status

## 📁 File Structure

```
.github/
└── workflows/
    ├── deploy.yml                          # Advanced workflow with testing
    └── firebase-hosting-deploy.yml         # Simple deployment workflow
```

## 🔒 Security Notes

- ✅ Service account secrets are encrypted in GitHub
- ✅ `firebase_options.dart` is generated during build (not committed)
- ✅ GitHub Actions has read-only access by default
- ✅ Only authorized users can trigger deployments
- ✅ All workflow runs are logged and auditable

## 🎯 Next Steps

1. **Set up the workflow:**
   ```bash
   firebase init hosting:github
   ```

2. **Test deployment:**
   ```bash
   git add .
   git commit -m "feat: add GitHub Actions deployment"
   git push origin main
   ```

3. **Monitor deployment:**
   - Watch: https://github.com/ykoehler/treattracker/actions
   - Visit: https://treattracker-app.web.app

## 📚 Resources

- [Firebase Hosting GitHub Actions](https://github.com/FirebaseExtended/action-hosting-deploy)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

---

**Ready to deploy automatically!** Just set up the secret and push to `main`. 🚀

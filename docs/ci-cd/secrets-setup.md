# GitHub Secrets Setup

This document explains how to configure the required GitHub secrets for CI/CD workflows.

## Required Secrets

### 1. GOOGLE_SERVICES_JSON_BASE64 (Android)

The `google-services.json` file contains Firebase configuration for Android.

**To set up:**

1. Encode the file to base64:
   ```bash
   base64 -i android/app/google-services.json
   ```
   Or on Linux:
   ```bash
   base64 -w 0 android/app/google-services.json
   ```

2. Copy the base64 output (it will be one long line)

3. Go to your GitHub repository → Settings → Secrets and variables → Actions

4. Click "New repository secret"

5. Name: `GOOGLE_SERVICES_JSON_BASE64`

6. Value: Paste the base64 encoded string

7. Click "Add secret"

### 2. GOOGLE_SERVICE_INFO_PLIST_BASE64 (iOS)

The `GoogleService-Info.plist` file contains Firebase configuration for iOS.

**To set up:**

1. Encode the file to base64:
   ```bash
   base64 -i ios/Runner/GoogleService-Info.plist
   ```
   Or on Linux:
   ```bash
   base64 -w 0 ios/Runner/GoogleService-Info.plist
   ```

2. Copy the base64 output (it will be one long line)

3. Go to your GitHub repository → Settings → Secrets and variables → Actions

4. Click "New repository secret"

5. Name: `GOOGLE_SERVICE_INFO_PLIST_BASE64`

6. Value: Paste the base64 encoded string

7. Click "Add secret"

### 3. FIREBASE_SERVICE_ACCOUNT_{{PROJECT_NAME_UPPER}} (Firebase Deployments)

This service account is used for deploying the web app to Firebase Hosting AND for deploying Firestore rules/indexes. It replaces the deprecated FIREBASE_TOKEN method.

**To set up:**

#### Step 1: Create the Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/)

2. Select your project: **{{FIREBASE_PROJECT_ID}}**

3. Go to **IAM & Admin** → **Service Accounts**

4. Click **"+ CREATE SERVICE ACCOUNT"**

5. Enter details:
   - **Name**: `github-actions-deployer`
   - **Description**: `Service account for GitHub Actions deployments`

6. Click **"CREATE AND CONTINUE"**

#### Step 2: Grant Required IAM Roles

Grant the following roles to the service account:

**Required roles:**
- ✅ **Firebase Admin** (`roles/firebase.admin`)
- ✅ **Cloud Datastore User** (`roles/datastore.user`)
- ✅ **Service Usage Consumer** (`roles/serviceusage.serviceUsageConsumer`)
- ✅ **Firebase Hosting Admin** (`roles/firebasehosting.admin`)

**How to add roles:**
1. In the service account creation wizard, click **"Select a role"**
2. Search for and add each role listed above
3. Click **"Continue"** when all roles are added
4. Click **"Done"**

#### Step 3: Create and Download the Key

1. Find your service account in the list

2. Click on the service account email

3. Go to the **"Keys"** tab

4. Click **"Add Key"** → **"Create new key"**

5. Select **JSON** format

6. Click **"Create"** - the JSON file will download automatically

7. **Keep this file secure!** It contains sensitive credentials

#### Step 4: Add to GitHub Secrets

1. Go to your GitHub repository → Settings → Secrets and variables → Actions

2. Click **"New repository secret"**

3. Name: `FIREBASE_SERVICE_ACCOUNT_{{PROJECT_NAME_UPPER}}`

4. Value: Paste the **entire contents** of the downloaded JSON file

5. Click **"Add secret"**

#### What This Service Account Does

This single service account is used for:
- ✅ Web app deployment to Firebase Hosting
- ✅ Firestore rules deployment
- ✅ Firestore indexes deployment

#### Troubleshooting

**If you get "Permission denied" errors:**

1. Go to [IAM & Admin in Cloud Console](https://console.cloud.google.com/iam-admin/iam)

2. Find your service account in the list

3. Click the pencil icon (Edit) next to it

4. Verify all 4 roles are listed:
   - Firebase Admin
   - Cloud Datastore User
   - Service Usage Consumer
   - Firebase Hosting Admin

5. If any are missing, click **"Add Another Role"** and add them

6. Click **"Save"**

7. Wait 1-2 minutes for permissions to propagate

8. Re-run the GitHub Actions workflow

**Alternative: Use Firebase Console Service Account**

If you already generated a service account from Firebase Console:

1. Find that service account in [Cloud Console IAM](https://console.cloud.google.com/iam-admin/iam)

2. It will be named like `firebase-adminsdk-xxxxx@{{FIREBASE_PROJECT_ID}}.iam.gserviceaccount.com`

3. Click Edit and add the missing roles listed above

The deprecated `FIREBASE_TOKEN` (from `firebase login:ci`) is no longer needed.

### 5. CODECOV_TOKEN (Optional - for code coverage reporting)

If you're using Codecov for coverage reports:

1. Sign up at https://codecov.io/ with your GitHub account

2. Add your repository to Codecov

3. Copy the upload token from the Codecov repository settings

4. Go to your GitHub repository → Settings → Secrets and variables → Actions

5. Click "New repository secret"

6. Name: `CODECOV_TOKEN`

7. Value: Paste the token

8. Click "Add secret"

## Verifying Setup

After setting up all secrets:

1. Go to Actions tab in your GitHub repository

2. Trigger a workflow run (push to main or create a PR)

3. Check that all jobs complete successfully

4. If any job fails, check the logs for missing secrets

## Security Notes

- **Never commit these files to git** - they're already in `.gitignore`
- These secrets contain sensitive API keys and credentials
- Only repository administrators can view and manage secrets
- Secrets are encrypted and only exposed to GitHub Actions during workflow runs
- Rotate secrets regularly for security

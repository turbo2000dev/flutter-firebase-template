# Firebase Deployment via CI/CD

This document explains how Firestore Database and Firebase Functions are automatically deployed via GitHub Actions.

## Overview

The CI/CD pipeline automatically deploys Firebase resources to production when code is pushed to the `main` branch:

- **Firestore Rules**: Security rules for database access control
- **Firestore Indexes**: Database indexes for query performance
- **Firebase Functions**: Python-based Cloud Functions for Excel generation

## CI/CD Jobs

### Job 5: Deploy Firestore Rules & Indexes

**Triggers**: Automatic on push to `main` branch

**What it does**:
1. Installs Firebase CLI
2. Authenticates using service account
3. Deploys Firestore security rules (`firestore.rules`)
4. Deploys Firestore indexes (`firestore.indexes.json`)

**Timeout**: 10 minutes

### Job 6: Deploy Firebase Functions

**Triggers**: Automatic on push to `main` branch

**What it does**:
1. Sets up Python 3.12 environment
2. Creates virtual environment in `functions/venv/`
3. Installs Python dependencies in venv from `functions/requirements.txt`
4. Validates Python code (syntax check)
5. Installs Firebase CLI
6. Deploys Cloud Functions to Firebase

**Functions deployed**:
- `generate_projection_excel`: Excel export for {{project_type}} projections

**Timeout**: 15 minutes

## Required GitHub Secrets

To enable Firebase deployments, you need to set the following secret in your GitHub repository:

### `FIREBASE_SERVICE_ACCOUNT_{{PROJECT_NAME_UPPER}}`

This is a JSON service account key with permissions to deploy to Firebase.

**How to create**:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `{{FIREBASE_PROJECT_ID}}`
3. Navigate to **IAM & Admin** → **Service Accounts**
4. Create a new service account or use existing one
5. Grant the following roles:
   - **Firebase Admin** (for Firestore rules and hosting)
   - **Cloud Functions Admin** (for Functions deployment)
   - **Service Account User** (for deployment)
6. Create a JSON key for the service account
7. Copy the entire JSON content
8. In your GitHub repository:
   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Name: `FIREBASE_SERVICE_ACCOUNT_{{PROJECT_NAME_UPPER}}`
   - Value: Paste the JSON key
   - Click **Add secret**

**Security Notes**:
- Never commit service account keys to the repository
- Rotate keys periodically (every 90 days recommended)
- Use least-privilege principle - only grant necessary permissions

## Local Testing

### Test Firestore Rules Locally

```bash
# Install Firebase emulator
npm install -g firebase-tools

# Start Firestore emulator
firebase emulators:start --only firestore

# Test rules with Firebase Console
open http://localhost:4000/firestore
```

### Test Firebase Functions Locally

```bash
# Navigate to functions directory
cd functions

# Create virtual environment and install dependencies
python3.12 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Start Functions emulator
firebase emulators:start --only functions

# Test the function
curl -X POST http://localhost:5001/{{FIREBASE_PROJECT_ID}}/us-central1/generate_projection_excel \
  -H "Content-Type: application/json" \
  -d '{"projection": {...}, "scenarioName": "Test"}' \
  --output test.xlsx
```

## Manual Deployment

If you need to deploy manually (outside CI/CD):

### Deploy Firestore Rules Only

```bash
firebase deploy --only firestore:rules --project {{FIREBASE_PROJECT_ID}}
```

### Deploy Firestore Indexes Only

```bash
firebase deploy --only firestore:indexes --project {{FIREBASE_PROJECT_ID}}
```

### Deploy Firebase Functions Only

```bash
firebase deploy --only functions --project {{FIREBASE_PROJECT_ID}}
```

### Deploy Everything

```bash
firebase deploy --project {{FIREBASE_PROJECT_ID}}
```

## Monitoring Deployments

### GitHub Actions

- View workflow runs: https://github.com/[YOUR_USERNAME]/{{PROJECT_NAME}}/actions
- Check job status, logs, and error messages
- Failed deployments will show red ❌
- Successful deployments show green ✓

### Firebase Console

**Firestore Rules**:
- https://console.firebase.google.com/project/{{FIREBASE_PROJECT_ID}}/firestore/rules

**Firestore Indexes**:
- https://console.firebase.google.com/project/{{FIREBASE_PROJECT_ID}}/firestore/indexes

**Cloud Functions**:
- https://console.firebase.google.com/project/{{FIREBASE_PROJECT_ID}}/functions/list
- View function logs, metrics, and invocation history

## Troubleshooting

### Error: "Permission denied"

**Cause**: Service account lacks necessary permissions

**Solution**:
1. Check service account roles in Google Cloud Console
2. Ensure it has Firebase Admin and Cloud Functions Admin roles
3. Regenerate and update the GitHub secret if needed

### Error: "Project requires Blaze plan"

**Cause**: Cloud Functions require Firebase Blaze (pay-as-you-go) plan

**Solution**:
1. Upgrade to Blaze plan: https://console.firebase.google.com/project/{{FIREBASE_PROJECT_ID}}/usage/details
2. Note: Free tier is generous; typical usage won't incur charges

### Error: "Python module not found"

**Cause**: Missing dependency in `functions/requirements.txt`

**Solution**:
1. Add missing package to `functions/requirements.txt`
2. Test locally: `cd functions && pip install -r requirements.txt`
3. Commit and push changes

### Error: "Missing virtual environment at venv directory"

**Cause**: Firebase Functions for Python requires a virtual environment in `functions/venv/`

**Full error**:
```
Error: Failed to find location of Firebase Functions SDK: Missing virtual
environment at venv directory. Did you forget to run 'python3.12 -m venv venv'?
```

**Solution**:
1. The CI/CD workflow automatically creates the venv (fixed in latest workflow)
2. For local development, create venv manually:
   ```bash
   cd functions
   python3.12 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. Ensure `functions/venv/` is in `.gitignore` (don't commit it)
4. Re-run the deployment after updating the workflow

**Why this happens**:
- Firebase Functions packages Python dependencies from the venv
- Without a venv, Firebase can't determine which packages to deploy
- The venv must exist in `functions/venv/` specifically

### Error: "Invalid service account JSON"

**Cause**: Service account secret is malformed

**Solution**:
1. Verify the JSON key is valid (use `jq` or JSON validator)
2. Re-download the key from Google Cloud Console
3. Update GitHub secret with correct JSON

### Deployment succeeds but rules don't take effect

**Cause**: Rules may take a few minutes to propagate

**Solution**:
1. Wait 2-3 minutes
2. Test with Firebase Console or your app
3. Check Firebase Console to verify rules were deployed

### Function deployment times out

**Cause**: Large dependencies or slow network

**Solution**:
1. Check if `functions/requirements.txt` has unnecessary packages
2. Increase timeout in workflow (currently 15 minutes)
3. Check Firebase Console logs for specific errors

## Cost Considerations

### Firestore

- **Rules and Indexes**: No cost
- **Database operations**: Billed per read/write (generous free tier)

### Cloud Functions

- **Invocations**: $0.40 per million invocations
- **Compute time**: $0.0000025 per GB-second
- **Free tier**: 2 million invocations, 400,000 GB-seconds per month
- **Typical usage**: ~150 exports/month = $0.00 (within free tier)

### Estimated Total Cost

**Development/Testing**: $0.00 (within free tiers)
**Production with moderate usage**: $0-5/month

## Best Practices

1. **Test locally first**: Always test rule changes and function updates locally before deploying
2. **Review logs**: Check Firebase Console logs after deployment
3. **Monitor usage**: Keep an eye on Firebase usage dashboard to avoid surprises
4. **Use staging**: Consider a separate Firebase project for staging/testing
5. **Version control**: All Firebase config files are in Git - review changes in PRs
6. **Security first**: Never commit service account keys or secrets

## Related Documentation

- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Functions for Firebase](https://firebase.google.com/docs/functions)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Support

For issues with:
- **CI/CD pipeline**: Check GitHub Actions logs and this documentation
- **Firebase deployment**: Consult Firebase Console and official documentation
- **Service account permissions**: Review Google Cloud IAM settings

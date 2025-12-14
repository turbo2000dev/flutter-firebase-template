# Firebase Deployment Checklist

Quick reference for Firebase deployments via CI/CD.

## ✅ Prerequisites

Before the CI/CD pipeline can deploy Firebase resources, ensure:

- [ ] Firebase project is on **Blaze (pay-as-you-go) plan** (required for Cloud Functions)
- [ ] GitHub secret `FIREBASE_SERVICE_ACCOUNT_{{PROJECT_NAME_UPPER}}` is set
- [ ] Service account has required permissions:
  - Firebase Admin
  - Cloud Functions Admin
  - Service Account User

## 🚀 Automatic Deployment

### Triggers

Deployments happen automatically when:
- Code is pushed to `main` branch
- All tests pass

### What Gets Deployed

| Resource | Files | Deployment Time |
|----------|-------|-----------------|
| **Firestore Rules** | `firestore.rules` | ~2 minutes |
| **Firestore Indexes** | `firestore.indexes.json` | ~2 minutes |
| **Firebase Functions** | `functions/*.py` | ~5-10 minutes |
| **Web Hosting** | `build/web/` | ~3 minutes |

### Deployment Order

1. ✅ **Tests** run first
2. 🌐 **Web build & deploy** (if tests pass)
3. 🔐 **Firestore rules** (if tests pass)
4. ⚡ **Firebase Functions** (if tests pass)

## 📝 Making Changes

### To Update Firestore Security Rules

1. Edit `firestore.rules`
2. Test locally:
   ```bash
   firebase emulators:start --only firestore
   ```
3. Commit and push to `main`
4. CI/CD automatically deploys

### To Update Firestore Indexes

1. Edit `firestore.indexes.json`
2. Or use Firebase Console to generate automatically
3. Commit and push to `main`
4. CI/CD automatically deploys

### To Update Firebase Functions

1. Edit files in `functions/` directory:
   - `main.py` - Entry point
   - `excel_generator.py` - Excel generation logic
   - `models.py` - Data models
2. Update `functions/requirements.txt` if adding dependencies
3. Test locally:
   ```bash
   cd functions
   pip install -r requirements.txt
   python -m py_compile main.py
   firebase emulators:start --only functions
   ```
4. Commit and push to `main`
5. CI/CD automatically deploys

## 🔍 Monitoring Deployment

### GitHub Actions

1. Go to: https://github.com/[YOUR_USERNAME]/{{PROJECT_NAME}}/actions
2. Click on the latest workflow run
3. Check each job status:
   - ✅ Green = Success
   - ❌ Red = Failed (click for logs)
   - 🟡 Yellow = In progress

### Firebase Console

After deployment, verify in Firebase Console:

**Firestore Rules**:
```
https://console.firebase.google.com/project/{{FIREBASE_PROJECT_ID}}/firestore/rules
```

**Firestore Indexes**:
```
https://console.firebase.google.com/project/{{FIREBASE_PROJECT_ID}}/firestore/indexes
```

**Cloud Functions**:
```
https://console.firebase.google.com/project/{{FIREBASE_PROJECT_ID}}/functions/list
```

## ⚠️ Common Issues

### Deployment Failed: "Permission denied"

**Fix**: Update service account permissions in Google Cloud Console

### Deployment Failed: "Requires Blaze plan"

**Fix**: Upgrade Firebase project to Blaze plan

### Function Not Working After Deployment

**Checks**:
1. Wait 2-3 minutes for propagation
2. Check Firebase Console function logs
3. Verify function URL is correct
4. Test with curl:
   ```bash
   curl https://us-central1-{{FIREBASE_PROJECT_ID}}.cloudfunctions.net/generate_projection_excel
   ```

### Rules Deployed but Not Taking Effect

**Fix**:
1. Clear browser cache
2. Wait 2-3 minutes
3. Check Firebase Console to confirm deployment

## 🔧 Manual Deployment (Emergency)

If CI/CD is down or you need to deploy manually:

```bash
# Deploy everything
firebase deploy --project {{FIREBASE_PROJECT_ID}}

# Deploy only Firestore rules
firebase deploy --only firestore:rules --project {{FIREBASE_PROJECT_ID}}

# Deploy only Functions
firebase deploy --only functions --project {{FIREBASE_PROJECT_ID}}

# Deploy only Hosting
firebase deploy --only hosting --project {{FIREBASE_PROJECT_ID}}
```

## 📊 Deployment Timeline

Typical deployment after push to `main`:

```
0:00 - Push to main
0:30 - Tests start
5:00 - Tests complete ✓
5:30 - Web build starts
8:30 - Web deployed ✓
8:30 - Firestore rules deployment starts
10:00 - Firestore rules deployed ✓
10:00 - Functions deployment starts
18:00 - Functions deployed ✓
```

**Total time**: ~15-20 minutes from push to full deployment

## 🎯 Best Practices

1. ✅ **Test locally first** - Always test before pushing
2. ✅ **Review logs** - Check GitHub Actions and Firebase Console
3. ✅ **Small changes** - Deploy small, incremental changes
4. ✅ **Monitor costs** - Check Firebase usage dashboard
5. ✅ **Security first** - Review rule changes carefully

## 📚 Quick Links

- [Full Firebase Deployment Guide](./firebase-deployment.md)
- [Weekly Workflow](./weekly-workflow.md)
- [Firebase Console](https://console.firebase.google.com/project/{{FIREBASE_PROJECT_ID}})
- [GitHub Actions](https://github.com/[YOUR_USERNAME]/{{PROJECT_NAME}}/actions)

## 🆘 Getting Help

**Issue**: CI/CD deployment failed
**Check**: GitHub Actions logs → Failed job → Error message

**Issue**: Firebase deployment succeeded but not working
**Check**: Firebase Console → Functions/Rules → Logs

**Issue**: Can't access Firebase Console
**Check**: Permissions in Firebase project settings

---

**Last Updated**: 2025-11-10
**CI/CD Version**: 1.0

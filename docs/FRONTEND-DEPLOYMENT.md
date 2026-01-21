# Frontend Deployment Guide - S3 + CloudFront

Complete guide for deploying the frontend with S3 + CloudFront CDN.

---

## 🎯 Overview

The frontend is deployed using:
- **S3** - Static file hosting (private bucket)
- **CloudFront** - Global CDN with HTTPS
- **OAI (Origin Access Identity)** - Secure S3 access

**Benefits:**
- ✅ HTTPS by default
- ✅ Global CDN (fast worldwide)
- ✅ Cheap (~$1-2/month)
- ✅ Auto-caching
- ✅ Production-ready

---

## 🚀 Deployment Steps

### Step 1: Deploy Infrastructure

```bash
cd infrastructure/sam

# Build and deploy (includes S3 + CloudFront)
sam build --template template-phase3.yaml --use-container
sam deploy --template template-phase3.yaml --guided
```

**Resources Created:**
- S3 bucket (private)
- CloudFront distribution
- Origin Access Identity (OAI)
- Bucket policy

**Deployment time:** 10-15 minutes (CloudFront takes longest)

---

### Step 2: Deploy Frontend

```bash
# From infrastructure/sam directory
cd ../scripts

# Run deployment script
./deploy-frontend.sh
```

**What it does:**
1. Gets stack outputs (bucket name, distribution ID, API endpoint)
2. Injects API endpoint into `index.html`
3. Uploads to S3
4. Invalidates CloudFront cache
5. Displays frontend URL

**Expected output:**
```
======================================
✓ Deployment Complete!
======================================

Frontend URL:
  https://d1234567890.cloudfront.net

API Endpoint:
  https://abc123.execute-api.ap-south-1.amazonaws.com/dev/document

Note: CloudFront cache invalidation may take 1-2 minutes.
```

---

### Step 3: Access Frontend

Open the CloudFront URL in your browser:
```
https://d1234567890.cloudfront.net
```

The API endpoint is **automatically configured** - no manual setup needed!

---

## 🔧 Manual Deployment (Alternative)

If you prefer manual deployment:

### Get Stack Outputs

```bash
aws cloudformation describe-stacks \
  --stack-name doc-generator-phase3 \
  --region ap-south-1 \
  --query 'Stacks[0].Outputs'
```

### Update Frontend

Edit `frontend/index.html` and replace:
```javascript
let API_ENDPOINT = localStorage.getItem('apiEndpoint') || '';
```

With:
```javascript
let API_ENDPOINT = 'https://YOUR-API-ID.execute-api.ap-south-1.amazonaws.com/dev/document';
```

### Upload to S3

```bash
BUCKET_NAME="doc-generator-frontend-YOUR-ACCOUNT-ID-dev"

aws s3 cp frontend/index.html s3://$BUCKET_NAME/index.html \
  --content-type "text/html" \
  --cache-control "max-age=3600"
```

### Invalidate CloudFront Cache

```bash
DISTRIBUTION_ID="E1234567890ABC"

aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

---

## 📊 Architecture

```
User Browser
    ↓
CloudFront (HTTPS, Global CDN)
    ↓
S3 Bucket (Private)
    ├── index.html (Frontend)
    └── (Other assets if added)
    
Frontend JavaScript
    ↓
API Gateway (CORS enabled)
    ↓
Lambda + DynamoDB
```

---

## 🔐 Security Features

✅ **Private S3 Bucket**
- No public access
- CloudFront OAI only

✅ **HTTPS Enforced**
- HTTP automatically redirects to HTTPS
- CloudFront default certificate

✅ **CORS Configured**
- API Gateway allows CloudFront origin
- Secure cross-origin requests

✅ **Bucket Policy**
- Only CloudFront OAI can access
- No direct S3 access

---

## 💰 Cost Breakdown

**Monthly costs for typical usage:**

| Service | Usage | Cost |
|---------|-------|------|
| **S3 Storage** | 1 file (~50KB) | ~$0.001 |
| **S3 Requests** | 1000 GET requests | ~$0.004 |
| **CloudFront Transfer** | 1GB | ~$0.085 |
| **CloudFront Requests** | 10k requests | ~$0.01 |
| **Total** | Typical usage | **~$0.10-2/month** |

**Free Tier (12 months):**
- CloudFront: 1TB transfer/month free
- S3: 5GB storage, 20k GET requests free

**Expected cost: $0-2/month** depending on traffic.

---

## 🎓 What Students Learn

By deploying with CloudFront:

1. **CDN Concepts** - Edge locations, caching, global distribution
2. **Origin Access Identity (OAI)** - Secure S3 access pattern
3. **Cache Invalidation** - Managing CDN cache
4. **HTTPS/SSL** - Automatic SSL with CloudFront
5. **Infrastructure as Code** - Everything in SAM template
6. **Production Patterns** - Industry-standard frontend hosting

---

## 🔄 Update Frontend

When you make changes to `index.html`:

```bash
# Quick update
cd scripts
./deploy-frontend.sh
```

The script automatically:
- Uploads new version
- Invalidates cache
- Shows new URL

**Cache invalidation takes 1-2 minutes** - be patient!

---

## 🐛 Troubleshooting

### Issue: CloudFront shows old version

**Cause:** Cache not invalidated

**Solution:**
```bash
aws cloudfront create-invalidation \
  --distribution-id YOUR-DIST-ID \
  --paths "/*"
```

Or wait 1 hour (default TTL).

---

### Issue: CORS errors

**Cause:** API Gateway CORS not configured

**Solution:** CORS is already configured in the SAM template:
```yaml
Cors:
  AllowMethods: "'POST, OPTIONS, GET'"
  AllowHeaders: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
  AllowOrigin: "'*'"
```

If still having issues, redeploy:
```bash
sam build --use-container
sam deploy
```

---

### Issue: "Access Denied" on CloudFront

**Cause:** OAI not configured correctly

**Solution:** Check bucket policy:
```bash
aws s3api get-bucket-policy \
  --bucket doc-generator-frontend-YOUR-ACCOUNT-ID-dev
```

Should allow CloudFront OAI. If not, redeploy stack.

---

### Issue: API endpoint not configured

**Symptom:** Frontend asks to "Configure API endpoint"

**Cause:** `deploy-frontend.sh` didn't inject endpoint

**Solution:** 
1. Run `./deploy-frontend.sh` again
2. Or manually configure in browser (one-time, saves to localStorage)

---

## 📝 Getting Stack Outputs

All stack outputs in one command:

```bash
aws cloudformation describe-stacks \
  --stack-name doc-generator-phase3 \
  --region ap-south-1 \
  --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
  --output table
```

**Example output:**
```
-----------------------------------------
|          DescribeStacks              |
+------------------------+-------------+
|  ApiEndpoint           | https://... |
|  FrontendURL          | https://... |
|  CloudFrontDistributionId | E123... |
|  FrontendBucketName   | doc-gen...  |
+------------------------+-------------+
```

---

## 🎯 Complete Deployment Flow

**For students deploying from scratch:**

```bash
# 1. Navigate to SAM directory
cd infrastructure/sam

# 2. Build Lambda + Infrastructure
sam build --template template-phase3.yaml --use-container

# 3. Deploy (creates S3, CloudFront, Lambda, DynamoDB, API Gateway)
sam deploy --template template-phase3.yaml --guided
# Answer prompts (use defaults or customize)

# 4. Wait for deployment (10-15 minutes)
# CloudFront distribution takes longest

# 5. Deploy frontend
cd ../scripts
chmod +x deploy-frontend.sh  # First time only
./deploy-frontend.sh

# 6. Open frontend URL
# Copy CloudFront URL from script output
# Example: https://d1234567890.cloudfront.net

# 7. Test the application
# Frontend should work immediately!
```

**Total time:** ~15-20 minutes

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] CloudFront URL loads frontend
- [ ] API endpoint is auto-configured
- [ ] Can paste code and generate docs
- [ ] Metrics display (cost, tokens, time)
- [ ] Copy/download buttons work
- [ ] No CORS errors in browser console

---

## 🔗 Related Documentation

- [PHASE3-COMPLETE.md](PHASE3-COMPLETE.md) - Complete Phase 3 guide
- [QUICK-DEPLOY.md](QUICK-DEPLOY.md) - Quick deployment reference
- [AWS CloudFront Docs](https://docs.aws.amazon.com/cloudfront/)
- [AWS S3 Static Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)

---

**Frontend deployment is production-ready!** 🚀

Students now have a complete, professional frontend hosted on CloudFront with automatic HTTPS and global CDN.

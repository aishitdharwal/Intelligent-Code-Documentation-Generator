# Quick Deployment Reference

Quick reference for deploying Phase 3 with S3 + CloudFront frontend.

---

## 🚀 Complete Deployment

### Deploy Backend + Frontend Infrastructure

```bash
cd infrastructure/sam

# Build (CRITICAL: use --use-container)
sam build --template template-phase3.yaml --use-container

# Deploy (first time use --guided, subsequent deploys omit it)
sam deploy --template template-phase3.yaml --guided

# Wait 10-15 minutes for CloudFront to provision
```

### Deploy Frontend to S3 + CloudFront

```bash
cd ../scripts

# Deploy frontend (auto-injects API endpoint)
./deploy-frontend.sh

# Frontend URL will be displayed at the end
```

**Total time:** 15-20 minutes (CloudFront takes longest)

---

## 📊 Get Deployment Info

```bash
# Get all outputs (API endpoint, Frontend URL, etc.)
aws cloudformation describe-stacks \
  --stack-name doc-generator-phase3 \
  --region ap-south-1 \
  --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
  --output table
```

---

## 🔄 Update Frontend Only

When you make changes to `frontend/index.html`:

```bash
cd scripts
./deploy-frontend.sh
```

Changes live in 1-2 minutes after cache invalidation.

---

## 🧪 Test the Deployment

```bash
cd src/phase3_production

# Set your API endpoint
export API_ENDPOINT="https://YOUR-ID.execute-api.ap-south-1.amazonaws.com/dev/document"

# Test caching
python test_phase3.py $API_ENDPOINT

# Test chunking
python test_phase3_final.py $API_ENDPOINT
```

---

## 🗑️ Delete Everything

```bash
# Delete CloudFormation stack (removes all resources)
aws cloudformation delete-stack \
  --stack-name doc-generator-phase3 \
  --region ap-south-1

# Note: S3 bucket must be empty first
# If deletion fails, empty the frontend bucket:
aws s3 rm s3://doc-generator-frontend-YOUR-ACCOUNT-ID-dev --recursive
```

---

## Common Commands

### View Logs

```bash
# Tail logs in real-time
aws logs tail /aws/lambda/doc-generator-phase3-dev \
  --follow \
  --region ap-south-1
```

### Check DynamoDB Cache

```bash
# View cached items
aws dynamodb scan \
  --table-name doc-cache-phase3-dev \
  --region ap-south-1 \
  --limit 10
```

### Invalidate CloudFront Cache

```bash
# Get distribution ID
DIST_ID=$(aws cloudformation describe-stacks \
  --stack-name doc-generator-phase3 \
  --region ap-south-1 \
  --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
  --output text)

# Invalidate
aws cloudfront create-invalidation \
  --distribution-id $DIST_ID \
  --paths "/*"
```

---

## Important Notes

### ✅ Always Use `--use-container`

**CORRECT:**
```bash
sam build --template template-phase3.yaml --use-container
```

**WRONG:**
```bash
sam build --template template-phase3.yaml  # ❌ Binary dependency errors
```

### ✅ Test Order

1. **Local tests first** (no deployment):
   ```bash
   python test_chunking_local.py
   python test_retry_logic.py
   ```

2. **Deploy infrastructure**:
   ```bash
   sam build --use-container
   sam deploy
   ```

3. **Deploy frontend**:
   ```bash
   ./deploy-frontend.sh
   ```

4. **Test deployed API**:
   ```bash
   python test_phase3_final.py $API_ENDPOINT
   ```

### ✅ Stack Already Exists

If you get "stack already exists" error:

```bash
# Update existing stack (same command)
sam deploy --template template-phase3.yaml

# Or delete and redeploy
aws cloudformation delete-stack --stack-name doc-generator-phase3
# Wait for deletion to complete, then deploy again
```

---

## 📚 Detailed Documentation

- **[PHASE3-COMPLETE.md](PHASE3-COMPLETE.md)** - Complete Phase 3 guide
- **[FRONTEND-DEPLOYMENT.md](FRONTEND-DEPLOYMENT.md)** - Frontend deployment details
- **[S3-CLOUDFRONT-COMPLETE.md](S3-CLOUDFRONT-COMPLETE.md)** - S3 + CloudFront summary

---

## 🎯 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Binary dependency error | Use `--use-container` flag |
| Stack outputs not found | Redeploy with updated template |
| Frontend shows old version | Run `./deploy-frontend.sh` |
| CORS errors | Already configured, check API endpoint |
| CloudFront 403 error | Wait 10-15 min for distribution |
| Cache not working | Check CloudWatch logs |

---

**For detailed guides, see the docs folder!**

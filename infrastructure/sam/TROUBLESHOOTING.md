# Troubleshooting SAM Deployment Issues

## Issue: CloudWatch Logs Role ARN Error

### Error Message
```
CREATE_FAILED AWS::ApiGateway::Stage DocumentationApiStage
Resource handler returned message: "CloudWatch Logs role ARN must be set in 
account settings to enable logging (Service: ApiGateway, Status Code: 400)
```

### What This Means
API Gateway needs a special IAM role to write access logs to CloudWatch. This role must be configured once per AWS account, and it's not set by default.

### ✅ Solution 1: Set Up CloudWatch Role (One-Time Setup)

This is the proper fix and only needs to be done once per AWS account.

#### Using AWS CLI (Recommended - 2 Minutes)

```bash
# 1. Create the IAM role
aws iam create-role \
    --role-name APIGatewayCloudWatchLogsRole \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "apigateway.amazonaws.com"},
        "Action": "sts:AssumeRole"
      }]
    }'

# 2. Attach the policy
aws iam attach-role-policy \
    --role-name APIGatewayCloudWatchLogsRole \
    --policy-arn "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"

# 3. Get your account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# 4. Set the role in API Gateway
aws apigateway update-account \
    --patch-operations op='replace',path='/cloudwatchRoleArn',value="arn:aws:iam::${ACCOUNT_ID}:role/APIGatewayCloudWatchLogsRole"

# 5. Verify it worked
aws apigateway get-account
```

You should see output like:
```json
{
    "cloudwatchRoleArn": "arn:aws:iam::123456789012:role/APIGatewayCloudWatchLogsRole"
}
```

#### Using AWS Console (5 Minutes)

1. **Create IAM Role:**
   - Go to: https://console.aws.amazon.com/iam/home#/roles
   - Click "Create role"
   - Select "AWS service" → "API Gateway"
   - Click "Next"
   - Policy `AmazonAPIGatewayPushToCloudWatchLogs` should be attached
   - Click "Next"
   - Name: `APIGatewayCloudWatchLogsRole`
   - Click "Create role"

2. **Get Role ARN:**
   - Click on the role you just created
   - Copy the ARN (e.g., `arn:aws:iam::123456789012:role/APIGatewayCloudWatchLogsRole`)

3. **Set in API Gateway:**
   - Go to: https://console.aws.amazon.com/apigateway
   - Click "Settings" in the left sidebar (bottom)
   - Paste ARN into "CloudWatch log role ARN"
   - Click "Save"

4. **Redeploy:**
   ```bash
   cd infrastructure/sam
   sam deploy
   ```

### ✅ Solution 2: Disable Access Logging (Quick Fix)

I've already updated `template.yaml` to remove the access logging requirement. This means you can deploy immediately without setting up the CloudWatch role.

**What you lose:**
- API Gateway access logs (request/response logs)

**What you keep:**
- Lambda function logs (still in CloudWatch)
- All other monitoring
- CloudWatch dashboard
- Metrics

To deploy now:
```bash
cd infrastructure/sam
sam deploy
```

### Adding Access Logging Back Later

After you've set up the CloudWatch role, you can add access logging back by uncommenting these lines in `template.yaml`:

```yaml
DocumentationApi:
  Type: AWS::Serverless::Api
  Properties:
    # ... other properties ...
    
    # Add this back:
    AccessLogSetting:
      DestinationArn: !GetAtt ApiAccessLogs.Arn
      Format: '$context.requestId $context.extendedRequestId $context.identity.sourceIp $context.requestTime $context.httpMethod $context.routeKey $context.status $context.protocol $context.responseLength'

# And add this resource back:
Resources:
  ApiAccessLogs:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub '/aws/apigateway/doc-generator-${Environment}'
      RetentionInDays: 7
```

Then redeploy:
```bash
sam build && sam deploy
```

---

## Other Common Issues

### Issue: "Unable to locate credentials"

**Error:**
```
Error: Unable to locate credentials. You can configure credentials by running "aws configure"
```

**Solution:**
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter region (e.g., us-east-1)
# Enter output format (json)
```

---

### Issue: "Docker not running"

**Error:**
```
Error: Running AWS SAM projects locally requires Docker. Have you got it installed and running?
```

**Solution:**
```bash
# macOS: Start Docker Desktop application
# Linux: 
sudo systemctl start docker

# Verify:
docker ps
```

---

### Issue: "Stack already exists"

**Error:**
```
Stack already exists. Use --no-confirm-changeset to update existing stack
```

**Solution:**
```bash
# Update existing stack
sam deploy --no-confirm-changeset

# Or delete and recreate
sam delete
sam build && sam deploy --guided
```

---

### Issue: "No module named 'anthropic'"

**Error in Lambda logs:**
```
Unable to import module 'lambda_function': No module named 'anthropic'
```

**Solution:**
```bash
# Ensure requirements.txt exists in src/phase1_poc/
cat src/phase1_poc/requirements.txt

# Should contain:
# anthropic>=0.18.0
# pydantic>=2.0.0

# Rebuild
cd infrastructure/sam
rm -rf .aws-sam
sam build
sam deploy
```

---

### Issue: "Access Denied" during deployment

**Error:**
```
An error occurred (AccessDenied) when calling the CreateStack operation: 
User is not authorized to perform: cloudformation:CreateStack
```

**Solution:**

Your AWS user needs these permissions:
- CloudFormation full access
- Lambda full access
- API Gateway full access
- IAM role creation
- CloudWatch logs

**Quick fix for development:**
```bash
# Attach AdministratorAccess policy (dev/learning only!)
# In production, use more restrictive policies

# Or ask your AWS admin to grant you these permissions
```

---

### Issue: "Rate limit exceeded" from Claude API

**Error in logs:**
```
anthropic.RateLimitError: 429: rate_limit_error
```

**Solution:**

This is expected in Phase 1 (we fix it in Phase 3 with retry logic).

**Temporary workarounds:**
- Wait a few seconds between requests
- Reduce concurrent requests
- Check your Anthropic API tier limits

---

### Issue: Invalid API key

**Error:**
```
anthropic.AuthenticationError: 401: invalid_api_key
```

**Solution:**
```bash
# Update in samconfig.toml
parameter_overrides = [
    "AnthropicApiKey=sk-ant-YOUR-CORRECT-KEY",
    "Environment=dev"
]

# Redeploy
sam deploy --parameter-overrides "AnthropicApiKey=sk-ant-YOUR-KEY"
```

---

### Issue: "Template format error"

**Error:**
```
Template format error: Unrecognized resource types: [AWS::Serverless::Function]
```

**Solution:**

Make sure you have the Transform at the top of template.yaml:
```yaml
Transform: AWS::Serverless-2016-10-31
```

---

### Issue: Function timeout (5 minutes exceeded)

**Error:**
```
Task timed out after 300.00 seconds
```

**Solution:**

This is expected in Phase 1 for large files (>5000 lines).

**This is what Phase 2 demonstrates!** The file is too large for single-pass processing.

**Temporary workaround:**
- Test with smaller files
- We fix this in Phase 3 with chunking

---

## Debugging Tips

### View CloudFormation Events

```bash
# In AWS Console
# CloudFormation → Stacks → doc-generator-phase1 → Events

# Or via CLI
aws cloudformation describe-stack-events \
    --stack-name doc-generator-phase1 \
    --max-items 20
```

### Check Lambda Logs

```bash
# Stream logs
sam logs --tail

# Or specific time
sam logs --start-time '10min ago'

# In AWS Console
# CloudWatch → Log groups → /aws/lambda/doc-generator-dev
```

### Validate Template Syntax

```bash
sam validate --lint

# More verbose
sam validate --debug
```

### Check What Will Change

```bash
# Preview changes without deploying
sam deploy --no-execute-changeset

# Then review in CloudFormation console
```

### Enable Debug Mode

```bash
sam build --debug
sam deploy --debug
```

---

## Getting More Help

### 1. Check SAM Logs
```bash
cat ~/.aws-sam/build.log
```

### 2. Check CloudFormation Events
Look for the specific resource that failed and read the error message.

### 3. Validate Your Template
```bash
sam validate
```

### 4. Clean Build and Retry
```bash
rm -rf .aws-sam
sam build
sam deploy
```

### 5. Ask for Help
- Include the full error message
- Include CloudFormation events
- Include your SAM version: `sam --version`
- Include your AWS region

---

## Prevention Checklist

Before deploying:

- [ ] SAM CLI installed and updated
- [ ] AWS CLI configured with valid credentials
- [ ] Correct region set in samconfig.toml
- [ ] Anthropic API key is valid
- [ ] template.yaml has no syntax errors (`sam validate`)
- [ ] requirements.txt exists in src/phase1_poc/
- [ ] Docker running (for local testing)

---

## Quick Fixes Reference

| Issue | Quick Fix |
|-------|-----------|
| CloudWatch role error | Use updated template.yaml (access logging disabled) |
| No credentials | `aws configure` |
| Docker not running | Start Docker Desktop |
| Module not found | Check requirements.txt, rebuild |
| Rate limit | Wait between requests |
| Invalid API key | Update samconfig.toml |
| Template error | Check Transform line exists |
| Timeout | Expected for large files (Phase 3 fixes this) |

---

## Still Stuck?

1. Delete the stack: `sam delete`
2. Clean build artifacts: `rm -rf .aws-sam`
3. Rebuild: `sam build`
4. Redeploy with guided mode: `sam deploy --guided`
5. Check logs: `sam logs --tail`

If the problem persists, check the CloudFormation events in AWS Console for detailed error messages.

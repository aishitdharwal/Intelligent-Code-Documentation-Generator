# AWS SAM Deployment Guide - Phase 1

This guide walks you through deploying the Phase 1 POC using AWS SAM (Serverless Application Model).

## Why SAM?

AWS SAM is better than raw Terraform/CloudFormation for serverless applications because:
- **Local testing** - Test Lambda functions locally before deploying
- **Built for serverless** - Abstracts away boilerplate
- **Fast iteration** - Quick build, test, deploy cycle
- **Great DX** - Better developer experience than raw CloudFormation

## Prerequisites

### 1. Install AWS SAM CLI

**macOS:**
```bash
brew install aws-sam-cli
```

**Linux:**
```bash
# Download the installer
wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
sudo ./sam-installation/install
```

**Windows:**
Download installer from: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html

**Verify installation:**
```bash
sam --version
# Should output: SAM CLI, version 1.x.x
```

### 2. Install AWS CLI

```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
```

### 3. Configure AWS Credentials

```bash
aws configure
```

You'll be prompted for:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-east-1`)
- Output format (use `json`)

### 4. Install Python Dependencies

```bash
cd src/phase1_poc
pip install -r ../../requirements.txt
```

### 5. Get Your Anthropic API Key

1. Go to https://console.anthropic.com/
2. Sign up or log in
3. Navigate to API Keys
4. Create a new key
5. Copy it (you'll need it for deployment)

## Project Structure

```
infrastructure/sam/
├── template.yaml              # SAM template (infrastructure as code)
├── samconfig.toml            # SAM CLI configuration
├── samconfig-dev.toml        # Dev environment parameters
└── events/                   # Test events for local testing
    ├── sample-request.json   # Simple function test
    └── class-example.json    # Class-based code test
```

## Quick Start (5 Minutes to Deployment)

### Step 1: Navigate to SAM Directory

```bash
cd infrastructure/sam
```

### Step 2: Update Configuration

Edit `samconfig.toml` and replace `REPLACE_ME` with your Anthropic API key:

```toml
parameter_overrides = [
    "AnthropicApiKey=sk-ant-YOUR-KEY-HERE",
    "Environment=dev"
]
```

**IMPORTANT:** Never commit your API key to git! Add it to `.gitignore`:

```bash
echo "samconfig.toml" >> ../../.gitignore
```

### Step 3: Build the Application

```bash
sam build
```

This:
- Packages your Lambda function code
- Installs dependencies
- Prepares for deployment

**Expected output:**
```
Build Succeeded

Built Artifacts  : .aws-sam/build
Built Template   : .aws-sam/build/template.yaml
```

### Step 4: Deploy to AWS

```bash
sam deploy --guided
```

You'll be prompted with:
```
Stack Name [doc-generator-phase1]: <press enter>
AWS Region [us-east-1]: <press enter>
Parameter AnthropicApiKey []: sk-ant-YOUR-KEY-HERE
Parameter CostPerMillionInputTokens [3.0]: <press enter>
Parameter CostPerMillionOutputTokens [15.0]: <press enter>
Parameter Environment [dev]: <press enter>
#Shows you resources changes to be deployed and require a 'Y' to initiate deploy
Confirm changes before deploy [Y/n]: Y
#SAM needs permission to be able to create roles to connect to the resources in your template
Allow SAM CLI IAM role creation [Y/n]: Y
#Preserves the state of previously provisioned resources when an operation fails
Disable rollback [y/N]: N
DocumentationGeneratorFunction has no authentication. Is this okay? [y/N]: y
Save arguments to configuration file [Y/n]: Y
SAM configuration file [samconfig.toml]: <press enter>
SAM configuration environment [default]: <press enter>
```

**Deployment will take 2-3 minutes.**

### Step 5: Get Your API Endpoint

After successful deployment, you'll see outputs:

```
Outputs
------------------------------------------------------------------------
Key                 ApiEndpoint
Description         API Gateway endpoint URL
Value               https://abc123.execute-api.us-east-1.amazonaws.com/dev/document

Key                 FunctionName
Description         Lambda Function Name
Value               doc-generator-dev
```

**Copy the API endpoint!** This is your documentation generation URL.

## Testing Your Deployment

### Test 1: Using curl

```bash
# Set your API endpoint
API_ENDPOINT="https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/dev/document"

# Test with a simple Python function
curl -X POST $API_ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{
    "file_path": "test.py",
    "file_content": "def hello(name):\n    return f\"Hello, {name}!\""
  }'
```

**Expected response:**
```json
{
  "success": true,
  "data": {
    "request_id": "...",
    "file_path": "test.py",
    "status": "completed",
    "documentation": "# Documentation here...",
    "total_cost": 0.0024,
    "total_tokens": 850,
    "processing_time_seconds": 3.2
  },
  "message": "Documentation generated successfully"
}
```

### Test 2: Using Python

Create a test script `test_deployed_api.py`:

```python
import requests
import json

API_ENDPOINT = "https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/dev/document"

# Sample Python code to document
code = """
class Calculator:
    def __init__(self):
        self.result = 0
    
    def add(self, value):
        self.result += value
        return self.result
"""

# Make request
response = requests.post(
    API_ENDPOINT,
    json={
        "file_path": "calculator.py",
        "file_content": code
    }
)

# Print result
if response.status_code == 200:
    data = response.json()
    print("✅ Success!")
    print(f"Cost: ${data['data']['total_cost']:.4f}")
    print(f"Time: {data['data']['processing_time_seconds']:.2f}s")
    print("\nDocumentation:")
    print(data['data']['documentation'])
else:
    print(f"❌ Error: {response.status_code}")
    print(response.text)
```

Run it:
```bash
python test_deployed_api.py
```

### Test 3: Check CloudWatch Logs

```bash
# Get recent logs
sam logs --stack-name doc-generator-phase1 --tail

# Or view in AWS Console
# The deployment output includes a link to CloudWatch
```

## Local Testing (Before Deploying)

SAM's killer feature is testing Lambda functions locally!

### Start Local API

```bash
cd infrastructure/sam
sam local start-api
```

This starts a local API Gateway emulator at `http://localhost:3000`

### Test Locally

```bash
# In another terminal
curl -X POST http://localhost:3000/document \
  -H "Content-Type: application/json" \
  -d '{
    "file_path": "test.py",
    "file_content": "def add(a, b):\n    return a + b"
  }'
```

**Note:** You need Docker running for local testing!

### Invoke Function Directly

```bash
# Test with a sample event
sam local invoke DocumentationGeneratorFunction \
  --event events/sample-request.json
```

This invokes your Lambda function with the test event.

### Debug Locally

```bash
# Start in debug mode
sam local start-api --debug
```

Then attach your IDE's debugger to `localhost:5858`.

## Understanding the SAM Template

Let's break down `template.yaml`:

### 1. Global Configuration

```yaml
Globals:
  Function:
    Timeout: 300        # 5 minutes max
    MemorySize: 512     # MB
    Runtime: python3.9
```

Applies to all Lambda functions in the template.

### 2. Parameters

```yaml
Parameters:
  AnthropicApiKey:
    Type: String
    NoEcho: true  # Hides in console
```

Allows customization without changing template.

### 3. Lambda Function

```yaml
DocumentationGeneratorFunction:
  Type: AWS::Serverless::Function
  Properties:
    CodeUri: ../../src/phase1_poc/
    Handler: lambda_function.lambda_handler
    Events:
      DocumentApi:
        Type: Api
        Properties:
          Path: /document
          Method: POST
```

Defines the Lambda function and its API trigger.

### 4. API Gateway

```yaml
DocumentationApi:
  Type: AWS::Serverless::Api
  Properties:
    Cors:
      AllowMethods: "'POST, OPTIONS'"
      AllowOrigin: "'*'"
```

Configures API Gateway with CORS.

### 5. Outputs

```yaml
Outputs:
  ApiEndpoint:
    Value: !Sub "https://${DocumentationApi}.execute-api.${AWS::Region}.amazonaws.com/${Environment}/document"
```

Displays useful information after deployment.

## Cost Monitoring

### View CloudWatch Dashboard

After deployment, a CloudWatch dashboard is automatically created:

1. Go to AWS Console → CloudWatch → Dashboards
2. Find `doc-generator-dev`
3. View metrics for:
   - Invocations
   - Errors
   - Duration
   - Throttles

### Check API Gateway Metrics

```bash
# View API metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiName,Value=doc-generator-api-dev \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

### Estimate Costs

**AWS Costs (very minimal for Phase 1):**
- API Gateway: $3.50 per million requests
- Lambda: $0.20 per 1M requests + $0.0000166667 per GB-second
- CloudWatch: First 5GB logs free, then $0.50/GB

**Typical Phase 1 AWS cost:** <$5/month for 1000 requests

**Claude API costs:** ~₹20 per 1000-line file (this is your main cost)

## Updating Your Deployment

### Change Code

```bash
# Make changes to src/phase1_poc/lambda_function.py
# Then rebuild and deploy
sam build
sam deploy
```

### Change Configuration

```bash
# Edit samconfig.toml or template.yaml
# Then deploy changes
sam deploy --parameter-overrides "Environment=prod"
```

### View Changes Before Deploying

```bash
sam deploy --no-execute-changeset
```

This creates a changeset but doesn't execute it. Review in AWS Console.

## Cleanup (Delete Stack)

To delete all resources:

```bash
sam delete --stack-name doc-generator-phase1
```

Confirms before deletion. This removes:
- Lambda function
- API Gateway
- CloudWatch logs
- IAM roles
- Everything!

**Note:** This does NOT delete S3 buckets created by SAM for deployment artifacts. Delete those manually if needed.

## Troubleshooting

### Issue: "Docker not running"

**Error:** Cannot start local API - Docker not running

**Solution:**
```bash
# Start Docker Desktop
# Or install Docker:
# macOS: brew install --cask docker
# Linux: Follow Docker installation guide
```

### Issue: "Access Denied"

**Error:** User is not authorized to perform: cloudformation:CreateStack

**Solution:**
```bash
# Ensure your AWS credentials have permission
# Needed permissions: CloudFormation, Lambda, API Gateway, IAM, CloudWatch

# Check current user
aws sts get-caller-identity

# If using IAM roles, ensure they have AdministratorAccess or specific permissions
```

### Issue: "API Key Not Working"

**Error:** Authentication error from Claude API

**Solution:**
```bash
# Verify API key is correct
# Update in samconfig.toml
# Redeploy
sam build
sam deploy
```

### Issue: "Module Not Found"

**Error:** Unable to import module 'lambda_function'

**Solution:**
```bash
# Ensure requirements.txt is in the right place
# Check that dependencies are specified correctly
cd src/phase1_poc
pip install -r ../../requirements.txt -t .
cd ../../infrastructure/sam
sam build
```

### Issue: "Rate Limit Exceeded"

**Error:** 429 error from Claude API

**Solution:**
- You're hitting Claude's rate limits
- Wait a few seconds between requests
- This is expected in Phase 1 (Phase 3 fixes it!)

## Advanced Usage

### Use Different Environments

Deploy to multiple environments:

```bash
# Deploy to dev
sam deploy --parameter-overrides "Environment=dev"

# Deploy to prod
sam deploy --parameter-overrides "Environment=prod" \
  --stack-name doc-generator-phase1-prod
```

### Add X-Ray Tracing

Update `template.yaml`:

```yaml
Globals:
  Function:
    Tracing: Active  # Enable X-Ray
```

Then:
```bash
sam build && sam deploy
```

### Enable Lambda Insights

```yaml
DocumentationGeneratorFunction:
  Type: AWS::Serverless::Function
  Properties:
    Layers:
      - !Sub "arn:aws:lambda:${AWS::Region}:580247275435:layer:LambdaInsightsExtension:14"
```

### Custom Domain

Add a custom domain to your API:

```yaml
DocumentationApi:
  Type: AWS::Serverless::Api
  Properties:
    Domain:
      DomainName: api.yourdomain.com
      CertificateArn: arn:aws:acm:...
```

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to AWS
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: aws-actions/setup-sam@v2
      - uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - run: sam build
      - run: sam deploy --no-confirm-changeset --no-fail-on-empty-changeset
```

## Best Practices

1. **Never commit API keys** - Use environment variables or AWS Secrets Manager
2. **Test locally first** - Use `sam local` before deploying
3. **Use parameters** - Don't hardcode values in template
4. **Monitor costs** - Check CloudWatch and AWS Cost Explorer regularly
5. **Version your code** - Tag releases: `git tag v1.0.0`
6. **Review changesets** - Always review what will change before deploying

## Next Steps

After deploying Phase 1:

1. ✅ **Test with sample files** - Verify it works
2. ✅ **Monitor CloudWatch** - Check logs and metrics
3. ✅ **Track costs** - See actual Claude API costs
4. ✅ **Document the endpoint** - Share with your team
5. ⬜ **Move to Phase 2** - Break it with large files!
6. ⬜ **Implement Phase 3** - Add production features

## Resources

- **SAM Documentation:** https://docs.aws.amazon.com/serverless-application-model/
- **SAM CLI Reference:** https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-command-reference.html
- **AWS Lambda Python:** https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html
- **Anthropic API:** https://docs.anthropic.com/

## Getting Help

If you're stuck:
1. Check SAM CLI logs: `sam logs --stack-name doc-generator-phase1 --tail`
2. Check CloudWatch logs in AWS Console
3. Review CloudFormation events in AWS Console
4. Use `sam validate` to check template syntax
5. Join AWS SAM Slack or GitHub Discussions

Happy deploying! 🚀

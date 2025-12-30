# SAM Deployment - Quick Reference

## One-Line Commands

### First Time Setup
```bash
# 1. Install SAM CLI
brew install aws-sam-cli  # macOS

# 2. Configure AWS
aws configure

# 3. Deploy
cd infrastructure/sam
sam build && sam deploy --guided
```

### Subsequent Deployments
```bash
sam build && sam deploy
```

## Essential Commands

| Command | Purpose |
|---------|---------|
| `sam init` | Create new SAM project |
| `sam build` | Build your application |
| `sam deploy` | Deploy to AWS |
| `sam deploy --guided` | Interactive deployment |
| `sam local start-api` | Run API locally |
| `sam local invoke` | Test function locally |
| `sam logs --tail` | Stream CloudWatch logs |
| `sam delete` | Delete entire stack |
| `sam validate` | Validate template |
| `sam sync --watch` | Auto-deploy on changes |

## Common Workflows

### Test Locally → Deploy
```bash
# Start local API
sam local start-api

# In another terminal, test
curl -X POST http://localhost:3000/document \
  -H "Content-Type: application/json" \
  -d '{"file_path": "test.py", "file_content": "def hello(): pass"}'

# If it works, deploy
sam build && sam deploy
```

### Quick Deploy After Code Changes
```bash
sam build && sam deploy --no-confirm-changeset
```

### View Logs
```bash
# Tail logs
sam logs --stack-name doc-generator-phase1 --tail

# Get specific time range
sam logs --stack-name doc-generator-phase1 \
  --start-time '10min ago' \
  --end-time 'now'
```

### Update Environment Variables
```bash
# Edit samconfig.toml
# Then redeploy
sam deploy --parameter-overrides "AnthropicApiKey=NEW-KEY"
```

## Testing Commands

### Local Function Invocation
```bash
# With sample event
sam local invoke -e events/sample-request.json

# With inline event
sam local invoke --event events/class-example.json
```

### Local API Testing
```bash
# Start local API (requires Docker)
sam local start-api

# Test endpoint
curl http://localhost:3000/document \
  -X POST \
  -H "Content-Type: application/json" \
  -d @events/sample-request.json
```

## Debugging

### Debug Mode
```bash
# More verbose output
sam build --debug
sam deploy --debug

# Local debugging
sam local start-api --debug
```

### Validate Template
```bash
# Check for syntax errors
sam validate

# Validate with linting
sam validate --lint
```

### Check What Will Change
```bash
# Preview changes without deploying
sam deploy --no-execute-changeset

# Then review changeset in AWS Console
```

## Quick Troubleshooting

### Docker Issues
```bash
# Check if Docker is running
docker ps

# If not, start Docker Desktop
# Then retry: sam local start-api
```

### Build Errors
```bash
# Clean build artifacts
rm -rf .aws-sam

# Rebuild from scratch
sam build
```

### Deployment Stuck
```bash
# Check CloudFormation console for details
# Or delete and redeploy
sam delete
sam build && sam deploy --guided
```

### Import Errors in Lambda
```bash
# Ensure dependencies are in requirements.txt
# Check Python version matches (3.9)
python --version

# Rebuild
sam build
```

## File Locations

```
infrastructure/sam/
├── template.yaml           # SAM template (IaC)
├── samconfig.toml         # SAM CLI config
├── events/                # Test events
│   ├── sample-request.json
│   └── class-example.json
└── .aws-sam/              # Build artifacts (gitignored)
    └── build/
```

## Environment Variables

Set in `samconfig.toml`:
```toml
parameter_overrides = [
    "AnthropicApiKey=sk-ant-...",
    "Environment=dev",
    "CostPerMillionInputTokens=3.0",
    "CostPerMillionOutputTokens=15.0"
]
```

## Getting Stack Info

```bash
# List all stacks
aws cloudformation list-stacks

# Describe specific stack
aws cloudformation describe-stacks \
  --stack-name doc-generator-phase1

# Get outputs (including API endpoint)
aws cloudformation describe-stacks \
  --stack-name doc-generator-phase1 \
  --query 'Stacks[0].Outputs'
```

## Cost Check

```bash
# View estimated monthly cost in AWS Console:
# AWS Cost Explorer → "doc-generator"

# Check Lambda invocations
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 86400 \
  --statistics Sum \
  --dimensions Name=FunctionName,Value=doc-generator-dev
```

## Cleanup

### Delete Everything
```bash
sam delete --stack-name doc-generator-phase1
```

### Keep Template, Delete Deployment
```bash
# Just removes AWS resources, keeps local code
sam delete --no-prompts
```

## Tips & Tricks

### Auto-Deploy on File Changes
```bash
sam sync --watch
# Now edit files and SAM auto-deploys
```

### Build Faster
```bash
# Use cached builds
sam build --cached

# Build in parallel
sam build --parallel
```

### Multiple Environments
```bash
# Dev
sam deploy --stack-name doc-gen-dev --parameter-overrides "Environment=dev"

# Prod
sam deploy --stack-name doc-gen-prod --parameter-overrides "Environment=prod"
```

### Get API Endpoint
```bash
aws cloudformation describe-stacks \
  --stack-name doc-generator-phase1 \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
  --output text
```

## Common Errors & Fixes

| Error | Fix |
|-------|-----|
| Docker not running | Start Docker Desktop |
| API key invalid | Update in samconfig.toml |
| Build failed | `rm -rf .aws-sam && sam build` |
| Deploy timeout | Check CloudFormation events |
| Import error | Add to requirements.txt |
| Rate limit | Wait, then retry |

## Quick Test Script

Save as `quick-test.sh`:
```bash
#!/bin/bash
ENDPOINT=$(aws cloudformation describe-stacks \
  --stack-name doc-generator-phase1 \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
  --output text)

curl -X POST $ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{"file_path": "test.py", "file_content": "def hello(): return \"world\""}'
```

Run: `chmod +x quick-test.sh && ./quick-test.sh`

## Resources

- SAM Docs: https://docs.aws.amazon.com/sam
- Examples: https://github.com/aws-samples/serverless-patterns
- Best Practices: https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html

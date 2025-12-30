# AWS SAM Infrastructure - Phase 1 POC

This directory contains AWS SAM (Serverless Application Model) templates and configuration for deploying the Phase 1 documentation generator.

## What's Here

```
infrastructure/sam/
├── README.md                  # This file
├── DEPLOYMENT-GUIDE.md        # Complete deployment walkthrough
├── QUICK-REFERENCE.md         # Command cheat sheet
├── template.yaml              # SAM template (infrastructure as code)
├── samconfig.toml            # SAM CLI configuration
├── samconfig-dev.toml        # Development environment config
└── events/                   # Test events for local testing
    ├── sample-request.json   # Simple function example
    └── class-example.json    # Class-based code example
```

## Quick Start

**Prerequisites:** AWS CLI, SAM CLI, Python 3.9, Anthropic API key

```bash
# 1. Navigate here
cd infrastructure/sam

# 2. Update your API key in samconfig.toml
# Replace REPLACE_ME with your Anthropic API key

# 3. Build and deploy
sam build
sam deploy --guided

# 4. Test your endpoint
curl -X POST <YOUR-API-ENDPOINT> \
  -H "Content-Type: application/json" \
  -d '{"file_path": "test.py", "file_content": "def hello(): pass"}'
```

## Documentation

- **New to SAM?** → Read [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)
- **Need quick commands?** → Check [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
- **Understanding the architecture?** → See [template.yaml](template.yaml) comments

## What Gets Deployed

When you run `sam deploy`, these AWS resources are created:

1. **Lambda Function** (`doc-generator-dev`)
   - Runtime: Python 3.9
   - Memory: 512 MB
   - Timeout: 5 minutes
   - Handler: `lambda_function.lambda_handler`

2. **API Gateway** (`doc-generator-api-dev`)
   - REST API with `/document` endpoint
   - CORS enabled
   - Throttling: 50 requests/sec, 100 burst

3. **CloudWatch Resources**
   - Log groups for Lambda and API Gateway
   - Monitoring dashboard
   - 7-day log retention

4. **IAM Roles**
   - Lambda execution role
   - CloudWatch permissions

**Total resources:** ~6 AWS resources

## Local Development

### Test Locally Before Deploying

```bash
# Start local API (requires Docker)
sam local start-api

# In another terminal
curl http://localhost:3000/document \
  -X POST \
  -H "Content-Type: application/json" \
  -d @events/sample-request.json
```

### Invoke Function Directly

```bash
sam local invoke -e events/sample-request.json
```

This tests your Lambda function without the API Gateway layer.

## Cost Estimate

**AWS Costs (Phase 1):**
- API Gateway: ~$3.50 per million requests
- Lambda: ~$0.20 per million requests
- CloudWatch: First 5GB free
- **Typical monthly cost:** <$5 for 1000 requests

**Claude API Costs:**
- ~$0.024 USD (~₹2) per 1000 lines
- This is your primary cost
- Tracked per request in CloudWatch logs

## Environment Variables

Set in the Lambda function via `template.yaml`:

- `ANTHROPIC_API_KEY` - Your Claude API key
- `COST_PER_1M_INPUT_TOKENS` - Input token cost (default: 3.00 USD)
- `COST_PER_1M_OUTPUT_TOKENS` - Output token cost (default: 15.00 USD)
- `CLAUDE_MODEL` - Model to use (default: claude-sonnet-4-20250514)
- `MAX_TOKENS` - Max output tokens (default: 4096)
- `TEMPERATURE` - Creativity (default: 0.0 for deterministic)
- `LOG_LEVEL` - Logging verbosity (default: INFO)
- `ENVIRONMENT` - Deployment environment (dev/staging/prod)

## Monitoring

### View Logs
```bash
sam logs --tail
```

### CloudWatch Dashboard
After deployment, find your dashboard:
- AWS Console → CloudWatch → Dashboards
- Dashboard name: `doc-generator-dev`
- Metrics: Invocations, Errors, Duration, Throttles

### API Gateway Metrics
- AWS Console → API Gateway → `doc-generator-api-dev`
- Metrics: Request count, 4xx/5xx errors, latency

## Updating Deployment

### Change Code
```bash
# Edit src/phase1_poc/lambda_function.py
sam build
sam deploy
```

### Change Configuration
```bash
# Edit template.yaml or samconfig.toml
sam deploy
```

### Change Environment Variables
```bash
sam deploy --parameter-overrides "CostPerMillionInputTokens=4.0"
```

## Multiple Environments

Deploy to dev, staging, and prod:

```bash
# Dev
sam deploy --parameter-overrides "Environment=dev"

# Staging
sam deploy --stack-name doc-gen-staging \
  --parameter-overrides "Environment=staging"

# Prod
sam deploy --stack-name doc-gen-prod \
  --parameter-overrides "Environment=prod"
```

Each environment is an independent CloudFormation stack.

## Cleanup

Delete all resources:

```bash
sam delete --stack-name doc-generator-phase1
```

This removes:
- Lambda function
- API Gateway
- CloudWatch logs and dashboards
- IAM roles
- Everything created by SAM

## Troubleshooting

### Common Issues

**"Docker not running"**
- Start Docker Desktop
- Run: `docker ps` to verify

**"Access Denied"**
- Check AWS credentials: `aws sts get-caller-identity`
- Ensure IAM permissions for CloudFormation, Lambda, API Gateway

**"Module not found"**
- Check `requirements.txt` in `src/phase1_poc/`
- Run: `sam build` to reinstall dependencies

**"API returns 403"**
- Check API key in samconfig.toml
- Redeploy: `sam deploy`

**"Timeout error"**
- File too large for Phase 1 (>5000 lines)
- Expected behavior - this is what Phase 2 demonstrates!

### Debug Mode

```bash
sam build --debug
sam deploy --debug
sam local start-api --debug
```

## Testing

### Test Events Included

1. **sample-request.json** - Simple function example
2. **class-example.json** - Class-based code

### Add Your Own Test Events

Create `events/my-test.json`:
```json
{
  "body": "{\"file_path\": \"my_code.py\", \"file_content\": \"...\"}"
}
```

Test it:
```bash
sam local invoke -e events/my-test.json
```

## Security Best Practices

1. **Never commit API keys** - Use parameters, not hardcoded values
2. **Use Secrets Manager** - For production, store keys in AWS Secrets Manager
3. **Enable API authentication** - Add API keys or IAM auth in production
4. **Restrict CORS** - Change `AllowOrigin: '*'` to specific domains
5. **Review IAM permissions** - Use least-privilege principles
6. **Enable encryption** - Lambda environment variables encrypted at rest
7. **Monitor CloudWatch** - Set up alerts for errors/throttles

## CI/CD Integration

### GitHub Actions

Add to `.github/workflows/deploy.yml`:

```yaml
name: Deploy Phase 1
on:
  push:
    branches: [main]
    paths:
      - 'src/phase1_poc/**'
      - 'infrastructure/sam/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: aws-actions/setup-sam@v2
      - uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - run: |
          cd infrastructure/sam
          sam build
          sam deploy --no-confirm-changeset
```

## Advanced Features

### Enable X-Ray Tracing

Uncomment in `template.yaml`:
```yaml
Globals:
  Function:
    Tracing: Active
```

### Add Custom Domain

```yaml
DocumentationApi:
  Type: AWS::Serverless::Api
  Properties:
    Domain:
      DomainName: api.yourdomain.com
      CertificateArn: arn:aws:acm:...
```

### Add Lambda Layers

For shared dependencies:
```yaml
DocumentationGeneratorFunction:
  Properties:
    Layers:
      - arn:aws:lambda:us-east-1:123456789:layer:my-layer:1
```

## Next Steps

After deploying Phase 1:

1. ✅ Test with sample files
2. ✅ Monitor in CloudWatch
3. ✅ Check costs in Cost Explorer
4. ⬜ Move to Phase 2 (break it!)
5. ⬜ Implement Phase 3 (production features)

## Resources

- [SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/)
- [SAM CLI Reference](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-command-reference.html)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Anthropic API Docs](https://docs.anthropic.com/)

## Support

**Issues?** Open a GitHub issue or check:
- [Deployment Guide](DEPLOYMENT-GUIDE.md) for detailed walkthrough
- [Quick Reference](QUICK-REFERENCE.md) for command cheat sheet
- CloudWatch logs: `sam logs --tail`
- CloudFormation events in AWS Console

---

**Ready to deploy?** Start with [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)!

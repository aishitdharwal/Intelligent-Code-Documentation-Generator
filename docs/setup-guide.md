# Setup Guide

## 📋 Prerequisites

### Required
- **Python 3.9+** - [Download](https://www.python.org/downloads/)
- **AWS Account** - [Sign up](https://aws.amazon.com/)
- **Anthropic API Key** - [Get yours](https://console.anthropic.com/)

### Optional (for deployment)
- **AWS CLI** configured with credentials
- **Terraform 1.0+** - [Install](https://www.terraform.io/downloads)
- **Docker** - [Install](https://docs.docker.com/get-docker/)
- **SAM CLI** - [Install](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)

---

## 🚀 Quick Start (5 minutes)

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/Intelligent-Code-Documentation-Generator.git
cd Intelligent-Code-Documentation-Generator
```

### 2. Set Up Python Environment

```bash
# Create virtual environment
python -m venv venv

# Activate it
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Configure Environment Variables

```bash
# Copy example env file
cp .env.example .env

# Edit .env and add your Anthropic API key
# You can get one at: https://console.anthropic.com/
```

Edit `.env`:
```bash
ANTHROPIC_API_KEY=your_actual_api_key_here
```

### 4. Test Locally (No AWS Required)

```bash
# Test with sample file
python src/phase1_poc/test_local.py

# Or test with your own file
python src/phase1_poc/lambda_function.py --file /path/to/your/file.py
```

**Expected Output:**
```
================================================================================
RESPONSE
================================================================================

Request ID: abc-123-def
Status: completed
Total Cost: $0.0120 USD
Total Tokens: 1,234
Processing Time: 4.56s

--------------------------------------------------------------------------------
DOCUMENTATION
--------------------------------------------------------------------------------
# Calculator Module Documentation
...
================================================================================
```

🎉 **Success!** You've generated your first documentation locally.

---

## 🔧 Detailed Setup

### Python Environment Setup

#### Option 1: Using venv (Recommended)

```bash
python -m venv venv
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate  # Windows

pip install -r requirements.txt
pip install -r requirements-dev.txt  # For development
```

#### Option 2: Using conda

```bash
conda create -n code-doc python=3.9
conda activate code-doc
pip install -r requirements.txt
```

#### Option 3: Using pipenv

```bash
pipenv install
pipenv shell
```

---

### Environment Variables

Create a `.env` file with the following variables:

```bash
# Required
ANTHROPIC_API_KEY=sk-ant-xxx

# Optional (has defaults)
AWS_REGION=us-east-1
CLAUDE_MODEL=claude-3-5-sonnet-20241022
CLAUDE_MAX_TOKENS=8192
CLAUDE_TEMPERATURE=0.3

# Cost Configuration (in USD)
COST_PER_1M_INPUT_TOKENS=3.00
COST_PER_1M_OUTPUT_TOKENS=15.00

# Feature Flags
ENABLE_COST_TRACKING=true
ENABLE_CACHING=true
LOCAL_MODE=true
DEBUG=false
```

---

## ☁️ AWS Setup (For Deployment)

### 1. Install and Configure AWS CLI

```bash
# Install AWS CLI
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Download from: https://aws.amazon.com/cli/

# Configure AWS credentials
aws configure
```

Enter your AWS credentials:
```
AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_KEY
Default region name: us-east-1
Default output format: json
```

### 2. Verify AWS Access

```bash
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-name"
}
```

---

## 🏗️ Infrastructure Setup

### Phase 1: Lambda-Only Deployment

#### Using Terraform

```bash
cd infrastructure/terraform/phase1

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy (costs ~₹200-500/month)
terraform apply
```

**Resources Created:**
- Lambda function (512MB, 5min timeout)
- API Gateway REST API
- CloudWatch Log Group
- IAM roles

#### Using AWS SAM (Alternative)

```bash
# Build the application
sam build

# Deploy guided (first time)
sam deploy --guided

# Or deploy with parameters
sam deploy \
  --parameter-overrides \
    AnthropicApiKey=$ANTHROPIC_API_KEY
```

---

### Phase 3: Full Production Deployment

```bash
cd infrastructure/terraform/phase3

# Initialize
terraform init

# Review
terraform plan

# Deploy (costs ~₹2,000-5,000/month with auto-scaling)
terraform apply
```

**Additional Resources:**
- ECS Fargate cluster
- DynamoDB table (caching)
- S3 bucket (documentation storage)
- Application Load Balancer
- Auto-scaling policies
- CloudWatch dashboards

---

## 🧪 Testing Your Setup

### 1. Test Local Python Environment

```bash
# Check Python version
python --version  # Should be 3.9+

# Test imports
python -c "from anthropic import Anthropic; print('✓ Anthropic SDK installed')"
python -c "import boto3; print('✓ Boto3 installed')"
```

### 2. Test Anthropic API Connection

```bash
# Create test script
cat > test_anthropic.py << 'EOF'
from anthropic import Anthropic
import os
from dotenv import load_dotenv

load_dotenv()
client = Anthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))

response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    max_tokens=100,
    messages=[{"role": "user", "content": "Hello!"}]
)

print("✓ Anthropic API connection successful!")
print(f"Response: {response.content[0].text}")
EOF

python test_anthropic.py
```

### 3. Run Unit Tests

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run tests
pytest tests/unit/

# With coverage
pytest --cov=src tests/unit/
```

### 4. Test Lambda Function Locally

```bash
# Using SAM Local
sam local invoke DocumentGeneratorFunction \
  --event tests/events/test_event.json

# Using test script
python src/phase1_poc/test_local.py
```

---

## 🐛 Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'anthropic'"

**Solution:**
```bash
pip install -r requirements.txt
```

### Issue: "Anthropic API key is required"

**Solution:**
```bash
# Check if .env file exists and has the key
cat .env | grep ANTHROPIC_API_KEY

# If not, add it
echo "ANTHROPIC_API_KEY=your_key_here" >> .env
```

### Issue: "AWS credentials not found"

**Solution:**
```bash
# Configure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
```

### Issue: Lambda deployment fails

**Solution:**
```bash
# Check AWS permissions
aws iam get-user

# Verify Terraform state
cd infrastructure/terraform/phase1
terraform plan

# Check CloudWatch logs
aws logs tail /aws/lambda/code-doc-generator --follow
```

### Issue: High API costs

**Solution:**
- Check `ENABLE_CACHING=true` in `.env`
- Verify cache is working: check DynamoDB table
- Monitor costs: `aws cloudwatch get-metric-statistics ...`
- Set budget alerts in AWS Billing

---

## 📊 Verify Setup

Run this checklist to verify everything is working:

```bash
# 1. Python environment
python --version  # ✓ 3.9+

# 2. Dependencies installed
pip list | grep anthropic  # ✓ Should show version

# 3. Environment variables
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print('API Key:', 'SET' if os.getenv('ANTHROPIC_API_KEY') else 'NOT SET')"  # ✓ Should say "SET"

# 4. Local test works
python src/phase1_poc/test_local.py  # ✓ Should generate docs

# 5. AWS access (if deploying)
aws sts get-caller-identity  # ✓ Should show your account

# 6. Terraform (if deploying)
terraform version  # ✓ Should show version
```

---

## 🎯 Next Steps

After setup is complete:

1. **Test Locally**: Run `python src/phase1_poc/test_local.py`
2. **Read Documentation**: Check `docs/architecture/phase1-poc.md`
3. **Deploy Phase 1**: Follow deployment guide above
4. **Break It**: Try Phase 2 breaking scenarios
5. **Optimize**: Build Phase 3 production features

---

## 💡 Tips

- Start with **local testing** before deploying to AWS
- Use **cost tracking** from day 1 to avoid surprises
- Test with **small files first** (< 1000 lines)
- Enable **caching** to reduce costs by 80%
- Monitor **CloudWatch logs** when things go wrong
- Set **billing alerts** in AWS ($10, $50, $100 thresholds)

---

## 📚 Additional Resources

- [Anthropic Documentation](https://docs.anthropic.com/)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Project Architecture](docs/architecture/)

---

## 🆘 Getting Help

If you're stuck:

1. Check [Troubleshooting](#-troubleshooting) section above
2. Review logs: `aws logs tail /aws/lambda/code-doc-generator --follow`
3. Search [GitHub Issues](https://github.com/yourusername/Intelligent-Code-Documentation-Generator/issues)
4. Create a new issue with error details

---

**Ready to start?** Run: `python src/phase1_poc/test_local.py` 🚀

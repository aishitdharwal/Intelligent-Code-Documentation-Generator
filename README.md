# 🤖 Intelligent Code Documentation Generator

> An AI-powered system that automatically generates comprehensive documentation for Python codebases using Claude API and AWS Lambda.

**Part of Production AI Engineering Cohort - Week 1 Project**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-orange.svg)](https://aws.amazon.com/lambda/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Learning Journey](#learning-journey)
- [Project Phases](#project-phases)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Cost Analysis](#cost-analysis)
- [Production Features](#production-features)
- [Testing](#testing)
- [Deployment](#deployment)
- [Project Structure](#project-structure)

---

## 🎯 Overview

This project demonstrates how to build, break, and scale an AI-powered code documentation system from a simple POC to a production-ready solution. You'll experience real-world challenges like API rate limits, memory overflow, and cost optimization - then learn how to solve them properly.

### What This Project Teaches

**Week 1 Core Learning Outcomes:**
- Build serverless AI applications with AWS Lambda + Claude API
- Handle large context windows and token management
- Implement cost tracking and optimization (₹240 for 50,000 lines)
- Scale from single-file to full repository processing
- Deploy production-ready infrastructure with monitoring

### Real-World Impact

- **Point it at 50,000 lines of undocumented Python** → Get comprehensive docs in 8 minutes for ₹240
- **Integrate as GitHub Action** → Every PR gets auto-documented (companies pay ₹8L/year for this)
- **Cost Optimization** → Reduce API costs from ₹4,000 to ₹240 per repo with smart caching

---

## 🚀 Learning Journey

### The Build → Break → Fix Approach

#### Phase 1: POC (Days 1-2)
✅ **Build** a basic documentation generator
- Single Python file analysis
- Direct Claude API integration
- Simple Lambda function
- Works perfectly for small files

#### Phase 2: Breaking Point (Day 3)
💥 **Break** it intentionally
- Point at 50,000-line codebase → **CRASHES**
- Problems you'll encounter:
  - API rate limits (429 errors)
  - Memory overflow (Lambda timeout)
  - Cost explosion (₹4,000+ per repo)
  - No visibility into what went wrong

#### Phase 3: Production Ready (Days 4-5)
⚡ **Fix** with production patterns
- Chunking strategies for large codebases
- Rate limiting and retry logic
- Caching layer (80% cost reduction)
- Parallel processing with ECS
- CloudWatch monitoring and alerts
- Auto-scaling infrastructure

---

## 📊 Project Phases

### Phase 1: POC - Simple Lambda + Claude API

**Goal:** Process a single Python file and generate documentation

**Stack:**
- AWS Lambda (Python 3.9)
- Claude API (Anthropic)
- API Gateway
- Basic cost tracking

**What Works:**
- Analyzes Python files up to 5,000 lines
- Generates function-level documentation
- Extracts docstrings and comments
- Returns structured markdown output

**Cost:** ~₹20 per file (average 1,000 lines)

**Time:** 30-60 seconds per file

---

### Phase 2: Breaking Scenarios

**What Happens When We Scale:**

1. **Large Repository (50,000 lines)**
   - Lambda timeout (15-minute limit)
   - Memory exhaustion (3GB limit)
   - Cost: ₹4,000+ (no caching)

2. **API Rate Limits**
   - 429 errors from Claude API
   - No retry logic = lost requests
   - Inconsistent results

3. **No Monitoring**
   - Can't see where time is spent
   - No cost breakdown per file
   - Silent failures

**Documentation:** See `docs/architecture/phase2-breaking.md`

---

### Phase 3: Production Features

**Core Production Capabilities:**

#### ✅ Basic Features (Must-Have)
1. **Intelligent Chunking**
   - Split large files into manageable chunks
   - Maintain context between chunks
   - Configurable chunk size (default: 2,000 lines)

2. **Cost Tracking**
   - Token counting per API call
   - Cost per file/repository
   - CloudWatch metrics integration

3. **Rate Limiting**
   - Exponential backoff
   - Request queuing
   - Configurable limits

4. **Caching Layer**
   - Hash-based file caching
   - DynamoDB for cache storage
   - 80% cost reduction on re-runs

5. **Basic Monitoring**
   - CloudWatch logs
   - Error tracking
   - Execution time metrics

#### 🚀 Advanced Features (Nice-to-Have)
6. **Parallel Processing**
   - ECS Fargate for large repos
   - Process multiple files concurrently
   - Auto-scaling based on queue depth

7. **Result Storage**
   - S3 for generated documentation
   - Version control for docs
   - HTML/Markdown/JSON output formats

8. **GitHub Action Integration**
   - Auto-document on PR
   - Comment with documentation diff
   - Commit documentation updates

9. **Advanced Monitoring**
   - X-Ray distributed tracing
   - Cost per user/repository
   - Quality metrics (coverage %)

10. **Multi-Language Support**
    - JavaScript/TypeScript
    - Java
    - Go

**Cost After Optimization:** ₹240 per 50,000-line repository (vs ₹4,000)

**Time:** 8 minutes for 50,000 lines

---

## 🛠 Tech Stack

### Core AI Stack
- **LLM:** Claude 3.5 Sonnet (Anthropic API)
- **Prompt Engineering:** Few-shot learning, structured outputs
- **Token Management:** Tiktoken for counting
- **Context Window:** Up to 200K tokens

### AWS Infrastructure
- **Compute:** AWS Lambda (Phase 1), ECS Fargate (Phase 3)
- **API:** API Gateway REST API
- **Storage:** S3 (docs), DynamoDB (cache)
- **Monitoring:** CloudWatch, X-Ray
- **Secrets:** AWS Secrets Manager
- **Orchestration:** Step Functions (Phase 3)

### Development Stack
- **Language:** Python 3.9+
- **IaC:** Terraform
- **Testing:** pytest
- **CI/CD:** GitHub Actions
- **Local Dev:** SAM CLI

---

## 🏗 Architecture

### Phase 1: Simple Lambda Architecture

```
┌─────────────┐
│   User/API  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  API Gateway    │
└──────┬──────────┘
       │
       ▼
┌─────────────────────────┐
│  Lambda Function        │
│  ├─ Code Analyzer       │
│  ├─ Claude Client       │
│  └─ Cost Tracker        │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────┐
│  Claude API     │
└─────────────────┘
```

### Phase 3: Production Architecture

```
┌──────────┐
│   User   │
└────┬─────┘
     │
     ▼
┌────────────────┐     ┌──────────────┐
│  API Gateway   │────▶│  CloudWatch  │
└────┬───────────┘     └──────────────┘
     │
     ▼
┌────────────────────────┐
│   Lambda (Router)      │
│   ├─ File size check   │
│   └─ Cache lookup      │
└────┬───────────────────┘
     │
     ├─────────────┬──────────────┐
     ▼             ▼              ▼
┌─────────┐  ┌─────────┐   ┌──────────┐
│ Lambda  │  │   ECS   │   │DynamoDB  │
│ (Small) │  │Fargate  │   │  Cache   │
└────┬────┘  │(Large)  │   └──────────┘
     │       └────┬────┘
     │            │
     ▼            ▼
┌──────────────────────┐
│    Claude API        │
└──────────────────────┘
           │
           ▼
┌──────────────────────┐
│  S3 (Documentation)  │
└──────────────────────┘
```

**Detailed Architecture Diagrams:** See `docs/architecture/`

---

## ⚡ Quick Start

### Prerequisites

```bash
# Required
- Python 3.9+
- AWS Account with CLI configured
- Anthropic API Key
- Terraform 1.0+

# Optional
- Docker (for local testing)
- SAM CLI (for local Lambda development)
```

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/Intelligent-Code-Documentation-Generator.git
cd Intelligent-Code-Documentation-Generator

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your API keys
```

### Environment Variables

```bash
ANTHROPIC_API_KEY=your_key_here
AWS_REGION=us-east-1
COST_PER_1K_INPUT_TOKENS=0.003  # $3 per million tokens
COST_PER_1K_OUTPUT_TOKENS=0.015  # $15 per million tokens
```

### Local Testing (Phase 1)

```bash
# Run the POC locally
python src/phase1_poc/test_local.py

# Test with sample file
python src/phase1_poc/lambda_function.py --file tests/test_data/small_repo/sample.py
```

### Deploy Phase 1 (Lambda Only)

```bash
cd infrastructure/terraform/phase1
terraform init
terraform plan
terraform apply

# Test the deployed API
curl -X POST https://your-api-gateway-url/dev/document \
  -H "Content-Type: application/json" \
  -d '{"file_path": "sample.py", "file_content": "..."}'
```

---

## 💰 Cost Analysis

### Phase 1 (POC) - No Optimization

| Metric | Cost |
|--------|------|
| Single file (1,000 lines) | ₹20 |
| Medium repo (10,000 lines) | ₹400 |
| Large repo (50,000 lines) | **₹4,000** |
| **Monthly (100 repos)** | **₹40,000** |

**Problems:**
- No caching (re-process identical files)
- No chunking strategy (large context windows)
- Inefficient prompts (verbose outputs)

---

### Phase 3 (Production) - Optimized

| Metric | Cost |
|--------|------|
| Single file (1,000 lines) | ₹8 |
| Medium repo (10,000 lines) | ₹80 |
| Large repo (50,000 lines) | **₹240** |
| **Monthly (100 repos, 50% cache hit)** | **₹6,000** |

**Optimizations Applied:**
- ✅ 80% cost reduction via caching
- ✅ Efficient chunking (smaller context windows)
- ✅ Optimized prompts (structured outputs)
- ✅ Batch processing (reduced API calls)

**Savings:** ₹34,000/month (85% reduction)

**Detailed Cost Breakdown:** See `docs/cost-analysis.md`

---

## 🎯 Production Features

### Currently Implemented

#### Phase 1 (POC)
- [x] Single file analysis
- [x] Claude API integration
- [x] Basic cost tracking
- [x] Lambda deployment
- [x] API Gateway endpoint

#### Phase 3 (Production - Basic)
- [x] Intelligent chunking
- [x] Cost tracking with CloudWatch
- [x] Rate limiting with exponential backoff
- [x] DynamoDB caching layer
- [x] Error handling and logging

### Roadmap (Advanced Features)

- [ ] ECS Fargate for parallel processing
- [ ] S3 documentation storage with versioning
- [ ] GitHub Action integration
- [ ] X-Ray distributed tracing
- [ ] Multi-language support (JS, Java)
- [ ] Quality metrics dashboard
- [ ] Auto-scaling based on queue depth
- [ ] Cost optimization alerts
- [ ] Documentation diff on PRs
- [ ] Webhook integrations

---

## 🧪 Testing

### Unit Tests

```bash
# Run all tests
pytest tests/unit/

# Run with coverage
pytest --cov=src tests/unit/

# Specific test
pytest tests/unit/test_code_analyzer.py
```

### Integration Tests

```bash
# Test complete flow
pytest tests/integration/test_end_to_end.py

# Test with sample repositories
pytest tests/integration/test_repositories.py
```

### Load Testing (Breaking Phase)

```bash
# Test with large repository
python tests/integration/test_large_repo.py

# Simulate rate limits
python tests/integration/test_rate_limits.py
```

---

## 🚀 Deployment

### Phase 1 Deployment (Lambda Only)

```bash
cd infrastructure/terraform/phase1
terraform init
terraform apply -var="anthropic_api_key=$ANTHROPIC_API_KEY"
```

**Resources Created:**
- Lambda function (512MB, 5min timeout)
- API Gateway REST API
- CloudWatch Log Group
- IAM roles and policies

**Estimated Cost:** ₹200-500/month (based on usage)

---

### Phase 3 Deployment (Production)

```bash
cd infrastructure/terraform/phase3
terraform init
terraform apply
```

**Additional Resources:**
- ECS Fargate cluster
- DynamoDB table (caching)
- S3 bucket (documentation storage)
- Application Load Balancer
- Auto-scaling policies
- CloudWatch dashboards

**Estimated Cost:** ₹2,000-5,000/month (with auto-scaling)

---

## 📁 Project Structure

```
Intelligent-Code-Documentation-Generator/
├── README.md                          # This file
├── .gitignore                         # Python/AWS gitignore
├── requirements.txt                   # Python dependencies
├── requirements-dev.txt               # Development dependencies
│
├── src/
│   ├── phase1_poc/                    # Phase 1: Simple POC
│   │   ├── lambda_function.py         # Main Lambda handler
│   │   ├── code_analyzer.py           # Python code parsing
│   │   ├── claude_client.py           # Claude API wrapper
│   │   ├── cost_tracker.py            # Token/cost tracking
│   │   └── test_local.py              # Local testing script
│   │
│   ├── phase2_breaking/               # Phase 2: Breaking scenarios
│   │   ├── large_repo_test.py         # Test large repositories
│   │   ├── rate_limit_test.py         # Simulate rate limits
│   │   └── breaking_scenarios.md      # Documentation of failures
│   │
│   ├── phase3_production/             # Phase 3: Production code
│   │   ├── lambda_function.py         # Optimized Lambda handler
│   │   ├── chunking_strategy.py       # Smart file chunking
│   │   ├── caching_layer.py           # DynamoDB cache
│   │   ├── rate_limiter.py            # Rate limiting logic
│   │   ├── parallel_processor.py      # ECS task coordination
│   │   ├── cost_tracker.py            # Enhanced cost tracking
│   │   └── monitoring.py              # CloudWatch metrics
│   │
│   └── shared/                        # Shared utilities
│       ├── models.py                  # Data models (Pydantic)
│       ├── config.py                  # Configuration
│       └── utils.py                   # Helper functions
│
├── infrastructure/
│   ├── terraform/
│   │   ├── phase1/                    # Phase 1 infrastructure
│   │   │   ├── main.tf
│   │   │   ├── lambda.tf
│   │   │   ├── api_gateway.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── phase3/                    # Phase 3 infrastructure
│   │   │   ├── main.tf
│   │   │   ├── ecs.tf
│   │   │   ├── dynamodb.tf
│   │   │   ├── s3.tf
│   │   │   └── monitoring.tf
│   │   │
│   │   └── modules/                   # Reusable modules
│   │       ├── lambda/
│   │       ├── ecs/
│   │       └── monitoring/
│   │
│   └── scripts/
│       ├── deploy.sh                  # Deployment script
│       ├── test.sh                    # Testing script
│       └── cost_estimate.sh           # Cost estimation
│
├── tests/
│   ├── unit/                          # Unit tests
│   │   ├── test_code_analyzer.py
│   │   ├── test_claude_client.py
│   │   └── test_cost_tracker.py
│   │
│   ├── integration/                   # Integration tests
│   │   ├── test_end_to_end.py
│   │   └── test_repositories.py
│   │
│   └── test_data/                     # Test data
│       ├── small_repo/                # Small test files
│       └── large_repo/                # Large test repository
│
├── github_action/
│   └── document-on-pr.yml             # GitHub Action workflow
│
└── docs/
    ├── architecture/
    │   ├── phase1-poc.md              # Phase 1 architecture
    │   ├── phase2-breaking.md         # Breaking scenarios
    │   ├── phase3-production.md       # Production architecture
    │   └── diagrams/                  # Architecture diagrams
    │
    ├── cost-analysis.md               # Detailed cost breakdown
    ├── setup-guide.md                 # Setup instructions
    └── troubleshooting.md             # Common issues and fixes
```

---

## 📚 Documentation

- **[Setup Guide](docs/setup-guide.md)** - Detailed setup instructions
- **[Architecture Overview](docs/architecture/)** - System architecture for each phase
- **[Cost Analysis](docs/cost-analysis.md)** - Detailed cost breakdown and optimization
- **[Breaking Scenarios](docs/architecture/phase2-breaking.md)** - What fails and why
- **[Production Patterns](docs/architecture/phase3-production.md)** - Production best practices

---

## 🎓 Learning Outcomes

By completing this project, you will:

✅ Build serverless AI applications with AWS Lambda + Claude API  
✅ Handle large context windows and token optimization  
✅ Implement production-ready cost tracking (per request, per user)  
✅ Scale from single-file to full repository processing  
✅ Deploy with Infrastructure as Code (Terraform)  
✅ Add monitoring and observability (CloudWatch, X-Ray)  
✅ Optimize costs by 85% using caching and chunking  
✅ Handle API rate limits with exponential backoff  
✅ Process 50,000 lines in 8 minutes for ₹240  
✅ Build GitHub Actions for automated documentation  

---

## 🤝 Contributing

This is a learning project, but contributions are welcome!

```bash
# Fork the repo
# Create a feature branch
git checkout -b feature/amazing-feature

# Make your changes and commit
git commit -m "Add amazing feature"

# Push and create a PR
git push origin feature/amazing-feature
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Anthropic** for Claude API
- **AWS** for serverless infrastructure
- **Production AI Engineering Cohort** for the project structure

---

## 📧 Contact

**Project Author:** Aishit Dharwal  
**Cohort:** Production AI Engineering - Week 1  
**Project:** Intelligent Code Documentation Generator

---

## 🔗 Links

- [Claude API Documentation](https://docs.anthropic.com/)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**Built with ❤️ as part of Production AI Engineering Cohort**

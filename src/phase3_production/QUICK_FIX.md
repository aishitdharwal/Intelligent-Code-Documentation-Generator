# Quick Fix for Pydantic Import Error

The issue is that SAM isn't packaging dependencies correctly. Here's the fix:

## Option 1: Use Docker Build (Recommended)

```bash
cd infrastructure/sam

# Build using Docker container (ensures correct environment)
sam build --template template-phase3.yaml --use-container

# Deploy
sam deploy --template template-phase3.yaml
```

The `--use-container` flag makes SAM build inside a Docker container that matches the Lambda environment exactly.

## Option 2: Manual Package Installation

```bash
cd src/phase3_production

# Install dependencies to a local directory
pip3 install -r requirements.txt -t . --upgrade

# Now deploy
cd ../../infrastructure/sam
sam build --template template-phase3.yaml
sam deploy --template template-phase3.yaml
```

This installs pydantic and anthropic directly into the phase3_production folder.

## Option 3: Use Phase 1 (Which Works)

If Phase 3 is giving issues, we can quickly verify caching works by:

```bash
# Go back to Phase 1
cd infrastructure/sam

# Deploy Phase 1 (which already works)
sam deploy --template template.yaml

# Then manually test the cache concept
```

## Verify After Fix

After running Option 1 or 2, test again:

```bash
cd src/phase3_production
python test_phase3.py https://YOUR-ENDPOINT/dev/document
```

## What's Happening

SAM needs to:
1. Install `pydantic`, `anthropic`, `boto3` from requirements.txt
2. Package them with your Lambda code
3. Deploy to AWS

The `--use-container` flag ensures this happens in the correct Python environment.

Try **Option 1** first - it's the most reliable!

#!/bin/bash
# Interactive Phase 3 deployment

echo "=========================================="
echo "Phase 3 Deployment"
echo "=========================================="
echo ""

# Prompt for API key
echo "Please enter your Anthropic API Key:"
read -s ANTHROPIC_KEY
echo ""

if [ -z "$ANTHROPIC_KEY" ]; then
    echo "❌ API Key is required"
    exit 1
fi

cd infrastructure/sam

echo "Cleaning previous build..."
rm -rf .aws-sam

echo ""
echo "Building with Docker..."
sam build --template template-phase3.yaml --use-container

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "Deploying Phase 3..."

sam deploy \
    --template template-phase3.yaml \
    --stack-name doc-generator-phase3 \
    --capabilities CAPABILITY_IAM \
    --resolve-s3 \
    --parameter-overrides \
        AnthropicApiKey="$ANTHROPIC_KEY" \
        Environment=dev \
        CostPerMillionInputTokens=3.00 \
        CostPerMillionOutputTokens=15.00 \
        CacheTTLHours=24

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ DEPLOYMENT SUCCESSFUL!"
    echo "=========================================="
    echo ""
    echo "Your Phase 3 API endpoint:"
    echo ""
else
    echo ""
    echo "❌ Deployment failed"
    echo ""
    echo "Check CloudFormation console for details:"
    echo "https://console.aws.amazon.com/cloudformation"
fi

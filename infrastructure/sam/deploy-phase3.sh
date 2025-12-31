#!/bin/bash
# Phase 3 - Build and Deploy Script with NEW stack name

echo "=========================================="
echo "Building Phase 3 with correct dependencies"
echo "=========================================="
echo ""

cd infrastructure/sam

# Clean old build
echo "Cleaning previous build..."
rm -rf .aws-sam

# Build with container
echo "Building with Docker container (ensures Linux x86_64 compatibility)..."
sam build --template template-phase3.yaml --use-container

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Deploying to NEW stack: doc-generator-phase3..."
    
    # Deploy with explicit stack name
    sam deploy \
        --template template-phase3.yaml \
        --stack-name doc-generator-phase3 \
        --capabilities CAPABILITY_IAM \
        --resolve-s3 \
        --parameter-overrides \
            Environment=dev
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "=========================================="
        echo "✅ DEPLOYMENT SUCCESSFUL!"
        echo "=========================================="
        echo ""
        echo "Get your Phase 3 API endpoint:"
        aws cloudformation describe-stacks \
            --stack-name doc-generator-phase3 \
            --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
            --output text
    else
        echo ""
        echo "❌ Deployment failed"
    fi
else
    echo ""
    echo "❌ Build failed"
fi

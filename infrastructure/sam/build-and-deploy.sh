# Phase 3 - Build and Deploy Script
# This ensures dependencies are built for the correct platform (Linux x86_64)

echo "=========================================="
echo "Building Phase 3 with correct dependencies"
echo "=========================================="
echo ""

cd infrastructure/sam

# Clean old build
echo "Cleaning previous build..."
rm -rf .aws-sam

# CRITICAL: Use --use-container to build for Lambda's Linux environment
echo "Building with Docker container (ensures Linux x86_64 compatibility)..."
sam build --template template-phase3.yaml --use-container

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Deploying..."
    sam deploy --template template-phase3.yaml
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "=========================================="
        echo "✅ DEPLOYMENT SUCCESSFUL!"
        echo "=========================================="
        echo ""
        echo "Get your API endpoint:"
        echo "  aws cloudformation describe-stacks --query 'Stacks[?contains(StackName, \`doc\`)].Outputs[?OutputKey==\`ApiEndpoint\`].OutputValue' --output text"
    else
        echo ""
        echo "❌ Deployment failed"
    fi
else
    echo ""
    echo "❌ Build failed"
    echo ""
    echo "If you don't have Docker, install it:"
    echo "  macOS: brew install --cask docker"
    echo "  Or download from: https://www.docker.com/products/docker-desktop"
fi

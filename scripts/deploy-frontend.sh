#!/bin/bash

# Frontend Deployment Script for S3 + CloudFront
# This script uploads the frontend and invalidates CloudFront cache

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
STACK_NAME="doc-generator-phase3"
REGION="ap-south-1"
FRONTEND_DIR="../frontend"
FRONTEND_FILE="$FRONTEND_DIR/index.html"
LOGO_FILE="$FRONTEND_DIR/logo.png"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Frontend Deployment Script${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check if frontend files exist
if [ ! -f "$FRONTEND_FILE" ]; then
    echo -e "${RED}Error: Frontend file not found at $FRONTEND_FILE${NC}"
    echo -e "${RED}Make sure you run this script from the scripts/ directory${NC}"
    exit 1
fi

if [ ! -f "$LOGO_FILE" ]; then
    echo -e "${RED}Error: Logo file not found at $LOGO_FILE${NC}"
    echo -e "${RED}Please make sure logo.png is in the frontend/ directory${NC}"
    exit 1
fi

# Get stack outputs
echo -e "${YELLOW}→ Getting CloudFormation stack outputs...${NC}"
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`FrontendBucketName`].OutputValue' \
    --output text)

DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
    --output text)

API_ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
    --output text)

FRONTEND_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`FrontendURL`].OutputValue' \
    --output text)

if [ -z "$BUCKET_NAME" ] || [ -z "$DISTRIBUTION_ID" ]; then
    echo -e "${RED}Error: Could not get stack outputs. Is the stack deployed?${NC}"
    echo -e "${YELLOW}Run: sam deploy --template template-phase3.yaml${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Stack outputs retrieved${NC}"
echo -e "  Bucket: ${BUCKET_NAME}"
echo -e "  Distribution: ${DISTRIBUTION_ID}"
echo -e "  API Endpoint: ${API_ENDPOINT}"
echo ""

# Update frontend with API endpoint
echo -e "${YELLOW}→ Updating frontend with API endpoint...${NC}"
TEMP_FILE="/tmp/index-updated.html"
sed "s|let API_ENDPOINT = .*|let API_ENDPOINT = '${API_ENDPOINT}';|" "$FRONTEND_FILE" > "$TEMP_FILE"
echo -e "${GREEN}✓ API endpoint injected${NC}"
echo ""

# Upload HTML to S3
echo -e "${YELLOW}→ Uploading index.html to S3...${NC}"
aws s3 cp "$TEMP_FILE" "s3://${BUCKET_NAME}/index.html" \
    --region $REGION \
    --content-type "text/html" \
    --cache-control "max-age=3600" \
    --metadata-directive REPLACE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ index.html uploaded successfully${NC}"
else
    echo -e "${RED}✗ index.html upload failed${NC}"
    exit 1
fi
echo ""

# Upload logo to S3
echo -e "${YELLOW}→ Uploading logo.png to S3...${NC}"
aws s3 cp "$LOGO_FILE" "s3://${BUCKET_NAME}/logo.png" \
    --region $REGION \
    --content-type "image/png" \
    --cache-control "max-age=86400" \
    --metadata-directive REPLACE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ logo.png uploaded successfully${NC}"
else
    echo -e "${RED}✗ logo.png upload failed${NC}"
    exit 1
fi
echo ""

# Invalidate CloudFront cache
echo -e "${YELLOW}→ Invalidating CloudFront cache...${NC}"
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Cache invalidation created: ${INVALIDATION_ID}${NC}"
    echo -e "  (Cache will be cleared in 1-2 minutes)"
else
    echo -e "${RED}✗ Invalidation failed${NC}"
    exit 1
fi
echo ""

# Clean up
rm -f "$TEMP_FILE"

# Success message
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${BLUE}Frontend URL:${NC}"
echo -e "  ${FRONTEND_URL}"
echo ""
echo -e "${BLUE}API Endpoint:${NC}"
echo -e "  ${API_ENDPOINT}"
echo ""
echo -e "${YELLOW}Note: CloudFront cache invalidation may take 1-2 minutes.${NC}"
echo -e "${YELLOW}If you don't see changes immediately, wait a moment and refresh.${NC}"
echo ""

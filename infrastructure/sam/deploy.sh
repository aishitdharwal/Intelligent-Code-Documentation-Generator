#!/bin/bash

# SAM Deployment Helper Script
# Makes it easy to deploy, test, and manage the Phase 1 documentation generator

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

error() {
    echo -e "${RED}✗ ${NC}$1"
}

warn() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check SAM CLI
    if ! command -v sam &> /dev/null; then
        error "SAM CLI not found. Install it first:"
        echo "  macOS: brew install aws-sam-cli"
        echo "  Linux: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
        exit 1
    fi
    success "SAM CLI found: $(sam --version)"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        error "AWS CLI not found. Install it first:"
        echo "  macOS: brew install awscli"
        echo "  Linux: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    success "AWS CLI found: $(aws --version)"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials not configured. Run: aws configure"
        exit 1
    fi
    success "AWS credentials configured"
    
    # Check Docker (for local testing)
    if command -v docker &> /dev/null; then
        if docker ps &> /dev/null; then
            success "Docker is running"
        else
            warn "Docker installed but not running (needed for local testing)"
        fi
    else
        warn "Docker not found (needed for local testing)"
    fi
    
    echo ""
}

# Build the application
build() {
    info "Building SAM application..."
    sam build --cached --parallel
    success "Build complete!"
    echo ""
}

# Deploy to AWS
deploy() {
    info "Deploying to AWS..."
    
    if [ "$1" == "guided" ]; then
        sam deploy --guided
    else
        sam deploy
    fi
    
    success "Deployment complete!"
    echo ""
    get_endpoint
}

# Get API endpoint
get_endpoint() {
    info "Getting API endpoint..."
    
    ENDPOINT=$(aws cloudformation describe-stacks \
        --stack-name doc-generator-phase1 \
        --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
        --output text 2>/dev/null)
    
    if [ -n "$ENDPOINT" ]; then
        success "API Endpoint: $ENDPOINT"
        echo ""
        echo "Test it with:"
        echo "  curl -X POST $ENDPOINT \\"
        echo "    -H 'Content-Type: application/json' \\"
        echo "    -d '{\"file_path\": \"test.py\", \"file_content\": \"def hello(): pass\"}'"
    else
        warn "Stack not deployed yet. Deploy first with: $0 deploy"
    fi
    echo ""
}

# Test locally
test_local() {
    info "Starting local API server..."
    warn "Make sure Docker is running!"
    echo ""
    echo "API will be available at: http://localhost:3000/document"
    echo ""
    echo "Test with:"
    echo "  curl -X POST http://localhost:3000/document \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d @events/sample-request.json"
    echo ""
    sam local start-api
}

# Test deployed API
test_deployed() {
    info "Testing deployed API..."
    
    ENDPOINT=$(aws cloudformation describe-stacks \
        --stack-name doc-generator-phase1 \
        --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
        --output text 2>/dev/null)
    
    if [ -z "$ENDPOINT" ]; then
        error "Stack not deployed. Deploy first with: $0 deploy"
        exit 1
    fi
    
    info "Sending test request to: $ENDPOINT"
    
    RESPONSE=$(curl -s -X POST "$ENDPOINT" \
        -H "Content-Type: application/json" \
        -d '{"file_path": "test.py", "file_content": "def hello(name):\n    return f\"Hello, {name}!\""}')
    
    if echo "$RESPONSE" | grep -q '"success": true'; then
        success "API is working!"
        echo ""
        echo "Response preview:"
        echo "$RESPONSE" | python3 -m json.tool | head -n 20
    else
        error "API test failed!"
        echo "$RESPONSE"
        exit 1
    fi
    echo ""
}

# View logs
logs() {
    info "Streaming CloudWatch logs (Ctrl+C to stop)..."
    sam logs --stack-name doc-generator-phase1 --tail
}

# Delete stack
delete() {
    warn "This will delete ALL resources!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" == "yes" ]; then
        info "Deleting stack..."
        sam delete --stack-name doc-generator-phase1 --no-prompts
        success "Stack deleted!"
    else
        info "Deletion cancelled"
    fi
    echo ""
}

# Validate template
validate() {
    info "Validating SAM template..."
    sam validate --lint
    success "Template is valid!"
    echo ""
}

# Show help
show_help() {
    echo "SAM Deployment Helper - Phase 1 Documentation Generator"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  check       Check prerequisites (SAM CLI, AWS CLI, Docker)"
    echo "  build       Build the SAM application"
    echo "  deploy      Deploy to AWS (use 'deploy guided' for first time)"
    echo "  test-local  Start local API server for testing"
    echo "  test        Test the deployed API"
    echo "  logs        Stream CloudWatch logs"
    echo "  endpoint    Get the API endpoint URL"
    echo "  validate    Validate the SAM template"
    echo "  delete      Delete the deployed stack"
    echo "  all         Check → Build → Deploy (quickstart)"
    echo ""
    echo "Examples:"
    echo "  $0 check                 # Verify prerequisites"
    echo "  $0 all                   # Full deployment"
    echo "  $0 deploy guided         # Interactive deployment"
    echo "  $0 test                  # Test deployed API"
    echo "  $0 logs                  # View logs"
    echo ""
}

# Main command handler
case "${1:-help}" in
    check)
        check_prerequisites
        ;;
    build)
        check_prerequisites
        build
        ;;
    deploy)
        check_prerequisites
        build
        deploy "$2"
        ;;
    test-local)
        check_prerequisites
        test_local
        ;;
    test)
        test_deployed
        ;;
    logs)
        logs
        ;;
    endpoint)
        get_endpoint
        ;;
    validate)
        validate
        ;;
    delete)
        delete
        ;;
    all)
        check_prerequisites
        build
        deploy
        test_deployed
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

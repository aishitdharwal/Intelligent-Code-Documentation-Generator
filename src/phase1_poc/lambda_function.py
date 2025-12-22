"""
AWS Lambda handler for Phase 1 POC.

Simple documentation generator for single Python files.
"""
import json
import logging
import time
from typing import Dict, Any
import uuid

from code_analyzer import PythonCodeAnalyzer
from claude_client import ClaudeClient
from cost_tracker import CostTracker
from ..shared.models import DocumentationResult, ProcessingStatus, APIResponse
from ..shared.utils import setup_logging, calculate_file_hash


# Setup logging
setup_logging()
logger = logging.getLogger(__name__)


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    AWS Lambda handler for documentation generation.
    
    Expected event format:
    {
        "file_path": "example.py",
        "file_content": "def hello():\\n    print('world')"
    }
    
    Args:
        event: Lambda event dict
        context: Lambda context object
        
    Returns:
        API Gateway response dict
    """
    logger.info("Lambda function invoked")
    start_time = time.time()
    
    try:
        # Extract request data
        body = event.get('body', '{}')
        if isinstance(body, str):
            body = json.loads(body)
        
        file_path = body.get('file_path')
        file_content = body.get('file_content')
        
        if not file_path or not file_content:
            return create_error_response(
                "Missing required fields: file_path and file_content",
                400
            )
        
        # Validate file extension
        if not file_path.endswith('.py'):
            return create_error_response(
                "Only Python files (.py) are supported in this version",
                400
            )
        
        # Generate documentation
        result = generate_documentation(file_path, file_content)
        
        # Calculate processing time
        processing_time = time.time() - start_time
        result.processing_time_seconds = processing_time
        
        logger.info(f"Documentation generated successfully in {processing_time:.2f}s")
        
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "success": True,
                "data": result.model_dump(),
                "message": "Documentation generated successfully"
            })
        }
        
    except Exception as e:
        logger.error(f"Error in lambda_handler: {str(e)}", exc_info=True)
        return create_error_response(str(e), 500)


def generate_documentation(file_path: str, file_content: str) -> DocumentationResult:
    """
    Generate documentation for a single file.
    
    Args:
        file_path: Path to the file
        file_content: Content of the file
        
    Returns:
        DocumentationResult object
    """
    request_id = str(uuid.uuid4())
    logger.info(f"Processing request {request_id} for {file_path}")
    
    try:
        # Initialize components
        analyzer = PythonCodeAnalyzer()
        claude_client = ClaudeClient()
        cost_tracker = CostTracker()
        
        # Analyze the code
        analysis = analyzer.analyze_file(file_path, file_content)
        logger.info(f"Analysis complete: {len(analysis.elements)} elements found")
        
        # Generate documentation
        documentation, cost_metrics = claude_client.generate_documentation(
            code=file_content,
            file_path=file_path
        )
        
        # Track costs
        cost_tracker.add_cost(file_path, cost_metrics)
        cost_tracker.print_summary()
        
        # Create result
        result = DocumentationResult(
            request_id=request_id,
            file_path=file_path,
            status=ProcessingStatus.COMPLETED,
            documentation=documentation,
            analysis=analysis,
            total_cost=cost_metrics.total_cost,
            total_tokens=cost_metrics.total_tokens,
            cached=False
        )
        
        return result
        
    except Exception as e:
        logger.error(f"Error generating documentation: {str(e)}")
        return DocumentationResult(
            request_id=request_id,
            file_path=file_path,
            status=ProcessingStatus.FAILED,
            error_message=str(e)
        )


def create_error_response(message: str, status_code: int = 500) -> Dict[str, Any]:
    """
    Create an error response.
    
    Args:
        message: Error message
        status_code: HTTP status code
        
    Returns:
        API Gateway response dict
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({
            "success": False,
            "error": message
        })
    }


# For local testing
if __name__ == "__main__":
    import sys
    import argparse
    
    # Setup argument parser
    parser = argparse.ArgumentParser(description='Generate documentation for a Python file')
    parser.add_argument('--file', type=str, required=True, help='Path to Python file')
    args = parser.parse_args()
    
    # Read file
    try:
        with open(args.file, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {args.file}")
        sys.exit(1)
    
    # Create mock event
    event = {
        'body': json.dumps({
            'file_path': args.file,
            'file_content': content
        })
    }
    
    # Call handler
    response = lambda_handler(event, None)
    
    # Print response
    print("\n" + "=" * 80)
    print("RESPONSE")
    print("=" * 80)
    response_body = json.loads(response['body'])
    
    if response_body['success']:
        result = response_body['data']
        print(f"\nRequest ID: {result['request_id']}")
        print(f"Status: {result['status']}")
        print(f"Total Cost: ${result['total_cost']:.4f} USD")
        print(f"Total Tokens: {result['total_tokens']:,}")
        print(f"Processing Time: {result['processing_time_seconds']:.2f}s")
        print(f"\n{'-' * 80}")
        print("DOCUMENTATION")
        print("-" * 80)
        print(result['documentation'])
        print("=" * 80 + "\n")
    else:
        print(f"\nError: {response_body['error']}")
        print("=" * 80 + "\n")

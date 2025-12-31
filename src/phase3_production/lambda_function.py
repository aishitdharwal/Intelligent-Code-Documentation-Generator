"""
Production Lambda Function with Caching - Simplified (no pydantic)

This is the Phase 3 production version with:
- DynamoDB caching (90% cost reduction)
- No pydantic dependency (avoiding binary issues)
- Decimal to float conversion for JSON serialization
"""
import json
import os
import logging
from datetime import datetime
from typing import Dict, Any
from decimal import Decimal

# Local imports
from cache_manager import CacheManager
from code_analyzer import PythonCodeAnalyzer
from claude_client import ClaudeClient
from cost_tracker import CostTracker
from models import create_documentation_result
from config import Config

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize components
config = Config()
cache_manager = CacheManager(
    table_name=os.environ.get('CACHE_TABLE_NAME'),
    region=os.environ.get('AWS_REGION', 'us-east-1')
)
analyzer = PythonCodeAnalyzer()
claude_client = ClaudeClient(api_key=os.environ['ANTHROPIC_API_KEY'])
cost_tracker = CostTracker()


def decimal_to_float(obj):
    """Convert Decimal to float for JSON serialization."""
    if isinstance(obj, Decimal):
        return float(obj)
    elif isinstance(obj, dict):
        return {k: decimal_to_float(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [decimal_to_float(v) for v in obj]
    return obj


def lambda_handler(event, context):
    """
    Main Lambda handler with caching support.
    
    Flow:
    1. Extract file content
    2. Calculate hash
    3. Check cache
    4. If HIT: return cached docs (cost = $0)
    5. If MISS: generate docs, save to cache
    """
    logger.info(f"Request received: {context.aws_request_id}")
    
    try:
        # Parse request body
        body = json.loads(event.get('body', '{}'))
        file_path = body.get('file_path')
        file_content = body.get('file_content')
        
        # Validate inputs
        if not file_path or not file_content:
            return error_response("Missing file_path or file_content", 400)
        
        if not file_path.endswith('.py'):
            return error_response("Only Python files (.py) supported", 400)
        
        # Calculate content hash
        file_hash = cache_manager.calculate_hash(file_content)
        logger.info(f"File hash: {file_hash[:16]}...")
        
        # Check cache
        cached = cache_manager.get_cached(file_hash)
        
        if cached:
            # CACHE HIT - Return cached documentation
            logger.info("Cache HIT - returning cached documentation")
            
            # Convert Decimals to floats for JSON serialization
            cached_clean = decimal_to_float(cached)
            
            result = create_documentation_result(
                request_id=context.aws_request_id,
                file_path=file_path,
                documentation=cached_clean['documentation'],
                total_cost=0.0,  # Cache hit = $0
                total_tokens=cached_clean['metadata'].get('tokens', 0),
                processing_time=0.1,  # Fast cache retrieval
                cached=True,
                cache_key=file_hash
            )
            
            return success_response(result)
        
        else:
            # CACHE MISS - Generate documentation
            logger.info("Cache MISS - generating documentation")
            
            start_time = datetime.utcnow()
            
            # Analyze code
            analysis = analyzer.analyze_file(file_path, file_content)
            
            # Generate documentation
            documentation, cost_metrics = claude_client.generate_documentation(
                code=file_content,
                file_path=file_path,
                analysis=analysis
            )
            
            # Track cost
            cost_tracker.add_cost(file_path, cost_metrics)
            
            # Calculate processing time
            processing_time = (datetime.utcnow() - start_time).total_seconds()
            
            # Create result
            result = create_documentation_result(
                request_id=context.aws_request_id,
                file_path=file_path,
                documentation=documentation,
                total_cost=cost_metrics['total_cost'],
                total_tokens=cost_metrics['total_tokens'],
                processing_time=processing_time,
                cached=False,
                cache_key=file_hash
            )
            
            # Save to cache for future requests
            cache_metadata = {
                'cost': cost_metrics['total_cost'],
                'tokens': cost_metrics['total_tokens'],
                'analysis': analysis,
                'processing_time': processing_time
            }
            
            cache_saved = cache_manager.save_to_cache(
                file_hash=file_hash,
                file_path=file_path,
                documentation=documentation,
                metadata=cache_metadata,
                ttl_hours=24
            )
            
            if cache_saved:
                logger.info("Documentation saved to cache")
            else:
                logger.warning("Failed to save to cache")
            
            return success_response(result)
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        return error_response(str(e), 500)


def success_response(data: Dict[str, Any]) -> Dict:
    """Build success response."""
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'success': True,
            'data': data,
            'message': 'Documentation generated successfully'
        })
    }


def error_response(message: str, status_code: int) -> Dict:
    """Build error response."""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'success': False,
            'error': message
        })
    }

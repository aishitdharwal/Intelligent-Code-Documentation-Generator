"""
Claude API client - simplified without pydantic
"""
import logging
import os
from typing import Optional, Dict, Any, Tuple
from anthropic import Anthropic
from models import create_cost_metrics


logger = logging.getLogger(__name__)


class ClaudeClient:
    """Wrapper for Claude API to generate code documentation."""
    
    def __init__(self, api_key: Optional[str] = None):
        """Initialize Claude client."""
        self.api_key = api_key or os.environ.get("ANTHROPIC_API_KEY", "")
        if not self.api_key:
            raise ValueError("Anthropic API key is required")
        
        self.client = Anthropic(api_key=self.api_key)
        self.model = os.environ.get("CLAUDE_MODEL", "claude-sonnet-4-20250514")
        self.max_tokens = int(os.environ.get("MAX_TOKENS", "4096"))
        self.temperature = float(os.environ.get("TEMPERATURE", "0.0"))
        
        logger.info(f"Initialized Claude client with model: {self.model}")
    
    def generate_documentation(
        self, 
        code: str, 
        file_path: str,
        analysis: Dict = None,
        context: Optional[str] = None
    ) -> Tuple[str, Dict[str, Any]]:
        """Generate documentation for code using Claude."""
        logger.info(f"Generating documentation for {file_path}")
        
        # Build the prompt
        prompt = self._build_documentation_prompt(code, file_path, context)
        
        try:
            # Call Claude API
            response = self.client.messages.create(
                model=self.model,
                max_tokens=self.max_tokens,
                temperature=self.temperature,
                messages=[
                    {"role": "user", "content": prompt}
                ]
            )
            
            # Extract documentation
            documentation = response.content[0].text
            
            # Calculate cost
            cost_metrics = self._calculate_cost(
                input_tokens=response.usage.input_tokens,
                output_tokens=response.usage.output_tokens
            )
            
            logger.info(
                f"Generated documentation. "
                f"Tokens: {cost_metrics['total_tokens']}, "
                f"Cost: ${cost_metrics['total_cost']:.6f}"
            )
            
            return documentation, cost_metrics
            
        except Exception as e:
            logger.error(f"Error generating documentation: {e}")
            raise
    
    def _build_documentation_prompt(self, code: str, file_path: str, context: Optional[str] = None) -> str:
        """Build the prompt for documentation generation."""
        base_prompt = f"""You are an expert technical writer and software engineer. Your task is to generate comprehensive, clear documentation for Python code.

**File:** {file_path}

**Code:**
```python
{code}
```

Please generate documentation that includes:

1. **File Overview**: A brief summary of what this file does and its purpose in the codebase.

2. **Functions/Classes**: For each function and class:
   - Purpose and functionality
   - Parameters with types and descriptions
   - Return values with types and descriptions
   - Usage examples (if appropriate)
   - Any important notes, edge cases, or warnings

3. **Dependencies**: List and explain any important imports or dependencies.

4. **Code Quality Notes**: Any observations about code quality, potential improvements, or best practices.

Format the documentation in clear, professional Markdown. Be concise but comprehensive. Focus on helping developers understand the code quickly.
"""
        
        if context:
            base_prompt += f"\n\n**Additional Context:**\n{context}"
        
        return base_prompt
    
    def _calculate_cost(self, input_tokens: int, output_tokens: int) -> Dict[str, Any]:
        """Calculate cost metrics for API call."""
        input_cost_per_1m = float(os.environ.get("COST_PER_1M_INPUT_TOKENS", "3.00"))
        output_cost_per_1m = float(os.environ.get("COST_PER_1M_OUTPUT_TOKENS", "15.00"))
        
        input_cost = (input_tokens / 1_000_000) * input_cost_per_1m
        output_cost = (output_tokens / 1_000_000) * output_cost_per_1m
        
        return create_cost_metrics(
            input_tokens=input_tokens,
            output_tokens=output_tokens,
            input_cost=input_cost,
            output_cost=output_cost
        )

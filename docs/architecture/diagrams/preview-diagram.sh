#!/bin/bash

# Quick Mermaid Preview Script
# Usage: ./preview-diagram.sh phase1-system-architecture.mermaid

if [ -z "$1" ]; then
    echo "Usage: ./preview-diagram.sh <diagram.mermaid>"
    exit 1
fi

DIAGRAM_FILE="$1"
TEMP_MD="temp_preview.md"

# Create temporary markdown file with the diagram
cat > "$TEMP_MD" << EOF
# Mermaid Diagram Preview

\`\`\`mermaid
$(cat "$DIAGRAM_FILE")
\`\`\`
EOF

echo "✅ Created $TEMP_MD"
echo "📝 Open this file in Cursor and press Cmd+Shift+V to preview"
echo ""
echo "The file will be automatically opened..."

# Try to open in Cursor (if cursor command is available)
if command -v cursor &> /dev/null; then
    cursor "$TEMP_MD"
else
    echo "⚠️  'cursor' command not found. Please open $TEMP_MD manually."
fi

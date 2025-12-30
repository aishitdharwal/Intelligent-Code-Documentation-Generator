# Phase 1 Architecture - All Diagrams Preview

This file contains all Phase 1 architecture diagrams in one place for easy preview in Cursor.

**How to view:**
1. Install "Markdown Preview Mermaid Support" extension in Cursor
2. Open this file
3. Press `Cmd + Shift + V` (Mac) or `Ctrl + Shift + V` (Windows/Linux)
4. Or press `Cmd + K V` for side-by-side view

---

## 1. System Architecture

**Purpose**: Shows the complete system from client to Claude API with all major components.

**Use when**: Introducing the project, explaining AWS services, discussing infrastructure.

```mermaid
graph TB
    subgraph "Client Layer"
        Client[Client Application<br/>Web/CLI/GitHub Action]
    end

    subgraph "AWS Cloud"
        subgraph "API Layer"
            APIGW[API Gateway<br/>REST API<br/>POST /document]
        end

        subgraph "Compute Layer"
            Lambda[AWS Lambda Function<br/>512 MB / 5 min timeout<br/>Python 3.9]
        end

        subgraph "Application Layer"
            Handler[Lambda Handler<br/>Orchestration]
            Analyzer[PythonCodeAnalyzer<br/>AST Parsing]
            ClaudeClient[ClaudeClient<br/>API Integration]
            CostTracker[CostTracker<br/>Metrics Aggregation]
        end

        subgraph "Logging"
            CloudWatch[CloudWatch Logs<br/>Request Logging<br/>Error Tracking]
        end
    end

    subgraph "External Services"
        Anthropic[Anthropic Claude API<br/>claude-sonnet-4-20250514<br/>Documentation Generation]
    end

    Client -->|HTTP POST<br/>JSON payload| APIGW
    APIGW -->|Lambda Proxy<br/>Integration| Lambda
    Lambda --> Handler
    Handler -->|1. Analyze Code| Analyzer
    Handler -->|2. Generate Docs| ClaudeClient
    Handler -->|3. Track Cost| CostTracker
    ClaudeClient -->|API Request<br/>Prompt + Code| Anthropic
    Anthropic -->|Response<br/>Documentation + Tokens| ClaudeClient
    Handler -->|Logs| CloudWatch
    Lambda -->|HTTP Response<br/>JSON| APIGW
    APIGW -->|JSON Response| Client

    style Client fill:#e1f5ff
    style APIGW fill:#fff4e1
    style Lambda fill:#ffe1f5
    style Anthropic fill:#e1ffe1
    style CloudWatch fill:#f0f0f0
```

---

## 2. Request Flow (Sequence Diagram)

**Purpose**: Shows the step-by-step sequence of a single documentation request.

**Use when**: Debugging issues, understanding performance bottlenecks, explaining the flow.

```mermaid
sequenceDiagram
    participant Client
    participant APIGW as API Gateway
    participant Lambda as Lambda Handler
    participant Analyzer as CodeAnalyzer
    participant Claude as ClaudeClient
    participant Anthropic as Claude API
    participant Cost as CostTracker
    participant CW as CloudWatch

    Note over Client,CW: Phase 1: Single File Documentation Request

    Client->>APIGW: POST /document<br/>{file_path, file_content}
    activate APIGW
    
    APIGW->>Lambda: Invoke with event
    activate Lambda
    
    Lambda->>CW: Log: Request received (req_id)
    
    Note over Lambda: Extract & validate input
    Lambda->>Lambda: Parse JSON body
    Lambda->>Lambda: Validate .py extension
    
    Lambda->>Analyzer: analyze_file(path, content)
    activate Analyzer
    
    Note over Analyzer: AST Parsing
    Analyzer->>Analyzer: Count lines
    Analyzer->>Analyzer: Parse AST tree
    Analyzer->>Analyzer: Extract functions
    Analyzer->>Analyzer: Extract classes
    Analyzer->>Analyzer: Extract imports
    
    Analyzer-->>Lambda: FileAnalysis object
    deactivate Analyzer
    
    Lambda->>CW: Log: Analysis complete (N elements)
    
    Lambda->>Claude: generate_documentation(code, path)
    activate Claude
    
    Claude->>Claude: Build prompt with code
    
    Claude->>Anthropic: messages.create()<br/>model: sonnet-4<br/>max_tokens: 4096
    activate Anthropic
    
    Note over Anthropic: LLM Processing
    Anthropic->>Anthropic: Process prompt
    Anthropic->>Anthropic: Generate documentation
    
    Anthropic-->>Claude: Response:<br/>- documentation text<br/>- input_tokens<br/>- output_tokens
    deactivate Anthropic
    
    Claude->>Claude: Extract documentation
    Claude->>Claude: Calculate cost
    
    Claude-->>Lambda: (documentation, CostMetrics)
    deactivate Claude
    
    Lambda->>Cost: add_cost(file_path, metrics)
    activate Cost
    Cost->>Cost: Update totals
    Cost->>CW: Log: Cost summary
    Cost-->>Lambda: Acknowledgment
    deactivate Cost
    
    Lambda->>Lambda: Build DocumentationResult
    Lambda->>Lambda: Calculate processing time
    
    Lambda->>CW: Log: Request complete (time, cost)
    
    Lambda-->>APIGW: HTTP 200<br/>{success, data, message}
    deactivate Lambda
    
    APIGW-->>Client: JSON Response:<br/>- documentation<br/>- cost: $0.XX<br/>- tokens: N<br/>- time: Xs
    deactivate APIGW
    
    Note over Client: Documentation received!<br/>Ready to use
```

---

## 3. Component Flow (Data Pipeline)

**Purpose**: Shows how data transforms through the system from raw code to documentation.

**Use when**: Understanding data transformations, optimizing performance, adding features.

```mermaid
graph LR
    subgraph "Input"
        FileContent[Python Source Code<br/>file_path: str<br/>file_content: str]
    end

    subgraph "Phase 1: Code Analysis"
        Analyzer[PythonCodeAnalyzer]
        AST[AST Parser]
        LineCounter[Line Counter]
        ElementExtractor[Element Extractor]
        
        FileContent --> Analyzer
        Analyzer --> LineCounter
        Analyzer --> AST
        AST --> ElementExtractor
        
        LineCounter --> Analysis
        ElementExtractor --> Analysis
        
        Analysis[FileAnalysis Object<br/>- total_lines<br/>- code_lines<br/>- elements: List<br/>- imports: List]
    end

    subgraph "Phase 2: Documentation Generation"
        PromptBuilder[Prompt Builder]
        APICall[Claude API Call]
        ResponseParser[Response Parser]
        
        Analysis --> PromptBuilder
        FileContent --> PromptBuilder
        PromptBuilder --> APICall
        APICall --> ResponseParser
        
        ResponseParser --> DocResult[Documentation String<br/>+ Token Counts]
    end

    subgraph "Phase 3: Cost Calculation"
        CostCalc[Cost Calculator]
        MetricsAgg[Metrics Aggregator]
        
        DocResult --> CostCalc
        CostCalc --> MetricsAgg
        
        MetricsAgg --> CostMetrics[CostMetrics Object<br/>- input_tokens<br/>- output_tokens<br/>- total_cost: float]
    end

    subgraph "Phase 4: Result Assembly"
        ResultBuilder[Result Builder]
        
        Analysis --> ResultBuilder
        DocResult --> ResultBuilder
        CostMetrics --> ResultBuilder
        
        ResultBuilder --> FinalResult[DocumentationResult<br/>- request_id<br/>- documentation<br/>- analysis<br/>- cost<br/>- time]
    end

    subgraph "Output"
        JSONResponse[JSON Response<br/>HTTP 200]
        
        FinalResult --> JSONResponse
    end

    style FileContent fill:#e3f2fd
    style Analysis fill:#fff3e0
    style DocResult fill:#f3e5f5
    style CostMetrics fill:#e8f5e9
    style FinalResult fill:#fce4ec
    style JSONResponse fill:#e0f2f1
```

---

## 4. Data Model (Class Diagram)

**Purpose**: Shows the data structures and their relationships.

**Use when**: Understanding code structure, adding fields, writing tests.

```mermaid
classDiagram
    class APIRequest {
        +string file_path
        +string file_content
    }

    class FileAnalysis {
        +string file_path
        +FileType file_type
        +int total_lines
        +int code_lines
        +int comment_lines
        +int blank_lines
        +List~CodeElement~ elements
        +List~string~ imports
    }

    class CodeElement {
        +string name
        +string type
        +int line_start
        +int line_end
        +string docstring
        +List~string~ parameters
        +string return_type
    }

    class CostMetrics {
        +int input_tokens
        +int output_tokens
        +int total_tokens
        +float input_cost
        +float output_cost
        +float total_cost
        +datetime timestamp
    }

    class DocumentationResult {
        +string request_id
        +string file_path
        +ProcessingStatus status
        +string documentation
        +FileAnalysis analysis
        +float total_cost
        +int total_tokens
        +float processing_time_seconds
        +bool cached
        +datetime timestamp
    }

    class APIResponse {
        +bool success
        +DocumentationResult data
        +string message
        +CostMetrics cost_metrics
    }

    APIRequest --> FileAnalysis : analyzes to
    FileAnalysis *-- CodeElement : contains
    FileAnalysis --> DocumentationResult : included in
    CostMetrics --> DocumentationResult : tracked in
    DocumentationResult --> APIResponse : wrapped in

    note for APIRequest "Input from client\nContains raw Python code"
    note for FileAnalysis "AST analysis results\nStructural information"
    note for CostMetrics "Token usage and costs\nPer API call"
    note for DocumentationResult "Complete result\nReturned to client"
```

---

## 5. Decision Flow (Error Handling)

**Purpose**: Shows all decision points and error paths in the system.

**Use when**: Understanding validation, debugging failures, adding error handling.

```mermaid
graph TD
    Start((Start:<br/>Document Request)) --> Validate{Valid<br/>Request?}
    
    Validate -->|No| Error1[Return 400 Error:<br/>Missing fields]
    Validate -->|Yes| ExtCheck{.py file?}
    
    ExtCheck -->|No| Error2[Return 400 Error:<br/>Invalid file type]
    ExtCheck -->|Yes| Parse[Parse Code<br/>with AST]
    
    Parse --> SyntaxCheck{Valid<br/>Syntax?}
    
    SyntaxCheck -->|No| Error3[Return 400 Error:<br/>Syntax error]
    SyntaxCheck -->|Yes| Extract[Extract:<br/>Functions, Classes,<br/>Imports]
    
    Extract --> CheckSize{File > 5000<br/>lines?}
    
    CheckSize -->|Yes| Warning[Continue with<br/>WARNING: May timeout]
    CheckSize -->|No| BuildPrompt[Build<br/>Documentation<br/>Prompt]
    Warning --> BuildPrompt
    
    BuildPrompt --> CallAPI[Call Claude API<br/>Sonnet-4]
    
    CallAPI --> APISuccess{API Call<br/>Success?}
    
    APISuccess -->|No| Retry{Retries<br/>Left?}
    Retry -->|Yes| Wait[Wait 1s]
    Wait --> CallAPI
    Retry -->|No| Error4[Return 500 Error:<br/>API failure]
    
    APISuccess -->|Yes| ParseResp[Parse Response<br/>Extract Docs]
    
    ParseResp --> CalcCost[Calculate:<br/>Token Cost]
    
    CalcCost --> BuildResult[Build<br/>DocumentationResult]
    
    BuildResult --> LogCost[Log Cost<br/>to CloudWatch]
    
    LogCost --> Success[Return 200 OK:<br/>Documentation +<br/>Metrics]
    
    Error1 --> End((End))
    Error2 --> End
    Error3 --> End
    Error4 --> End
    Success --> End
    
    style Start fill:#4CAF50,stroke:#1B5E20,stroke-width:2px,color:#fff
    style End fill:#F44336,stroke:#B71C1C,stroke-width:2px,color:#fff
    style Success fill:#2196F3,stroke:#0D47A1,stroke-width:2px,color:#fff
    style Error1 fill:#FF9800,stroke:#E65100,stroke-width:2px
    style Error2 fill:#FF9800,stroke:#E65100,stroke-width:2px
    style Error3 fill:#FF9800,stroke:#E65100,stroke-width:2px
    style Error4 fill:#FF9800,stroke:#E65100,stroke-width:2px
```

---

## 6. Phase Comparison (POC vs Production)

**Purpose**: Visual comparison between Phase 1's simplicity and Phase 3's sophistication.

**Use when**: Explaining why Phase 3 matters, motivating students, justifying complexity.

```mermaid
graph TB
    subgraph "Phase 1: Simple POC"
        P1Client[Client] -->|Single File| P1API[API Gateway]
        P1API --> P1Lambda[Lambda<br/>5 min timeout]
        P1Lambda --> P1Analyzer[Code Analyzer]
        P1Lambda --> P1Claude[Claude Client]
        P1Claude -->|Every Request| P1Anthropic[Claude API<br/>$$$$]
        P1Lambda --> P1Cost[Cost Tracker]
        
        style P1Lambda fill:#ffcccc
        style P1Anthropic fill:#ffcccc
    end

    subgraph "Phase 3: Production System"
        P3Client[Client] -->|Batch/Single| P3API[API Gateway]
        P3API --> P3Lambda[Lambda Router<br/>Fast decisions]
        
        P3Lambda --> P3Cache{Cache<br/>Hit?}
        P3Cache -->|Yes| P3Return1[Return<br/>Cached Docs<br/>$0]
        P3Cache -->|No| P3Size{File<br/>Size?}
        
        P3Size -->|Small| P3LambdaProc[Lambda<br/>Processor]
        P3Size -->|Large| P3Queue[SQS Queue]
        P3Queue --> P3ECS[ECS Fargate<br/>Parallel Processing]
        
        P3LambdaProc --> P3Chunk[Chunking<br/>Strategy]
        P3ECS --> P3Chunk
        
        P3Chunk --> P3RateLimit[Rate Limiter<br/>+ Retry Logic]
        P3RateLimit --> P3ClaudeClient[Claude Client]
        P3ClaudeClient --> P3Anthropic[Claude API<br/>$]
        
        P3Anthropic --> P3UpdateCache[Update<br/>DynamoDB Cache]
        P3UpdateCache --> P3S3[Store in S3]
        P3S3 --> P3Return2[Return Docs]
        
        P3Lambda --> P3Monitor[CloudWatch<br/>+ X-Ray]
        
        style P3Cache fill:#ccffcc
        style P3Return1 fill:#ccffcc
        style P3RateLimit fill:#ccffcc
        style P3Chunk fill:#ccffcc
    end

    subgraph "Key Differences"
        D1[❌ No Caching<br/>Every call costs money]
        D2[✅ 80% Cache Hit Rate<br/>Massive cost savings]
        
        D3[❌ No Chunking<br/>Large files timeout]
        D4[✅ Smart Chunking<br/>Handles 50K+ lines]
        
        D5[❌ No Retry Logic<br/>Failures are final]
        D6[✅ Exponential Backoff<br/>Handles rate limits]
        
        D7[❌ Serial Processing<br/>One file at a time]
        D8[✅ Parallel Processing<br/>10x faster on repos]
    end

    style D1 fill:#ffcccc
    style D3 fill:#ffcccc
    style D5 fill:#ffcccc
    style D7 fill:#ffcccc
    
    style D2 fill:#ccffcc
    style D4 fill:#ccffcc
    style D6 fill:#ccffcc
    style D8 fill:#ccffcc
```

---

## Quick Navigation

Jump to:
- [System Architecture](#1-system-architecture) - Big picture overview
- [Request Flow](#2-request-flow-sequence-diagram) - Step-by-step sequence
- [Component Flow](#3-component-flow-data-pipeline) - Data transformations
- [Data Model](#4-data-model-class-diagram) - Class structures
- [Decision Flow](#5-decision-flow-error-handling) - Validation and errors
- [Phase Comparison](#6-phase-comparison-poc-vs-production) - Why Phase 3 matters

## Notes

- All diagrams are rendered with Mermaid
- Colors indicate different layers or states
- Arrows show data flow or dependencies
- Subgraphs group related components

## Exporting

To export any diagram:
1. Right-click on the rendered diagram
2. Select "Copy Image" or use browser tools
3. Paste into presentations, docs, etc.

Or use https://mermaid.live to export as PNG/SVG.

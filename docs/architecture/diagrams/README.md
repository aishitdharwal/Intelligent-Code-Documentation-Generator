# Phase 1 Architecture Diagrams

This directory contains visual representations of the Phase 1 architecture using Mermaid diagrams. These diagrams can be rendered directly in GitHub, used in presentations, or exported to images.

## Available Diagrams

### 1. High-Level System Architecture
Shows the complete system from client to Claude API with all major components.

### 2. Request Flow Sequence
Shows the step-by-step flow of a single documentation request through the system.

### 3. Component Interaction
Shows how the internal components (Analyzer, Client, Cost Tracker) interact.

### 4. Data Model
Shows the key data structures and how they flow through the system.

## How to Use These Diagrams

### Viewing in GitHub
Simply open any `.mermaid` file in GitHub and it will render automatically.

### Viewing in VS Code
Install the "Markdown Preview Mermaid Support" extension to see diagrams in preview.

### Exporting to Images
Use the Mermaid CLI or online editor:
```bash
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Export to PNG
mmdc -i diagram.mermaid -o diagram.png
```

Or use the online editor: https://mermaid.live

### Including in Presentations
Copy the diagram code into your presentation tool that supports Mermaid (like Notion, GitPitch, or reveal.js).

## Diagram Legend

```
┌─────────┐  Rectangle = Component/Service
│         │
└─────────┘

    ↓       Arrow = Data flow / Call direction

((  ))      Circle = Start/End point

{  }        Diamond = Decision point

[  ]        Box = Process/Action
```

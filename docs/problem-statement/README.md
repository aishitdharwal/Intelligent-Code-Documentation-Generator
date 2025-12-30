# Problem Statement: Intelligent Code Documentation Generator

## The Real-World Problem

Software engineering teams face a persistent documentation crisis. Legacy codebases accumulate thousands of lines of undocumented or poorly documented code over time. New developers joining teams spend weeks trying to understand what the code does rather than contributing to it. Code reviews take longer because reviewers must decipher intent from implementation details. Technical debt compounds as nobody wants to touch code they don't understand, leading to rewrites instead of refactoring.

The traditional solutions to this problem are fundamentally broken. Manual documentation is time-consuming and quickly becomes outdated as code evolves. Developers view documentation as a chore that takes time away from "real work," so it gets deprioritized under deadline pressure. Even when documentation exists, it often lacks depth because the person writing it assumes context that new readers don't have. The result is that most production codebases have documentation coverage below thirty percent, with critical business logic often completely undocumented.

Automated documentation tools like JSDoc or Sphinx can extract docstrings and generate API references, but they only surface information that already exists in the code. They cannot explain why code exists, what business problems it solves, or what design decisions were made along the way. They produce documentation that is technically accurate but pedagogically useless for someone trying to understand the system.

## Why Now? The LLM Opportunity

Large language models like Claude have fundamentally changed what automated documentation can accomplish. Unlike traditional static analysis tools, LLMs can read code and explain it in natural language. They can infer intent from implementation patterns, identify code smells, suggest improvements, and write explanations that would take a human developer hours to produce. The quality of LLM-generated documentation often rivals or exceeds what junior developers would write manually.

However, integrating LLMs into production workflows introduces an entirely new class of engineering challenges. API costs, rate limits, latency requirements, context window constraints, and reliability expectations all create barriers that prevent teams from simply pointing GPT-4 or Claude at their codebase and getting usable documentation. This gap between the theoretical capability of LLMs and the practical requirements of production systems is what makes this project essential for AI engineering education.

## The Educational Problem

Most AI engineering courses teach students how to call LLM APIs in isolation. They show you how to construct a prompt, make an API request, and parse the response. Then they declare victory without addressing the hard questions: How do you handle a codebase too large to fit in the context window? What happens when your API calls cost more than your revenue? How do you make documentation generation fast enough for CI/CD integration? How do you handle rate limits when processing hundreds of files?

Students who learn AI engineering without confronting these constraints build systems that work in demos but fail in production. They optimize for impressive outputs rather than sustainable economics. They design architectures that assume infinite compute and zero latency. When they encounter real-world limitations, they lack the systematic problem-solving approaches to overcome them.

This project addresses that gap by deliberately exposing students to the failure modes of naive AI systems, then teaching them production engineering patterns to solve those failures. The goal is not just to build a documentation generator, but to internalize the thinking process required to build any production AI system that operates under real-world constraints.

## Problem Scope and Boundaries

### In Scope

This project focuses specifically on generating comprehensive documentation for Python codebases. The target user is a software engineering team with an existing codebase that lacks adequate documentation. The team wants to automatically generate documentation that helps new developers understand the code, supports code reviews with context about what each function does, and provides searchable reference material for the entire codebase.

The system must handle repositories ranging from single files to massive codebases with tens of thousands of lines of code. It must produce documentation in standard formats like Markdown and HTML that can be integrated into existing documentation sites or repositories. The documentation should cover function and class purposes, parameter descriptions, return value specifications, usage examples where appropriate, dependencies between components, and code quality observations.

The system must operate within economic constraints that make it viable as a commercial product or internal tool. This means cost per repository must be low enough to support frequent regeneration as code changes. The system must be reliable enough to integrate into continuous integration pipelines without causing flaky builds. Processing time must be reasonable for developer workflows, meaning minutes rather than hours for typical repositories.

### Out of Scope

This project does not attempt to replace human-written documentation for high-level architectural decisions, product requirements, or user guides. It focuses exclusively on code-level documentation that explains implementation details. The system does not modify code or enforce documentation standards, it only generates documentation based on existing code.

Multi-language support beyond Python is considered an advanced feature rather than a core requirement. While the architecture should be extensible to JavaScript, TypeScript, Java, and other languages, the initial implementation targets Python specifically because its clear syntax and extensive use of AST make it an ideal teaching example.

Real-time documentation generation or IDE integration is out of scope for the core project. The system is designed as a batch processing tool that analyzes entire files or repositories, not as an interactive assistant that documents code as you write it. Integration points like GitHub Actions or webhooks are included, but deep IDE integration requires different architectural decisions around latency and user experience.

## Key Constraints and Requirements

### Economic Constraints

The primary economic constraint is API cost. Claude's pricing model charges per token for both input and output. A naive approach that sends entire files to Claude without optimization can easily cost thousands of rupees for a single large repository. This makes the system economically unviable for regular use.

The system must achieve a target cost of under ₹500 per 50,000-line repository to be commercially viable. This target assumes that documentation will be regenerated multiple times during development and that teams will want to document multiple repositories. At higher costs, the system becomes a luxury that only well-funded companies can afford rather than a practical tool for typical development teams.

Cost optimization must be achieved through intelligent caching, efficient chunking strategies, and prompt engineering that minimizes token usage without sacrificing documentation quality. The system should track costs at granular levels including per file, per API call, and per repository so that users can understand where their money goes and make informed decisions about usage.

### Performance Constraints

Processing time directly impacts developer experience. If documentation generation takes hours, developers will not use it regularly. The target is to process a typical 10,000-line repository in under five minutes and a large 50,000-line repository in under fifteen minutes. These targets assume that documentation generation happens asynchronously rather than blocking developer workflows.

Latency requirements differ based on usage context. For batch processing of entire repositories, higher latency is acceptable because it runs in the background. For integration with pull request workflows, documentation should complete within the typical code review timeframe of ten to thirty minutes. Real-time use cases like IDE integration would require sub-second latency, which is why they are out of scope for this project.

The system must handle concurrency gracefully. Multiple users or repositories might request documentation simultaneously. The architecture should scale horizontally to handle increased load rather than degrading performance for all users. This requires distributed processing capabilities and careful management of API rate limits across concurrent requests.

### Quality Constraints

Documentation quality directly determines the value of the entire system. Poor quality documentation that simply restates what the code does is worse than no documentation because it creates false confidence. The system must produce documentation that provides genuine insight beyond what a developer could quickly understand by reading the code itself.

Quality criteria include completeness of coverage for all public functions and classes, accuracy in describing what the code actually does rather than what it appears to do, clarity for developers who are unfamiliar with the codebase, and actionability in terms of usage examples and edge case warnings. The documentation should feel like it was written by a senior developer who understands both the implementation details and the broader context.

Quality must be measurable and improvable over time. The system should support A/B testing of different prompts, collect feedback on documentation usefulness, and provide metrics like coverage percentage and developer satisfaction scores. This creates a feedback loop that allows continuous improvement of documentation quality.

### Reliability Constraints

Production systems must handle failures gracefully. The documentation generator will encounter syntax errors in code, API rate limits from Claude, network failures, and malformed inputs. The system should never silently fail or produce incorrect documentation. When failures occur, they should be logged with enough context to debug the issue and reported to users in actionable ways.

The system must be idempotent, meaning that generating documentation for the same code multiple times produces the same result. This is essential for integration with version control systems where documentation changes should only occur when code changes. Cache invalidation must be reliable so that stale documentation is never served after code updates.

Reliability also means predictable behavior under resource constraints. If AWS Lambda reaches its memory limit, the system should gracefully split the work rather than crashing. If DynamoDB throttles cache writes, the system should fall back to regenerating documentation rather than failing entirely. Degraded operation is preferable to complete failure.

## Success Metrics

### Quantitative Metrics

Cost efficiency is measured by the total cost to document a repository divided by the number of lines of code processed. The target is under ₹0.01 per line for the first documentation pass and under ₹0.002 per line for subsequent passes with caching. These metrics should trend downward over time as cache hit rates improve and prompt engineering becomes more efficient.

Processing speed is measured by the wall-clock time from request submission to documentation completion. The target is under five minutes for 10,000 lines and under fifteen minutes for 50,000 lines. Percentile metrics matter here because average processing time can be misleading if occasional requests take much longer.

Coverage percentage measures what proportion of functions, classes, and methods receive documentation. The target is ninety-five percent coverage for public APIs and seventy percent for internal implementation details. Missing coverage should be explicitly tracked so that gaps can be addressed.

Cache hit rate measures the percentage of documentation requests served from cache rather than requiring new API calls. The target is eighty percent for repositories that are documented regularly. This metric directly correlates with cost efficiency and should improve as teams integrate documentation into their workflows.

### Qualitative Metrics

Documentation usefulness can only be measured through developer feedback. The system should support explicit feedback mechanisms like thumbs up or down on individual documentation sections. Over time, this feedback should correlate with improvements in documentation quality as prompts are refined based on what developers find most helpful.

Time to understanding measures how long it takes a new developer to understand what a function does using the generated documentation. This is subjective and hard to measure at scale, but can be approximated through user studies or surveys. The goal is that documentation reduces time to understanding by at least fifty percent compared to reading code alone.

Integration success measures how well the system fits into existing developer workflows. Successful integration means that documentation generation becomes automatic rather than manual, that developers actually reference the generated documentation during code reviews and debugging, and that documentation quality improves code quality by surfacing issues that might otherwise be missed.

## Non-Functional Requirements

### Scalability

The system must scale from single-user laptop testing to multi-tenant cloud deployment. This means supporting everything from a student running the code locally with minimal AWS resources to a company processing hundreds of repositories per day across multiple teams. The architecture should allow horizontal scaling where adding more compute capacity proportionally increases processing throughput.

Resource usage should scale sub-linearly with repository size. A repository twice as large should not require twice as much compute time or cost twice as much money. This requires intelligent optimizations like processing only changed files, reusing documentation for stable functions, and parallelizing independent chunks.

### Maintainability

Code must be well-documented and modular so that students can understand and extend it. Each phase of the project should be independently runnable and testable. The transition from Phase 1 to Phase 3 should be gradual, with clear intermediate steps that can be deployed and validated.

Infrastructure as Code with Terraform ensures that the AWS resources can be recreated consistently. This is essential for a teaching project where students will deploy and tear down resources frequently. The Terraform configurations should be well-commented and explain why each resource is configured the way it is.

### Security

The system handles source code, which may contain sensitive business logic or proprietary algorithms. While the documentation generator does not store code persistently beyond caching, it must handle credentials securely through AWS Secrets Manager and ensure that cached documentation is not accessible across different tenants.

API keys must never be committed to version control or logged in plaintext. All AWS resources should follow least-privilege access patterns where Lambda functions can only access the specific DynamoDB tables and S3 buckets they need. This teaches students production security practices from the beginning.

## The Learning Journey

The problem statement itself is educational. By clearly articulating the constraints and requirements before writing code, students learn that engineering is about solving problems under constraints rather than building whatever seems cool. The three-phase structure maps directly to the problem progression: Phase 1 solves the basic documentation problem, Phase 2 reveals the constraints, and Phase 3 addresses the constraints systematically.

Each constraint in this problem statement becomes a teaching opportunity. Economic constraints teach cost optimization. Performance constraints teach distributed systems. Quality constraints teach prompt engineering. Reliability constraints teach error handling and monitoring. By the end of the project, students have not just built a documentation generator but learned systematic approaches to building any production AI system.

The problem is scoped to be achievable in a four-week course while being sophisticated enough to require production engineering thinking. It is realistic because it mirrors actual problems that AI engineering teams face when deploying LLM-powered tools. It is measurable because every requirement has concrete success criteria. This problem statement is the foundation upon which the entire learning experience is built.

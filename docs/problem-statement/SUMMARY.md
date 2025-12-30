# Problem Statement Summary

## The Core Problem in One Sentence

Software teams waste enormous developer time trying to understand undocumented codebases because writing documentation manually is expensive and gets deprioritized, while traditional automated tools cannot explain intent or generate the contextual understanding that developers actually need.

## Who Experiences This Problem

The problem affects multiple stakeholders across the software development lifecycle. New developers joining teams struggle to become productive because they must reverse-engineer the codebase rather than reading documentation that explains what the code does and why it exists. Code reviewers spend excessive time in reviews because they lack context about what the code is supposed to accomplish, forcing them to mentally simulate execution to understand behavior. Maintainers of legacy systems face enormous risk when making changes because nobody remembers the original design decisions or understands all the edge cases the code handles.

Open source maintainers watch their projects lose adoption to competitors with better documentation even when their implementation is technically superior. Companies in regulated industries struggle to comply with audit requirements that demand comprehensive documentation of business-critical code. Every one of these stakeholders would benefit from automated documentation that is comprehensive, accurate, current, and generated at reasonable cost.

## Why Traditional Solutions Fail

Manual documentation fails because it is expensive to create and even more expensive to maintain. Developers view documentation as a chore that takes time away from shipping features, so it gets deprioritized under deadline pressure. Even when documentation gets written, it becomes outdated as code evolves because keeping documentation synchronized with code requires ongoing discipline that teams rarely maintain.

Traditional documentation tools like Sphinx or Javadoc can extract information that already exists in the code such as function signatures and existing docstrings, but they cannot create information that does not exist. They produce skeleton documentation that technically describes the API but fails to explain what the code actually does or how to use it effectively. Static analysis tools can detect code smells but cannot explain intent or suggest improvements in natural language.

This is where large language models create a fundamental shift in what automated documentation can accomplish. LLMs can read code and infer intent from implementation, explain functionality in natural language that helps developers understand quickly, identify edge cases and potential issues that might not be obvious, suggest improvements based on patterns they recognize from training on millions of code examples, and generate usage examples that show how to actually use the code rather than just describing its signature.

However, using LLMs in production is not as simple as calling an API and dumping all your code into the prompt. The constraints of cost, performance, reliability, and quality create an entire class of engineering challenges that must be solved systematically to make LLM-powered documentation viable for regular use in production workflows.

## The Key Constraints That Define the Solution Space

Economic constraints dominate the design space. Claude charges per token for both input and output, and a naive approach that sends entire large files to the API without optimization can easily cost thousands of rupees for a single repository. This makes regular use economically impossible for most teams. The system must achieve costs under five hundred rupees per fifty-thousand-line repository to be viable for frequent regeneration as code changes.

Performance constraints determine adoption. If documentation generation takes hours, developers will not integrate it into their workflows. The target is processing typical repositories in under five minutes so that documentation can be generated asynchronously without blocking developer productivity. Latency requirements are less stringent than real-time systems but still tight enough that careful optimization is needed.

Quality constraints determine value. Documentation that simply restates the code in English provides minimal value over reading the code directly. The system must generate documentation that provides genuine insight, explains not just what the code does but why it exists and how to use it, covers edge cases and error conditions that developers need to know about, and maintains consistent terminology and style across the entire codebase.

Reliability constraints determine trust. The system must handle syntax errors in code, API rate limits and transient failures, large files that exceed context windows, and concurrent requests without degrading service. Failures must be handled gracefully with actionable error messages rather than silent failures or crashes that force developers to abandon the tool.

## What Success Looks Like

Quantitatively, success means documenting a fifty-thousand-line repository for under five hundred rupees, completing documentation generation in under fifteen minutes for large repositories, achieving ninety-five percent coverage of public APIs with comprehensive documentation, and maintaining cache hit rates above eighty percent for repositories that are documented regularly.

Qualitatively, success means that new developers can understand unfamiliar code in hours instead of weeks by reading the generated documentation, code reviewers can perform thorough reviews in significantly less time because they have context about what the code is supposed to do, teams integrate documentation generation into their continuous integration pipelines because it is reliable enough to depend on, and developers actually reference the generated documentation during development rather than ignoring it as inaccurate or outdated.

The ultimate measure of success is that comprehensive documentation becomes the default rather than the exception because the cost and effort to generate it becomes negligible compared to the value it provides. When documentation is cheap enough and good enough, teams stop treating it as optional and start treating it as essential infrastructure.

## The Educational Value of This Problem

This problem is valuable for teaching AI engineering because it exposes students to the full range of challenges involved in building production LLM systems. Students experience the gap between calling an API in a demo versus deploying a reliable system that operates under real-world constraints. They learn that production AI engineering is not primarily about prompt engineering or model selection but about building robust systems that handle failures, optimize costs, and deliver value predictably.

The three-phase structure teaches systematic problem solving. Phase 1 demonstrates that building something that works in the simple case is straightforward. Phase 2 reveals the constraints that simple solutions violate when pushed beyond toy examples. Phase 3 teaches production patterns that address constraints systematically rather than through ad-hoc fixes. This progression mirrors how professional engineers approach new problems by starting simple, identifying limitations through testing, and iterating toward robust solutions.

The problem also teaches valuable meta-skills around requirement specification, cost-benefit analysis, and tradeoff evaluation. Students learn to measure success against concrete criteria rather than subjective assessments of quality. They practice making architectural decisions based on requirements rather than technical preferences. They develop intuition about which optimizations matter most by understanding where costs and bottlenecks actually come from.

## Why Now Is the Right Time for This Problem

Large language models have advanced to the point where they can generate genuinely useful code documentation, but the engineering patterns for deploying them in production workflows are not yet widely understood. Most organizations struggle to move from proof of concept demonstrations to production systems because they lack systematic approaches to handling cost, reliability, and performance constraints.

This gap between theoretical capability and practical deployment creates enormous demand for engineers who understand how to build production LLM systems. By teaching students to confront and solve these challenges in an educational context, we prepare them for the problems they will immediately face when they try to deploy AI systems professionally.

The documentation generation domain is particularly timely because code understanding is a major bottleneck in software development that is only getting worse as codebases grow larger and more complex. The shift to remote work and distributed teams makes written documentation even more critical because developers cannot walk over to a colleague's desk to ask questions. AI-powered documentation generation addresses a real, growing problem with increasing commercial value.

## The Bottom Line

This project teaches production AI engineering by having students build a system that solves a real problem under realistic constraints. The problem is significant because poor documentation costs software teams enormous productivity. The constraints are realistic because they reflect the actual limitations of API costs, processing time, and reliability that production systems must satisfy. The solution is non-trivial because it requires systematic engineering rather than just calling an API.

By the time students complete this project, they will have experienced the complete lifecycle of building a production AI system from problem definition through architecture design to implementation and optimization. More importantly, they will have internalized the thinking process required to approach any production AI challenge systematically by understanding the problem deeply, specifying requirements precisely, implementing in phases to manage risk, and measuring success against concrete criteria.

This problem statement provides the foundation for that learning journey by defining exactly what problem we are solving, who we are solving it for, what constraints we must satisfy, and how we will know when we have succeeded.

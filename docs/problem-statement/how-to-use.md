# How to Use This Problem Statement

## The Purpose of Problem Definition

Before writing a single line of code, the best engineering teams spend significant time defining exactly what problem they are solving and for whom. This disciplined approach to problem definition separates professional engineering from hobbyist coding. When you skip this step and jump straight to implementation, you end up building solutions in search of problems, creating technically impressive systems that nobody actually needs or wants to use.

The three documents in this problem statement directory serve different but complementary purposes. The README provides the high-level problem definition, articulating what the real-world problem is, why it matters, what constraints must be satisfied, and how success will be measured. The user scenarios document brings the problem to life through concrete stories of people experiencing the pain points we aim to solve. The technical requirements specification translates the problem and scenarios into testable, measurable requirements that can guide implementation and validation.

Together, these documents form a complete picture of what this documentation generator must accomplish. They provide the foundation for every subsequent technical decision, from architecture choices to API design to optimization strategies. When you face tradeoffs during implementation, you should return to these documents to understand which choice better serves the core requirements.

## For Students Using This Project

If you are a student working through this project as part of the AI Classroom course, these problem statement documents are your north star. Before you start coding Phase 1, read through all three documents carefully to understand not just what you will build but why it matters and who it helps. This context transforms the project from an academic exercise into a realistic simulation of production AI engineering.

As you work through each phase, refer back to the requirements to validate your implementation. When Phase 1 is complete, check which functional requirements you have satisfied and which still need work. When you deliberately break the system in Phase 2, connect the failures back to the constraints and requirements that were violated. When you implement production features in Phase 3, trace each feature to the specific requirement it addresses.

The user scenarios are particularly valuable for understanding motivation. When you implement caching to reduce costs, remember Ankit who cannot afford consultant fees for his open source library. When you add comprehensive error handling, remember Priya who struggles to understand undocumented legacy code. Every feature exists to solve a real problem for a real person, even though these specific people are fictional examples representing real user needs.

The technical requirements give you concrete validation criteria. Your code review workflow integration works correctly if it satisfies IR-1.2 about posting PR comments with documentation. Your cost tracking is complete when it implements all the requirements in FR-4. These requirements remove ambiguity about what "done" means and help you assess the completeness of your implementation.

When you complete this project, you will not just have built a documentation generator. You will have practiced the complete engineering lifecycle from problem definition through requirements specification to phased implementation. This process is how professional AI systems are actually built, and experiencing it in an educational context prepares you for the real challenges you will face in industry.

## For Instructors Teaching This Project

If you are an instructor using this project in your AI engineering curriculum, these problem statement documents provide the pedagogical foundation for the entire course. The documents are deliberately written to be standalone resources that students can read and understand without additional lectures, allowing you to focus class time on hands-on implementation rather than problem explanation.

The progression from problem statement to user scenarios to technical requirements mirrors how professional engineering teams approach new projects. Walking students through this progression teaches them that engineering is not about implementing cool technical features but about solving problems under constraints. The emphasis on constraints, economics, and real-world limitations is intentional because these are the aspects that separate academic AI projects from production systems.

The user scenarios serve as case studies for discussion. Ask students to identify which scenario they find most compelling and why. Have them brainstorm additional scenarios that the current problem statement does not cover. Challenge them to critique the requirements and identify missing or overly restrictive specifications. These discussions help students develop the critical thinking skills needed to evaluate requirements in their future work.

The technical requirements specification provides the basis for grading and assessment. Students can self-evaluate their progress by checking which requirements they have implemented and which remain incomplete. You can structure assignments around implementing specific sets of requirements, allowing students to work incrementally rather than needing to complete the entire system before getting feedback.

The traceability between scenarios, requirements, and implementation teaches students why requirements engineering matters. When a student questions why a particular feature is necessary, you can point to the specific user scenario it addresses and the requirement it satisfies. When implementation decisions seem arbitrary, you can show how they derive from the constraints specified in the problem statement.

The problem statement also sets appropriate expectations about scope and complexity. By clearly defining what is in scope and what is out of scope, you prevent scope creep where students try to add every possible feature and end up completing nothing thoroughly. The phased structure with basic features versus advanced features helps students prioritize work and deliver incrementally rather than attempting to build everything at once.

## Using the Problem Statement During Development

The problem statement is not a document you read once and forget. It should be an active reference throughout the development process. When you face a design decision, consult the requirements to see if they provide guidance. When you consider adding a feature, check whether it addresses a requirement or is just an interesting technical challenge. When you optimize performance, refer back to the performance targets to understand what level of improvement actually matters.

Specific examples of how to use these documents during development include checking the cost requirements before implementing caching to understand what cost reduction target you need to achieve. Reading the reliability requirements before implementing error handling to ensure you cover all the specified failure modes. Reviewing the user scenarios before designing the API to ensure your interface serves the actual use cases that matter.

The problem statement also helps with communication and collaboration. If you are working with teammates, a shared understanding of the problem statement ensures everyone is building toward the same goals. When you encounter disagreements about implementation approaches, you can return to the requirements as neutral arbiters rather than debating opinions. When you present your work to others, starting with the problem statement provides context that makes your technical decisions understandable.

The problem statement evolves as you learn more about the domain and discover requirements that were not initially apparent. If you encounter user needs that are not addressed by the current requirements, document them as potential additions. If you find requirements that conflict or are impossible to satisfy simultaneously, note the tradeoffs and document your resolution. The problem statement should be a living document that reflects your current understanding, not a static artifact frozen at project start.

## Common Pitfalls to Avoid

Several common mistakes emerge when developers work from requirements without fully internalizing the problem statement. The first is treating requirements as a checklist to satisfy mechanically without understanding their purpose. You can implement every requirement literally while completely missing the point if you do not understand the underlying problem each requirement addresses.

Another pitfall is optimizing for the wrong metrics because you did not internalize the constraints. For example, you might focus on generating the most comprehensive documentation possible when the real constraint is generating adequate documentation within cost limits. Comprehensiveness without economic viability makes the system unusable in practice, but you would not realize this without understanding the cost constraints specified in the problem statement.

A third pitfall is adding features that seem cool but do not address any specified requirement. This is scope creep driven by technical curiosity rather than user needs. While exploration and experimentation have value in learning, they should be clearly distinguished from work toward the core requirements. Features that do not trace back to requirements are suspect until proven necessary.

A fourth pitfall is treating the problem statement as fixed when you discover it does not fully capture reality. If you find that the problem statement is wrong or incomplete, update it rather than working around it. Requirements specification is an iterative process where early assumptions are tested against reality and refined based on what you learn. Treating the problem statement as immutable leads to building systems that solve the wrong problem correctly.

## Connecting Problem Definition to Architecture

The architecture of this documentation generator flows directly from the problem statement. The three-phase structure addresses the educational requirement to teach not just working solutions but the process of discovering why naive solutions fail and how to fix them systematically. The Phase 1 POC satisfies the functional requirements in a simple way that is easy to understand but violates several non-functional requirements around cost, performance, and scalability.

Phase 2 deliberately breaks the system by pushing it beyond the limits specified in the performance and cost requirements. This breaking phase exists because one of the core educational goals is teaching students to recognize and handle constraint violations. By experiencing failure in a controlled environment, students develop intuition about what breaks and why, which prepares them for the inevitable failures they will encounter in production systems.

Phase 3 addresses the violations discovered in Phase 2 by implementing features that satisfy the non-functional requirements. Caching implements the cost optimization requirements. Chunking implements the scalability requirements for large codebases. Rate limiting and retry logic implement the reliability requirements. Distributed processing with ECS implements the performance requirements for concurrent workloads. Each production feature traces back to specific requirements that Phase 1 violated.

The modular architecture with separate components for code analysis, Claude interaction, cost tracking, and caching reflects the maintainability requirements. Each component can be tested independently, modified without affecting others, and extended with new capabilities. The modularity also supports the extensibility requirement for adding new programming languages by isolating language-specific parsing logic.

The choice of AWS services traces back to specific requirements. Lambda satisfies the requirement for serverless deployment without managing infrastructure. DynamoDB satisfies the caching requirements with fast key-value lookups and automatic expiration. S3 satisfies the documentation storage requirements with versioning and lifecycle policies. CloudWatch satisfies the monitoring requirements with logs and metrics. Each technology choice exists to satisfy specific requirements rather than being selected based on popularity or familiarity.

## Measuring Success Against the Problem Statement

The problem statement defines success through specific quantitative and qualitative metrics. As you complete each phase of the project, evaluate your implementation against these success criteria to determine whether you have actually solved the problem.

For cost metrics, measure the actual cost to document a fifty-thousand-line repository and compare it to the target of under five hundred rupees. If your costs are significantly higher, you have not yet satisfied the economic constraints and need to implement additional optimizations. If your costs are much lower, document what optimizations you implemented and whether they compromise other requirements like documentation quality.

For performance metrics, measure the time to process repositories of different sizes and compare to the targets specified in the requirements. Create test repositories at ten thousand lines, fifty thousand lines, and one hundred thousand lines. Time how long documentation generation takes for each size. If you exceed the performance targets, profile your code to identify bottlenecks and implement optimizations that bring you within the required range.

For quality metrics, have people unfamiliar with the code read your generated documentation and assess whether they can understand what the code does. This qualitative evaluation is harder to quantify than cost or performance but arguably more important because documentation that is fast and cheap but unintelligible has no value. Consider using rubrics based on the quality criteria in the requirements such as completeness, accuracy, clarity, and actionability.

For reliability metrics, deliberately inject failures like network errors, malformed code, and API rate limits. Verify that your system handles these failures gracefully according to the reliability requirements. A production system must handle failure cases elegantly rather than crashing or producing incorrect results. Test that cache invalidation works correctly by modifying code and verifying that documentation updates. Test that retry logic actually retries on rate limits rather than giving up immediately.

When you complete Phase 3 and have implemented all the production features, perform a comprehensive evaluation against the entire requirements specification. Create a traceability matrix showing which code modules implement which requirements. Identify any requirements that remain partially or completely unimplemented and assess whether those gaps are acceptable for your use case or require additional work.

## The Bigger Picture

This problem statement teaches you a transferable skill that applies far beyond code documentation. Every production AI system you build professionally will start with similar problem definition work. You will need to understand real user pain points, identify constraints around cost and performance, specify functional and non-functional requirements, and measure success against concrete criteria.

The specific domain of code documentation is chosen because it is complex enough to require production engineering patterns but simple enough to implement in a course timeframe. The skills you develop around cost optimization, reliability engineering, scalable architectures, and requirement-driven development transfer directly to other AI applications like customer support chatbots, content generation systems, data analysis tools, and decision support systems.

The emphasis on constraints and tradeoffs reflects the reality that all engineering is optimization under constraints. Unlimited resources would make most technical problems trivial. The interesting challenges emerge when you must balance competing requirements like cost versus quality, speed versus accuracy, or simplicity versus flexibility. Learning to navigate these tradeoffs systematically is what separates junior engineers from senior engineers.

The problem statement approach also teaches you to think from the user perspective rather than the technology perspective. Many AI engineers fall into the trap of focusing on what is technically possible with LLMs without considering whether those capabilities actually solve problems people care about. By starting with user scenarios and working backward to technical requirements, you develop the habit of building for users rather than for the sake of building.

Finally, the problem statement instills discipline about defining success before starting implementation. Without clear success criteria, you can work indefinitely without knowing whether you are making progress toward a goal or just adding features that seem interesting. The metrics and requirements in the problem statement give you a definition of done that prevents endless feature creep and allows you to ship a complete, useful system rather than an perpetually incomplete experiment.

The time you invest in understanding this problem statement will pay dividends throughout the project and throughout your career as an AI engineer. Take it seriously, refer to it often, and use it as the foundation for every technical decision you make.

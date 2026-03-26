# Senior Code Review Skill

## Description
Performs a deep, senior-level code review of all staged (uncommitted) changes in the git repository.  
The review focuses on architectural decisions, design quality, long-term maintainability, and risk assessment—not just code style.

The output is a structured markdown report saved as:
`review_<BRANCH_NAME>_<COUNTER>.md` in the project root.

## Usage
Invoke this skill before committing when you want a **high-signal, expert-level review** that challenges the solution and highlights deeper issues.

## Output
- Generates: `review_<branch_name>_<number>.md`
- Branch name is sanitized (slashes → underscores)
- Counter auto-increments per branch

## Review Scope
This is not a superficial lint-style review. It evaluates:

### 1. **Context & Intent**
- What problem is being solved?
- Does the implementation actually address it correctly?
- Are there simpler or more robust approaches?

### 2. **Architecture & Design**
- Is the solution aligned with the system’s architecture?
- Separation of concerns and modularity
- Coupling vs cohesion
- Scalability and extensibility implications
- Violations of established patterns or introduction of anti-patterns

### 3. **Solution Quality**
- Is this the *right* solution or just a working one?
- Overengineering vs underengineering
- Hidden complexity and maintainability risks
- Trade-offs made (explicit or accidental)

### 4. **Code & Practices**
- Readability and clarity of intent
- Naming and abstraction quality
- Misuse of frameworks, libraries, or patterns
- Consistency with existing codebase conventions

### 5. **Risk Analysis**
- Edge cases and failure modes
- Backward compatibility risks
- Hidden bugs or undefined behavior
- Security concerns (data exposure, injection risks, etc.)
- Performance implications under load

### 6. **Testing & Validation**
- Are critical paths covered?
- Are tests meaningful or superficial?
- Missing edge case coverage
- Test design quality (not just presence)

### 7. **Diff Awareness**
- Focus on *what changed* and *why it matters*
- Identify unintended side effects of changes
- Highlight risky modifications in sensitive areas

## Output Structure
The review document includes:

1. **Branch Overview**
   - Branch name
   - High-level summary of intent (inferred if needed)

2. **Staged Files**
   - List of modified/added/deleted files

3. **Key Findings (High Priority)**
   - Critical architectural or design concerns
   - Major risks or incorrect approaches

4. **Detailed Review**
   - File-by-file or concern-by-concern analysis
   - Deep reasoning, not just observations

5. **Architectural Assessment**
   - Impact on system design
   - Long-term consequences

6. **Risks & Edge Cases**
   - What could break and how

7. **Recommendations**
   - Concrete improvements
   - Alternative approaches where relevant

8. **Verdict**
   - Ready to merge / Needs revision / Blocker
   - Clear justification

## Files
- `review.sh` — Main script responsible for generating the review

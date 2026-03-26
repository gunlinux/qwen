# Test Documentation Generator Skill

## Description
Analyzes test files in a project and generates comprehensive documentation about test code styles, patterns, and conventions. This helps teams maintain consistent testing practices across the codebase.

The output is a structured markdown report saved as:
`test_docs_<BRANCH_NAME>_<COUNTER>.md` in the project root.

## Usage
Invoke this skill when you want to:
- Document existing test patterns for new team members
- Identify inconsistencies in test writing styles
- Establish testing conventions for a project
- Audit test code quality before a major refactor

## Output
- Generates: `test_docs_<branch_name>_<number>.md`
- Branch name is sanitized (slashes → underscores)
- Counter auto-increments per branch

## Analysis Scope

### 1. **Test File Structure**
- File naming conventions (`test_*.py`, `*_test.py`, `*.test.js`, etc.)
- Directory organization and module structure
- Import patterns and organization

### 2. **Test Naming Conventions**
- Test function/method naming patterns
- Descriptive naming vs technical naming
- Consistency in describing behavior

### 3. **Test Organization**
- Use of test classes vs standalone functions
- Grouping by feature, module, or behavior
- Fixture/setup method patterns

### 4. **Assertion Styles**
- Assertion libraries used (pytest assert, unittest, chai, jest, etc.)
- Consistency in assertion patterns
- Use of custom matchers or helpers

### 5. **Test Patterns & Practices**
- AAA pattern usage (Arrange-Act-Assert)
- Mocking and stubbing approaches
- Parameterized tests usage
- Test data management strategies

### 6. **Code Quality Metrics**
- Average test length
- Code duplication in tests
- Test independence and isolation
- Coverage of edge cases

### 7. **Framework Usage**
- Testing frameworks detected (pytest, unittest, jest, mocha, etc.)
- Framework-specific features usage (fixtures, hooks, decorators)
- Plugin or extension usage

### 8. **Recommendations**
- Identified inconsistencies
- Suggested improvements for consistency
- Best practices adoption opportunities

## Output Structure

The documentation includes:

1. **Project Overview**
   - Project name and branch
   - Test framework(s) detected
   - Total test files and test cases

2. **Test File Inventory**
   - List of all test files
   - Directory structure visualization
   - File size distribution

3. **Naming Convention Analysis**
   - Detected naming patterns
   - Examples of good naming
   - Inconsistencies found

4. **Structural Patterns**
   - Common test structures
   - Fixture/setup patterns
   - Teardown patterns

5. **Assertion Analysis**
   - Assertion styles used
   - Common assertion patterns
   - Custom assertions or helpers

6. **Test Quality Indicators**
   - Test length distribution
   - Duplication hotspots
   - Independence score

7. **Framework Features**
   - Features in use
   - Underutilized features
   - Recommended features

8. **Consistency Report**
   - Areas of high consistency
   - Areas needing improvement
   - Specific examples

9. **Recommendations**
   - Style guide suggestions
   - Refactoring opportunities
   - Tool recommendations (linters, formatters)

10. **Appendix**
    - Code examples from the project
    - Reference implementations
    - Quick reference guide

## Files
- `test_docs.sh` — Main script responsible for generating the test documentation

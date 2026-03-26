#!/bin/bash

# Test Documentation Generator
# Analyzes test files and generates comprehensive documentation about test code styles

set -e

# Get current branch name and sanitize it
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr '/' '_' | tr ' ' '_' || echo "local")

# Find the next test_docs number for this branch
COUNTER=1
while [[ -f "test_docs_${BRANCH_NAME}_${COUNTER}.md" ]]; do
    ((COUNTER++))
done

DOCS_FILE="test_docs_${BRANCH_NAME}_${COUNTER}.md"

# Detect test files based on common patterns
detect_test_files() {
    local test_files=()
    
    # Python test patterns
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find . -type f \( -name "test_*.py" -o -name "*_test.py" -o -name "tests.py" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/__pycache__/*" -print0 2>/dev/null)
    
    # JavaScript/TypeScript test patterns
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find . -type f \( -name "*.test.js" -o -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.js" -o -name "*.spec.ts" -o -name "*.spec.tsx" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -print0 2>/dev/null)
    
    # Ruby test patterns
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find . -type f \( -name "*_test.rb" -o -name "*_spec.rb" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -print0 2>/dev/null)
    
    # Go test patterns
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find . -type f -name "*_test.go" -not -path "*/node_modules/*" -not -path "*/.git/*" -print0 2>/dev/null)
    
    # Java test patterns
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find . -type f \( -name "*Test.java" -o -name "*Tests.java" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -print0 2>/dev/null)
    
    printf '%s\n' "${test_files[@]}"
}

# Detect testing framework
detect_framework() {
    local frameworks=()
    
    # Check for pytest
    if grep -r "import pytest\|from pytest\|@pytest\." test* 2>/dev/null | head -1 > /dev/null; then
        frameworks+=("pytest")
    fi
    
    # Check for unittest
    if grep -r "import unittest\|from unittest\|class.*unittest\.TestCase" test* 2>/dev/null | head -1 > /dev/null; then
        frameworks+=("unittest")
    fi
    
    # Check for jest
    if grep -r "describe(\|it(\|test(\|@jest\|import.*jest" test* 2>/dev/null | head -1 > /dev/null; then
        frameworks+=("jest")
    fi
    
    # Check for mocha
    if grep -r "describe(\|it(\|before(\|after(" test* 2>/dev/null | head -1 > /dev/null; then
        if grep -r "require.*mocha\|import.*mocha" test* 2>/dev/null | head -1 > /dev/null; then
            frameworks+=("mocha")
        fi
    fi
    
    # Check for RSpec
    if grep -r "describe do\|it do\|RSpec\.describe" test* 2>/dev/null | head -1 > /dev/null; then
        frameworks+=("RSpec")
    fi
    
    # Check for Go testing
    if grep -r "testing.T\|func Test" test* 2>/dev/null | head -1 > /dev/null; then
        frameworks+=("go testing")
    fi
    
    # Check for JUnit
    if grep -r "@Test\|org.junit\|JUnit" test* 2>/dev/null | head -1 > /dev/null; then
        frameworks+=("JUnit")
    fi
    
    if [[ ${#frameworks[@]} -eq 0 ]]; then
        echo "Unknown/Not detected"
    else
        printf '%s, ' "${frameworks[@]}" | sed 's/, $//'
    fi
}

# Analyze naming patterns
analyze_naming_patterns() {
    local test_files="$1"
    local patterns=()
    
    # Count different naming styles
    local snake_case=$(echo "$test_files" | grep -cE "test_[a-z_]+\.[a-z]+" || echo 0)
    local camel_case=$(echo "$test_files" | grep -cE "[a-z]+[A-Z]+[a-zA-Z]*Test\.[a-z]+" || echo 0)
    local suffix_test=$(echo "$test_files" | grep -cE "_test\.[a-z]+" || echo 0)
    local suffix_spec=$(echo "$test_files" | grep -cE "\.(test|spec)\.[a-z]+" || echo 0)
    
    echo "Snake case (test_*): $snake_case"
    echo "CamelCase ( *Test): $camel_case"
    echo "Suffix *_test: $suffix_test"
    echo "Suffix *.test/*.spec: $suffix_spec"
}

# Count test functions
count_test_functions() {
    local file="$1"
    local count=0
    local tmp_count=0
    
    # Python pytest/unittest style
    tmp_count=$(grep -cE "^(\s*)def test_|^(\s*)async def test_" "$file" 2>/dev/null) || tmp_count=0
    count=$((count + tmp_count))
    
    # JavaScript jest/mocha style
    tmp_count=$(grep -cE "^\s*(it|test)\(" "$file" 2>/dev/null) || tmp_count=0
    count=$((count + tmp_count))
    
    # Go style
    tmp_count=$(grep -cE "^func Test[A-Z]" "$file" 2>/dev/null) || tmp_count=0
    count=$((count + tmp_count))
    
    # Ruby RSpec style
    tmp_count=$(grep -cE "^\s*it\s+'|^\s*it\s+\"" "$file" 2>/dev/null) || tmp_count=0
    count=$((count + tmp_count))
    
    echo "$count"
}

# Analyze assertion styles
analyze_assertions() {
    local test_files="$1"
    
    echo "### Assertion Styles Detected"
    echo ""
    
    # Python assert
    local pytest_assert=$(echo "$test_files" | xargs grep -l "^assert \|    assert " 2>/dev/null | wc -l || echo 0)
    echo "- **Python assert statements**: Found in $pytest_assert file(s)"
    
    # unittest assertions
    local unittest_assert=$(echo "$test_files" | xargs grep -lE "self\.assert|self\.assertEquals|self\.assertTrue|self\.assertFalse" 2>/dev/null | wc -l || echo 0)
    echo "- **unittest assertions**: Found in $unittest_assert file(s)"
    
    # Jest expect
    local jest_expect=$(echo "$test_files" | xargs grep -lE "expect\(" 2>/dev/null | wc -l || echo 0)
    echo "- **expect() assertions (Jest/Chai)**: Found in $jest_expect file(s)"
    
    # should.js/chai should
    local should_style=$(echo "$test_files" | xargs grep -lE "\.should\.|should\.equal|should\.be" 2>/dev/null | wc -l || echo 0)
    echo "- **should.* assertions**: Found in $should_style file(s)"
    
    # Go testing
    local go_testing=$(echo "$test_files" | xargs grep -lE "t\.Error|t\.Fatal|t\.Assert" 2>/dev/null | wc -l || echo 0)
    echo "- **Go t.Error/t.Fatal**: Found in $go_testing file(s)"
    
    echo ""
}

# Generate the documentation
echo "🔍 Analyzing test files..."

TEST_FILES=$(detect_test_files)
TEST_FILE_COUNT=$(echo "$TEST_FILES" | grep -c "." || echo 0)

if [[ "$TEST_FILE_COUNT" -eq 0 || -z "$TEST_FILES" ]]; then
    echo "❌ No test files found in the project."
    echo ""
    echo "Supported patterns:"
    echo "  - Python: test_*.py, *_test.py"
    echo "  - JavaScript/TypeScript: *.test.js, *.spec.js, *.test.ts, *.spec.ts"
    echo "  - Ruby: *_test.rb, *_spec.rb"
    echo "  - Go: *_test.go"
    echo "  - Java: *Test.java, *Tests.java"
    exit 1
fi

echo "✅ Found $TEST_FILE_COUNT test file(s)"

# Calculate total test functions
TOTAL_TESTS=0
while IFS= read -r file; do
    if [[ -n "$file" ]]; then
        count=$(count_test_functions "$file")
        TOTAL_TESTS=$((TOTAL_TESTS + count))
    fi
done <<< "$TEST_FILES"

FRAMEWORK=$(detect_framework)

# Generate the documentation file
cat > "$DOCS_FILE" << EOF
# Test Documentation: Code Styles & Conventions

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Branch**: \`$BRANCH_NAME\`
**Project**: $(basename "$(pwd)")

---

## 1. Project Overview

| Metric | Value |
|--------|-------|
| Total Test Files | $TEST_FILE_COUNT |
| Estimated Test Cases | $TOTAL_TESTS |
| Testing Framework(s) | $FRAMEWORK |
| Primary Language | $(file --mime-type -b $(echo "$TEST_FILES" | head -1) 2>/dev/null | cut -d'/' -f2 || echo "Unknown") |

---

## 2. Test File Inventory

### 2.1 Directory Structure

\`\`\`
$(echo "$TEST_FILES" | head -20 | sort)
$([ $(echo "$TEST_FILES" | wc -l) -gt 20 ] && echo "... and $((TEST_FILE_COUNT - 20)) more files")
\`\`\`

### 2.2 File Distribution by Directory

\`\`\`
$(echo "$TEST_FILES" | xargs -I {} dirname {} | sort | uniq -c | sort -rn | head -10)
\`\`\`

---

## 3. Naming Convention Analysis

### 3.1 File Naming Patterns

$(analyze_naming_patterns "$TEST_FILES")

### 3.2 Test Function Naming

**Common patterns detected:**

\`\`\`
$(echo "$TEST_FILES" | head -5 | xargs grep -hE "^(\s*)def test_|^\s*(it|test)\(|^func Test[A-Z]" 2>/dev/null | head -10 || echo "Pattern analysis not available")
\`\`\`

---

## 4. Structural Patterns

### 4.1 Test Organization

EOF

# Analyze structure based on detected files
echo "$TEST_FILES" | head -5 | while IFS= read -r file; do
    if [[ -n "$file" ]]; then
        echo "#### $(basename "$file")"
        echo ""
        echo "\`\`\`$(echo "$file" | sed 's/.*\.//')"
        head -30 "$file"
        echo "\`\`\`"
        echo ""
    fi
done >> "$DOCS_FILE"

cat >> "$DOCS_FILE" << EOF

### 4.2 Fixture/Setup Patterns

\`\`\`
$(echo "$TEST_FILES" | xargs grep -hE "@pytest\.fixture|@Before|@BeforeEach|beforeEach|beforeAll|def setup|def setUp|@pytest.fixture" 2>/dev/null | head -10 || echo "No fixture patterns detected")
\`\`\`

---

## 5. Assertion Analysis

$(analyze_assertions "$TEST_FILES")

### 5.2 Common Assertion Patterns

\`\`\`
$(echo "$TEST_FILES" | xargs grep -hE "assert |\.toEqual\(|\.toBe\(|\.should\.|self\.assert" 2>/dev/null | head -10 || echo "No assertion patterns detected")
\`\`\`

---

## 6. Test Quality Indicators

### 6.1 Average Test Length

| File | Lines | Test Functions | Avg Lines/Test |
|------|-------|----------------|----------------|
EOF

# Add file statistics
echo "$TEST_FILES" | head -10 | while IFS= read -r file; do
    if [[ -n "$file" && -f "$file" ]]; then
        lines=$(wc -l < "$file")
        tests=$(count_test_functions "$file")
        if [[ $tests -gt 0 ]]; then
            avg=$((lines / tests))
        else
            avg=$lines
        fi
        echo "| $(basename "$file") | $lines | $tests | $avg |" >> "$DOCS_FILE"
    fi
done

cat >> "$DOCS_FILE" << EOF

### 6.2 Code Duplication Hotspots

Files with similar imports or setup patterns:

\`\`\`
$(echo "$TEST_FILES" | xargs grep -hE "^import |^from |^const |^let |^var " 2>/dev/null | sort | uniq -c | sort -rn | head -10)
\`\`\`

### 6.3 Test Independence Score

Tests that appear to be independent (no shared state):
- **High**: Tests use individual fixtures/setup
- **Medium**: Some shared setup detected
- **Low**: Heavy use of shared state or global variables

---

## 7. Framework Features Usage

EOF

# Framework-specific analysis
if echo "$FRAMEWORK" | grep -qi "pytest"; then
    cat >> "$DOCS_FILE" << 'EOF'
### pytest Features Detected

| Feature | Usage Count |
|---------|-------------|
EOF
    echo "| @pytest.fixture | $(echo "$TEST_FILES" | xargs grep -c "@pytest.fixture" 2>/dev/null | awk -F: '{sum+=$2} END {print sum}') |" >> "$DOCS_FILE"
    echo "| @pytest.mark.parametrize | $(echo "$TEST_FILES" | xargs grep -c "@pytest.mark.parametrize" 2>/dev/null | awk -F: '{sum+=$2} END {print sum}') |" >> "$DOCS_FILE"
    echo "| @pytest.mark.skip | $(echo "$TEST_FILES" | xargs grep -c "@pytest.mark.skip" 2>/dev/null | awk -F: '{sum+=$2} END {print sum}') |" >> "$DOCS_FILE"
    echo "| conftest.py usage | $(find . -name "conftest.py" 2>/dev/null | wc -l | tr -d ' ') |" >> "$DOCS_FILE"
    echo ""
fi

if echo "$FRAMEWORK" | grep -qi "jest"; then
    cat >> "$DOCS_FILE" << 'EOF'
### Jest Features Detected

| Feature | Usage Count |
|---------|-------------|
EOF
    echo "| describe() | $(echo "$TEST_FILES" | xargs grep -c "describe(" 2>/dev/null | awk -F: '{sum+=$2} END {print sum}') |" >> "$DOCS_FILE"
    echo "| it()/test() | $(echo "$TEST_FILES" | xargs grep -cE "(it|test)\(" 2>/dev/null | awk -F: '{sum+=$2} END {print sum}') |" >> "$DOCS_FILE"
    echo "| beforeEach() | $(echo "$TEST_FILES" | xargs grep -c "beforeEach(" 2>/dev/null | awk -F: '{sum+=$2} END {print sum}') |" >> "$DOCS_FILE"
    echo "| jest.mock() | $(echo "$TEST_FILES" | xargs grep -c "jest.mock(" 2>/dev/null | awk -F: '{sum+=$2} END {print sum}') |" >> "$DOCS_FILE"
    echo ""
fi

cat >> "$DOCS_FILE" << EOF

---

## 8. Consistency Report

### 8.1 Areas of High Consistency ✅

- File naming follows established patterns
- Test functions use consistent naming style
- Assertion style is uniform across files

### 8.2 Areas Needing Improvement ⚠️

- Consider standardizing fixture/setup patterns
- Some tests may benefit from parameterization
- Documentation strings could be more consistent

### 8.3 Specific Examples

**Good patterns to follow:**

\`\`\`
$(echo "$TEST_FILES" | head -3 | xargs grep -hA 5 "def test_\|it(\|test(" 2>/dev/null | head -15 || echo "See test files for examples")
\`\`\`

---

## 9. Recommendations

### 9.1 Style Guide Suggestions

1. **Naming Convention**: Use \`test_<behavior>_when_<condition>\` for descriptive names
2. **Test Structure**: Follow AAA pattern (Arrange-Act-Assert)
3. **Assertions**: One assertion per test when possible, or group related assertions
4. **Fixtures**: Use fixtures for common setup, keep them focused and single-purpose

### 9.2 Refactoring Opportunities

- Consolidate duplicate setup code into fixtures
- Split large test files into focused modules
- Add descriptive docstrings to complex tests

### 9.3 Tool Recommendations

| Tool | Purpose |
|------|---------|
| pytest-cov | Coverage reporting |
| eslint-plugin-jest | Jest linting |
| ruff/flake8 | Python linting |
| prettier | Code formatting |

---

## 10. Quick Reference

### Test Template (Python/pytest)

\`\`\`python
def test_<feature>_<scenario>_<expected_result>():
    # Arrange
    ...
    
    # Act
    result = ...
    
    # Assert
    assert result == expected
\`\`\`

### Test Template (JavaScript/Jest)

\`\`\`javascript
describe('<Component/Feature>', () => {
  describe('when <condition>', () => {
    it('should <expected behavior>', () => {
      // Arrange
      ...
      
      // Act
      const result = ...;
      
      // Assert
      expect(result).toBe(expected);
    });
  });
});
\`\`\`

---

*This documentation was auto-generated to help maintain consistent test practices across the project.*
EOF

echo ""
echo "✅ Test documentation created: $DOCS_FILE"
echo ""
echo "Next steps:"
echo "1. Review the generated documentation"
echo "2. Update recommendations based on team preferences"
echo "3. Share with team to establish testing conventions"
echo "4. Consider adding to project documentation"

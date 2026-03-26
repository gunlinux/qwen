#!/bin/bash

# Code Review Generator
# Generates a markdown review of staged git changes

set -e

# Get current branch name and sanitize it
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | tr '/' '_' | tr ' ' '_')

# Find the next review number for this branch
COUNTER=1
while [[ -f "review_${BRANCH_NAME}_${COUNTER}.md" ]]; do
    ((COUNTER++))
done

REVIEW_FILE="review_${BRANCH_NAME}_${COUNTER}.md"

# Get staged files
STAGED_FILES=$(git diff --cached --name-only)

if [[ -z "$STAGED_FILES" ]]; then
    echo "❌ No staged changes found. Please stage files first with 'git add'."
    exit 1
fi

# Get the diff
DIFF_CONTENT=$(git diff --cached)

# Generate the review file
cat > "$REVIEW_FILE" << EOF
# Code Review: $BRANCH_NAME

**Review File**: \`$REVIEW_FILE\`  
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')  
**Branch**: \`$BRANCH_NAME\`

---

## 1. Staged Files Summary

Total files changed: $(echo "$STAGED_FILES" | wc -l | tr -d ' ')

\`\`\`
$(echo "$STAGED_FILES")
\`\`\`

---

## 2. Changes Overview

\`\`\`diff
$DIFF_CONTENT
\`\`\`

---

## 3. Code Quality Assessment

### 3.1 Code Style & Conventions
<!-- AI to analyze: Are naming conventions followed? Is formatting consistent? -->

### 3.2 Potential Bugs
<!-- AI to analyze: Check for null checks, error handling, edge cases -->

### 3.3 Security Concerns
<!-- AI to analyze: Look for hardcoded secrets, SQL injection risks, input validation -->

### 3.4 Performance Implications
<!-- AI to analyze: Identify inefficient algorithms, unnecessary operations -->

### 3.5 Test Coverage
<!-- AI to analyze: Are tests included? Do they cover edge cases? -->

---

## 4. Recommendations

<!-- AI to provide specific recommendations based on the changes -->

---

## 5. Review Checklist

- [ ] Code follows project conventions
- [ ] No hardcoded secrets or sensitive data
- [ ] Error handling is adequate
- [ ] Tests are included/updated
- [ ] Documentation is updated (if needed)
- [ ] No performance regressions
- [ ] Security considerations addressed

---

*This review was auto-generated. Please complete the assessment sections above.*
EOF

echo "✅ Review created: $REVIEW_FILE"
echo ""
echo "Next steps:"
echo "1. Open the review file and complete the assessment sections"
echo "2. Address any issues found"
echo "3. Commit changes with the review file"

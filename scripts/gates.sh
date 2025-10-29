#!/bin/sh

# Change to repo root
cd "$(dirname "$0")/../"

# Ensure GOPATH/bin is in PATH for golangci-lint
export PATH="$(go env GOPATH)/bin:$PATH"

echo "🔍 Running Test Gates..."
echo "========================="

# Track failures and test stats
FAILURES=0
GO_TESTS_RAN=0
GO_TESTS_PASSED=0
GO_TESTS_FAILED=0
GO_TEST_STATUS=0
GO_LINT_STATUS=0
FRONTEND_LINT_STATUS=0

# Backend Tests
echo ""
echo "🧪 Running Go tests..."
# Capture test output and parse results
TEST_OUTPUT=$(go test ./... -json 2>&1) || GO_TEST_STATUS=$?

# Parse test results from JSON output
if [ -n "$TEST_OUTPUT" ]; then
    GO_TESTS_RAN=$(printf '%s' "$TEST_OUTPUT" | awk '/"Action":"run"/ && /"Test":/ {count++} END {print count+0}')
    GO_TESTS_PASSED=$(printf '%s' "$TEST_OUTPUT" | awk '/"Action":"pass"/ && /"Test":/ {count++} END {print count+0}')
    GO_TESTS_FAILED=$(printf '%s' "$TEST_OUTPUT" | awk '/"Action":"fail"/ && /"Test":/ {count++} END {print count+0}')

    GO_TESTS_RAN=${GO_TESTS_RAN:-0}
    GO_TESTS_PASSED=${GO_TESTS_PASSED:-0}
    GO_TESTS_FAILED=${GO_TESTS_FAILED:-0}
fi

# Show test output if there were failures
if [ "$GO_TEST_STATUS" -ne 0 ]; then
    echo "$TEST_OUTPUT" | grep -v '"Action":"output"' | grep -E '(fail|ok|FAIL)' | head -20
    echo "❌ Go tests failed"
    FAILURES=$((FAILURES + 1))
else
    echo "✅ Go tests passed"
fi

# Backend Linting
echo ""
echo "🔍 Running golangci-lint..."
if ! command -v golangci-lint >/dev/null 2>&1; then
    echo "❌ golangci-lint not found. Gates failed."
    echo ""
    echo "Please install golangci-lint first:"
    echo "  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
    echo ""
    echo "Then re-run: ./scripts/gates.sh"
    FAILURES=$((FAILURES + 1))
    GO_LINT_STATUS=1
else
    # Run golangci-lint and capture output
    LINT_OUTPUT=$(golangci-lint run 2>&1) || GO_LINT_STATUS=$?
    if [ -n "$GO_LINT_STATUS" ] && [ "$GO_LINT_STATUS" -ne 0 ]; then
        echo "$LINT_OUTPUT"
        # Check for Go version mismatch error
        if echo "$LINT_OUTPUT" | grep -q "Go language version.*used to build golangci-lint.*lower than"; then
            echo ""
            echo "⚠️  golangci-lint version mismatch detected."
            echo "   This usually means golangci-lint needs to be rebuilt with your current Go version."
            echo "   Try: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
            echo "   Or build from source: https://github.com/golangci/golangci-lint#local-installation"
        fi
        echo "❌ Go linting failed"
        FAILURES=$((FAILURES + 1))
    else
        echo "✅ Go linting passed"
        GO_LINT_STATUS=0
    fi
fi

# Frontend Linting
echo ""
echo "🔍 Running frontend linting..."
if ! command -v pnpm >/dev/null 2>&1; then
    echo "❌ pnpm not found. Gates failed."
    echo ""
    echo "Please install pnpm first:"
    echo "  npm install -g pnpm"
    echo "  or visit: https://pnpm.io/installation"
    echo ""
    echo "Then re-run: ./scripts/gates.sh"
    FAILURES=$((FAILURES + 1))
    FRONTEND_LINT_STATUS=1
else
    cd web
    if ! pnpm lint; then
        echo "❌ Frontend linting failed"
        FAILURES=$((FAILURES + 1))
        FRONTEND_LINT_STATUS=1
    else
        echo "✅ Frontend linting passed"
        FRONTEND_LINT_STATUS=0
    fi
    cd ..
fi

# Print summary
echo ""
echo "========================="
echo "📊 Summary:"
if [ "$GO_TESTS_RAN" -gt 0 ]; then
    if [ "$GO_TESTS_FAILED" -eq 0 ]; then
        echo "  ✅ Tests: $GO_TESTS_PASSED/$GO_TESTS_RAN passed"
    else
        echo "  ❌ Tests: $GO_TESTS_PASSED passed, $GO_TESTS_FAILED failed (out of $GO_TESTS_RAN)"
    fi
fi
if [ "$GO_LINT_STATUS" -eq 0 ]; then
    echo "  ✅ Go lint: passed"
else
    echo "  ❌ Go lint: failed"
fi
if [ "$FRONTEND_LINT_STATUS" -eq 0 ]; then
    echo "  ✅ Frontend lint: passed"
else
    echo "  ❌ Frontend lint: failed"
fi

if [ $FAILURES -eq 0 ]; then
    echo ""
    echo "🎉 All gates passed!"
    exit 0
else
    echo ""
    echo "💥 $FAILURES gate(s) failed"
    exit 1
fi

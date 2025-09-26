# ZPA App Connector Modules Makefile

.PHONY: help test test-validate test-plan test-apply test-idempotence test-clean install-deps

# Default target
help:
	@echo "Available targets:"
	@echo "  install-deps     - Install Go dependencies"
	@echo "  test            - Run all tests"
	@echo "  test-validate   - Run validation tests only"
	@echo "  test-plan       - Run plan tests only"
	@echo "  test-apply      - Run apply tests only"
	@echo "  test-idempotence - Run idempotence tests only"
	@echo "  test-clean      - Clean up test artifacts"

# Install dependencies
install-deps:
	@echo "Installing Go dependencies..."
	go mod tidy
	go mod download

# Run all tests
test: install-deps
	@echo "Running all tests..."
	go test ./test/... -v

# Run validation tests only
test-validate: install-deps
	@echo "Running validation tests..."
	go test ./test/... -v -run TestValidate

# Run plan tests only
test-plan: install-deps
	@echo "Running plan tests..."
	go test ./test/... -v -run TestPlan

# Run apply tests only
test-apply: install-deps
	@echo "Running apply tests..."
	go test ./test/... -v -run TestApply

# Run idempotence tests only
test-idempotence: install-deps
	@echo "Running idempotence tests..."
	go test ./test/... -v -run TestIdempotence

# Clean up test artifacts
test-clean:
	@echo "Cleaning up test artifacts..."
	find ./test -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find ./test -name "terraform.tfstate*" -type f -exec rm -f {} + 2>/dev/null || true
	find ./test -name ".terraform.lock.hcl" -type f -exec rm -f {} + 2>/dev/null || true

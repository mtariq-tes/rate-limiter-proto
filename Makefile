# ─────────────────────────────────────────────────────────────
# VARIABLES
# ─────────────────────────────────────────────────────────────
PROTO_DIR       := proto
PROTO_GEN_DIR   := proto/gen
PROTO_FILE      := $(PROTO_DIR)/ratelimiter.proto

PROTOC          := protoc
PROTOC_GEN_GO   := $(shell which protoc-gen-go)
PROTOC_GEN_GRPC := $(shell which protoc-gen-go-grpc)

# ─────────────────────────────────────────────────────────────
# DEFAULT
# ─────────────────────────────────────────────────────────────
.DEFAULT_GOAL := help

# ─────────────────────────────────────────────────────────────
# HELP
# ─────────────────────────────────────────────────────────────
.PHONY: help
help:
	@echo ""
	@echo "  Distributed Rate Limiter — Makefile"
	@echo ""
	@echo "  Usage:"
	@echo "    make generate_proto   Generate Go code from .proto files"
	@echo "    make clean_proto      Delete all generated proto files"
	@echo "    make check_tools      Verify all required tools are installed"
	@echo "    make install_tools    Install protoc-gen-go and protoc-gen-go-grpc"
	@echo ""

# ─────────────────────────────────────────────────────────────
# CHECK TOOLS
# ─────────────────────────────────────────────────────────────
.PHONY: check_tools
check_tools:
	@echo "→ Checking required tools..."
	@which protoc > /dev/null 2>&1 || \
		(echo "✗ protoc not found. Run: sudo apt install -y protobuf-compiler" && exit 1)
	@which protoc-gen-go > /dev/null 2>&1 || \
		(echo "✗ protoc-gen-go not found. Run: make install_tools" && exit 1)
	@which protoc-gen-go-grpc > /dev/null 2>&1 || \
		(echo "✗ protoc-gen-go-grpc not found. Run: make install_tools" && exit 1)
	@echo "✓ All tools found"
	@echo "  protoc          → $(shell protoc --version)"
	@echo "  protoc-gen-go   → $(shell protoc-gen-go --version)"
	@echo "  protoc-gen-grpc → $(shell protoc-gen-go-grpc --version)"

# ─────────────────────────────────────────────────────────────
# INSTALL TOOLS
# ─────────────────────────────────────────────────────────────
.PHONY: install_tools
install_tools:
	@echo "→ Installing protoc-gen-go..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@echo "→ Installing protoc-gen-go-grpc..."
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	@echo "✓ Tools installed. Make sure $(shell go env GOPATH)/bin is in your PATH"

# ─────────────────────────────────────────────────────────────
# GENERATE PROTO
# ─────────────────────────────────────────────────────────────
.PHONY: generate_proto
generate_proto: check_tools
	@echo "→ Creating output directory $(PROTO_GEN_DIR)..."
	@mkdir -p $(PROTO_GEN_DIR)
	@echo "→ Generating Go code from $(PROTO_FILE)..."
	$(PROTOC) \
		--go_out=$(PROTO_GEN_DIR) \
		--go_opt=paths=source_relative \
		--go-grpc_out=$(PROTO_GEN_DIR) \
		--go-grpc_opt=paths=source_relative \
		--proto_path=$(PROTO_DIR) \
		$(PROTO_FILE)
	@echo "✓ Proto generation complete"
	@echo ""
	@echo "  Generated files:"
	@find $(PROTO_GEN_DIR) -name "*.go" | sed 's/^/    /'
	@echo ""

# ─────────────────────────────────────────────────────────────
# CLEAN PROTO
# ─────────────────────────────────────────────────────────────
.PHONY: clean_proto
clean_proto:
	@echo "→ Removing generated proto files..."
	@rm -rf $(PROTO_GEN_DIR)
	@echo "✓ Cleaned $(PROTO_GEN_DIR)"
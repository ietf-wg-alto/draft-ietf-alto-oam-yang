# Makefile fragment for automatic commit message generation using Conventional Commits 1.0.0
# Include this in your main Makefile: include commit-prompt.mk

# --- Configuration ---
# Set your preferred AI agent tool: claude-code, gemini-cli, codex, qwen, kiro-cli, etc.
AGENT_TOOL ?= claude-code

# Set the command template for executing the prompt (default: direct execution)
# Use $(PROMPT) placeholder for the prompt text
AGENT_CMD_TEMPLATE ?= $(AGENT_TOOL) $(PROMPT)

# Commit prompt following Conventional Commits 1.0.0
PROMPT := "Analyze the currently staged changes in this git repository and generate a commit message following the Conventional Commits 1.0.0 specification (https://www.conventionalcommits.org/en/v1.0.0/). Examine the diff of all staged files and create a commit message with the proper format: <type>[optional scope]: <description>. Choose the most appropriate type from: feat, fix, docs, style, refactor, perf, test, build, ci, chore, or revert. Provide a concise description (under 50 characters) that clearly summarizes the changes. If the changes are significant enough, include a longer body paragraph describing the motivation and contrast with previous behavior. Then automatically commit the changes with the generated message."

# --- Auto-commit Target ---
.PHONY: auto-commit
auto-commit: ## Generate commit message using AI and commit staged changes
	@echo "Generating commit message with $(AGENT_TOOL)..."
	@$(call run-agent,$(AGENT_TOOL),$(AGENT_CMD_TEMPLATE))
	@echo "Commit completed."

# --- Pre-configured Tool Targets ---
.PHONY: auto-commit-claude auto-commit-gemini auto-commit-codex auto-commit-qwen auto-commit-kiro
auto-commit-claude: AGENT_TOOL=claude-code
auto-commit-claude: AGENT_CMD_TEMPLATE=claude-code $(PROMPT)
auto-commit-claude: ## Commit using Claude Code CLI
	$(call run-agent-claude)

auto-commit-gemini: AGENT_TOOL=gemini-cli
auto-commit-gemini: AGENT_CMD_TEMPLATE=gemini-cli $(PROMPT)
auto-commit-gemini: ## Commit using Gemini CLI
	$(call run-agent-gemini)

auto-commit-codex: AGENT_TOOL=codex
auto-commit-codex: AGENT_CMD_TEMPLATE=codex $(PROMPT)
auto-commit-codex: ## Commit using OpenAI Codex CLI
	$(call run-agent-codex)

auto-commit-qwen: AGENT_TOOL=qwen
auto-commit-qwen: AGENT_CMD_TEMPLATE=qwen -i $(PROMPT)
auto-commit-qwen: ## Commit using Qwen CLI
	$(call run-agent-qwen)

auto-commit-kiro: AGENT_TOOL=kiro-cli
auto-commit-kiro: AGENT_CMD_TEMPLATE=kiro-cli chat $(PROMPT)
auto-commit-kiro: ## Commit using Kiro CLI
	$(call run-agent-kiro)

# --- Helper Macros ---
define run-agent
	@echo "Running $(1) to generate commit message..."
	@$(2)
endef

define run-agent-claude
	@echo "Running Claude Code to generate commit message..."
	@claude-code $(PROMPT)
endef

define run-agent-gemini
	@echo "Running Gemini CLI to generate commit message..."
	@gemini-cli $(PROMPT)
endef

define run-agent-codex
	@echo "Running OpenAI Codex to generate commit message..."
	@codex $(PROMPT)
endef

define run-agent-qwen
	@echo "Running Qwen to generate commit message..."
	@qwen -i $(PROMPT)
endef

define run-agent-kiro
	@echo "Running Kiro CLI to generate commit message..."
	@kiro-cli chat $(PROMPT)
endef


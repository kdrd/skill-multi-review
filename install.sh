#!/bin/bash
set -e

# =============================================================================
# Multi-Review Skill Installer
# =============================================================================

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variable definitions
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_NAME="multi-review"
GLOBAL_SKILLS_DIR="$HOME/.claude/skills"
SKILL_SOURCE="$REPO_DIR/skills/$SKILL_NAME"
SKILL_TARGET="$GLOBAL_SKILLS_DIR/$SKILL_NAME"

# =============================================================================
# Functions
# =============================================================================

print_step() {
  echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
  echo -e "${RED}✗${NC}  $1"
}

print_success() {
  echo -e "${GREEN}✓${NC}  $1"
}

check_prerequisites() {
  print_step "Checking prerequisites..."

  # Claude Code (required)
  if ! command -v claude &> /dev/null; then
    print_error "Error: Claude Code is required but not installed."
    echo "    Please install Claude Code first: https://claude.ai/code"
    exit 1
  fi
  print_success "Claude Code found"

  # Codex CLI (recommended)
  if command -v codex &> /dev/null; then
    CODEX_VERSION=$(codex --version 2>/dev/null | head -1 || echo "unknown")
    print_success "Codex CLI found: $CODEX_VERSION"
  else
    print_warning "Codex CLI not found (optional)"
  fi

  # Gemini CLI (recommended)
  if command -v gemini &> /dev/null; then
    print_success "Gemini CLI found"
  else
    print_warning "Gemini CLI not found (optional)"
  fi

  echo ""
}

check_skill_source() {
  print_step "Checking skill source..."

  if [ ! -d "$SKILL_SOURCE" ]; then
    print_error "Skill source directory not found: $SKILL_SOURCE"
    exit 1
  fi

  if [ ! -f "$SKILL_SOURCE/SKILL.md" ]; then
    print_error "SKILL.md not found in: $SKILL_SOURCE"
    exit 1
  fi

  print_success "Skill source verified: $SKILL_SOURCE"
  echo ""
}

check_existing_installation() {
  print_step "Checking existing installation..."

  if [ -e "$SKILL_TARGET" ]; then
    if [ -L "$SKILL_TARGET" ]; then
      # It's a symlink
      print_warning "Skill symlink already exists: $SKILL_TARGET"
      read -p "Do you want to overwrite it? [y/N] " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
      fi
      rm "$SKILL_TARGET"
      print_success "Existing symlink removed"
    else
      # It's a real directory
      print_error "A directory already exists at: $SKILL_TARGET"
      echo "    Please remove it manually before installing."
      exit 1
    fi
  else
    print_success "No existing installation found"
  fi

  echo ""
}

install_skill() {
  print_step "Installing skill..."

  # Create global skills directory if it doesn't exist
  if [ ! -d "$GLOBAL_SKILLS_DIR" ]; then
    mkdir -p "$GLOBAL_SKILLS_DIR"
    print_success "Created directory: $GLOBAL_SKILLS_DIR"
  fi

  # Create symlink
  ln -s "$SKILL_SOURCE" "$SKILL_TARGET"
  print_success "Created symlink: $SKILL_TARGET -> $SKILL_SOURCE"

  echo ""
}

print_completion_message() {
  echo -e "${GREEN}=============================================================================${NC}"
  echo -e "${GREEN}Installation complete!${NC}"
  echo -e "${GREEN}=============================================================================${NC}"
  echo ""
  echo "Usage:"
  echo "  /multi-review [target] [request]"
  echo ""
  echo "Examples:"
  echo "  /multi-review src/ \"Review code quality\""
  echo "  /multi-review . \"Security audit\""
  echo ""
}

# =============================================================================
# Main
# =============================================================================

echo ""
echo "Multi-Review Skill Installer"
echo "============================"
echo ""

check_prerequisites
check_skill_source
check_existing_installation
install_skill
print_completion_message

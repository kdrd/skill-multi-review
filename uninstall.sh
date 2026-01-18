#!/bin/bash
set -e

# ==============================================================================
# Multi-Review Skill Uninstaller
# ==============================================================================

# Variables
SKILL_NAME="multi-review"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL_SKILLS_DIR="$HOME/.claude/skills"
SKILL_TARGET="$GLOBAL_SKILLS_DIR/$SKILL_NAME"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ==============================================================================
# Uninstallation Process
# ==============================================================================

echo "Uninstalling $SKILL_NAME skill..."
echo ""

# Check if skill exists
if [ ! -e "$SKILL_TARGET" ]; then
    echo -e "${YELLOW}Not installed:${NC} $SKILL_TARGET does not exist."
    echo "Nothing to uninstall."
    exit 0
fi

# Helper function for warnings
print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Check if it's a symbolic link or actual directory
if [ -L "$SKILL_TARGET" ]; then
    # It's a symbolic link - verify it points to our repository
    LINK_TARGET=$(readlink "$SKILL_TARGET")
    EXPECTED_TARGET="$REPO_DIR/skills/$SKILL_NAME"

    echo -e "Found symbolic link: ${GREEN}$SKILL_TARGET${NC}"
    echo ""

    # Verify symlink target
    if [ "$LINK_TARGET" != "$EXPECTED_TARGET" ]; then
        print_warning "Symlink points to unexpected location: $LINK_TARGET"
        print_warning "Expected: $EXPECTED_TARGET"
        read -p "Still remove? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Uninstallation cancelled."
            exit 0
        fi
    fi

    # Confirmation prompt
    read -p "Remove $SKILL_NAME skill? [y/N] " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$SKILL_TARGET"
        echo ""
        echo -e "${GREEN}Uninstallation complete!${NC}"
        echo "The $SKILL_NAME skill has been removed from Claude Code."
        exit 0
    else
        echo -e "${YELLOW}Uninstallation cancelled.${NC}"
        exit 0
    fi
else
    # It's an actual directory - do not remove
    echo -e "${RED}Warning:${NC} ~/.claude/skills/$SKILL_NAME is not a symbolic link."
    echo "This may have been manually installed. Remove manually if needed."
    exit 1
fi

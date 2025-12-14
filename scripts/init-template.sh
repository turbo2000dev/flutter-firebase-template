#!/bin/bash
#
# Flutter + Firebase Template Initialization Script
# =================================================
# This script replaces template placeholders with your project values.
#
# Usage:
#   ./scripts/init-template.sh
#
# The script will prompt for required values interactively.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Flutter + Firebase Template Initialization Script        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to prompt for value with default
prompt_value() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"

    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " value
        value="${value:-$default}"
    else
        read -p "$prompt: " value
    fi

    eval "$var_name='$value'"
}

# Gather project information
echo -e "${YELLOW}Please provide the following information:${NC}"
echo ""

# Try to detect project name from current directory
DETECTED_NAME=$(basename "$(pwd)" | tr '-' '_')

prompt_value "Project name (snake_case)" "$DETECTED_NAME" "PROJECT_NAME"
PROJECT_NAME_UPPER=$(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]')

prompt_value "Project display name" "" "PROJECT_DISPLAY_NAME"
prompt_value "Project description (brief)" "" "PROJECT_DESCRIPTION"
prompt_value "Project state" "Early development" "PROJECT_STATE"
prompt_value "Target market/audience" "" "TARGET_MARKET"
prompt_value "Target region (optional)" "" "TARGET_REGION"

echo ""
echo -e "${YELLOW}Firebase Configuration:${NC}"
prompt_value "Firebase project ID" "" "FIREBASE_PROJECT_ID"
FIREBASE_STORAGE_BUCKET="${FIREBASE_PROJECT_ID}.appspot.com"
prompt_value "Firebase storage bucket" "$FIREBASE_STORAGE_BUCKET" "FIREBASE_STORAGE_BUCKET"

echo ""
echo -e "${YELLOW}Domain Configuration:${NC}"
prompt_value "Production domain" "${PROJECT_NAME//_/-}.app" "PROD_DOMAIN"
prompt_value "Development domain" "dev.${PROD_DOMAIN}" "DEV_DOMAIN"
prompt_value "Staging domain" "staging.${PROD_DOMAIN}" "STAGING_DOMAIN"

# Default URLs based on Firebase project ID
DEV_URL_DEFAULT="${FIREBASE_PROJECT_ID}-dev.web.app"
STAGING_URL_DEFAULT="${FIREBASE_PROJECT_ID}-staging.web.app"
PROD_URL_DEFAULT="${FIREBASE_PROJECT_ID}.web.app"

prompt_value "Development URL" "$DEV_URL_DEFAULT" "DEV_URL"
prompt_value "Staging URL" "$STAGING_URL_DEFAULT" "STAGING_URL"
prompt_value "Production URL" "$PROD_URL_DEFAULT" "PROD_URL"

echo ""
echo -e "${YELLOW}GitHub Configuration:${NC}"
prompt_value "GitHub username/organization" "" "GITHUB_USERNAME"

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Configuration Summary:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Project Name:       ${GREEN}$PROJECT_NAME${NC}"
echo -e "  Display Name:       ${GREEN}$PROJECT_DISPLAY_NAME${NC}"
echo -e "  Description:        ${GREEN}$PROJECT_DESCRIPTION${NC}"
echo -e "  Target Market:      ${GREEN}$TARGET_MARKET${NC}"
echo -e "  Firebase Project:   ${GREEN}$FIREBASE_PROJECT_ID${NC}"
echo -e "  Production Domain:  ${GREEN}$PROD_DOMAIN${NC}"
echo -e "  GitHub User:        ${GREEN}$GITHUB_USERNAME${NC}"
echo ""

read -p "Proceed with these values? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${RED}Initialization cancelled.${NC}"
    exit 1
fi

# Replace placeholders in files
echo ""
echo -e "${YELLOW}Replacing placeholders in files...${NC}"

# Find all files with placeholders (excluding binary files and node_modules)
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.sh" -o -name "*.py" -o -name "*.template" \) \
    -not -path "./node_modules/*" \
    -not -path "./.git/*" \
    -not -path "./build/*" \
    -not -path "./landing-page/node_modules/*" \
    -print0 | while IFS= read -r -d '' file; do

    if grep -q '{{' "$file" 2>/dev/null; then
        echo "  Processing: $file"

        # Create temp file for sed operations
        sed -i.bak \
            -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
            -e "s|{{PROJECT_NAME_UPPER}}|$PROJECT_NAME_UPPER|g" \
            -e "s|{{PROJECT_DISPLAY_NAME}}|$PROJECT_DISPLAY_NAME|g" \
            -e "s|{{PROJECT_DESCRIPTION}}|$PROJECT_DESCRIPTION|g" \
            -e "s|{{PROJECT_STATE}}|$PROJECT_STATE|g" \
            -e "s|{{TARGET_MARKET}}|$TARGET_MARKET|g" \
            -e "s|{{TARGET_REGION}}|$TARGET_REGION|g" \
            -e "s|{{FIREBASE_PROJECT_ID}}|$FIREBASE_PROJECT_ID|g" \
            -e "s|{{FIREBASE_STORAGE_BUCKET}}|$FIREBASE_STORAGE_BUCKET|g" \
            -e "s|{{PROD_DOMAIN}}|$PROD_DOMAIN|g" \
            -e "s|{{DEV_DOMAIN}}|$DEV_DOMAIN|g" \
            -e "s|{{STAGING_DOMAIN}}|$STAGING_DOMAIN|g" \
            -e "s|{{DEV_URL}}|$DEV_URL|g" \
            -e "s|{{STAGING_URL}}|$STAGING_URL|g" \
            -e "s|{{PROD_URL}}|$PROD_URL|g" \
            -e "s|{{GITHUB_USERNAME}}|$GITHUB_USERNAME|g" \
            -e "s|{{project_type}}|${PROJECT_NAME//_/ }|g" \
            -e "s|{{PROJECT_TYPE}}|${PROJECT_DISPLAY_NAME}|g" \
            "$file"

        # Remove backup files
        rm -f "${file}.bak"
    fi
done

# Rename template files
echo ""
echo -e "${YELLOW}Renaming template files...${NC}"

if [ -f "CLAUDE.md.template" ]; then
    mv CLAUDE.md.template CLAUDE.md
    echo "  Renamed: CLAUDE.md.template → CLAUDE.md"
fi

if [ -f "firebase.json.template" ]; then
    mv firebase.json.template firebase.json
    echo "  Renamed: firebase.json.template → firebase.json"
fi

if [ -f ".firebaserc.template" ]; then
    mv .firebaserc.template .firebaserc
    echo "  Renamed: .firebaserc.template → .firebaserc"
fi

if [ -f ".claude/settings.local.json.example" ]; then
    cp .claude/settings.local.json.example .claude/settings.local.json
    echo "  Created: .claude/settings.local.json"
fi

# Make scripts executable
echo ""
echo -e "${YELLOW}Making scripts executable...${NC}"
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x .githooks/* 2>/dev/null || true

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Template Initialization Complete!               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Next steps:"
echo ""
echo -e "  1. ${BLUE}Set up Git hooks:${NC}"
echo -e "     ./scripts/setup-git-hooks.sh"
echo ""
echo -e "  2. ${BLUE}Set up Firebase:${NC}"
echo -e "     firebase login"
echo -e "     firebase use --add"
echo -e "     ./scripts/setup-hosting-targets.sh"
echo ""
echo -e "  3. ${BLUE}Configure GitHub Secrets:${NC}"
echo -e "     See docs/ci-cd/secrets-setup.md"
echo ""
echo -e "  4. ${BLUE}Start development:${NC}"
echo -e "     flutter pub get"
echo -e "     # In Claude Code:"
echo -e "     /init"
echo -e "     /plan-from-requirements <your requirements>"
echo ""
echo -e "${GREEN}Happy coding!${NC}"

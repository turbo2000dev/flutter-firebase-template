#!/bin/bash
#
# Setup Firebase Hosting Targets
# Creates hosting sites for dev/staging/prod environments
#
# Prerequisites:
# - Firebase CLI installed and authenticated
# - Access to the Firebase project
#
# Usage: ./scripts/setup-hosting-targets.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ID="{{FIREBASE_PROJECT_ID}}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setting up Firebase Hosting Targets${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${YELLOW}This script will create hosting sites for:${NC}"
echo "  - retirement-dev (development)"
echo "  - retirement-app-staging (staging)"
echo "  - {{FIREBASE_PROJECT_ID}} (production - already exists)"

echo -e "\n${YELLOW}Note: You need Firebase project owner permissions.${NC}"
read -p "Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Setup cancelled"
    exit 0
fi

# Create dev site
echo -e "\n${YELLOW}Creating development hosting site...${NC}"
firebase hosting:sites:create retirement-dev --project $PROJECT_ID 2>/dev/null || \
    echo "Site 'retirement-dev' may already exist, continuing..."

# Create staging site
echo -e "\n${YELLOW}Creating staging hosting site...${NC}"
firebase hosting:sites:create retirement-app-staging --project $PROJECT_ID 2>/dev/null || \
    echo "Site 'retirement-app-staging' may already exist, continuing..."

# Apply targets
echo -e "\n${YELLOW}Applying hosting targets...${NC}"
firebase target:apply hosting dev retirement-dev --project $PROJECT_ID
firebase target:apply hosting staging retirement-app-staging --project $PROJECT_ID
firebase target:apply hosting prod {{FIREBASE_PROJECT_ID}} --project $PROJECT_ID

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nHosting targets configured:"
echo -e "  dev     → ${YELLOW}https://retirement-dev.web.app${NC}"
echo -e "  staging → ${YELLOW}https://retirement-app-staging.web.app${NC}"
echo -e "  prod    → ${YELLOW}https://{{FIREBASE_PROJECT_ID}}.web.app${NC}"
echo -e "\nYou can now deploy with:"
echo -e "  ${BLUE}./scripts/deploy.sh dev${NC}"
echo -e "  ${BLUE}./scripts/deploy.sh staging${NC}"
echo -e "  ${BLUE}./scripts/deploy.sh prod${NC}"

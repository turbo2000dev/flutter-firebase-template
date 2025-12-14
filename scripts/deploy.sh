#!/bin/bash
#
# Deployment Script
# Builds and deploys all components to a Firebase Hosting environment
#
# Usage: ./scripts/deploy.sh <environment> [options]
#   environment: dev, staging, or prod (required)
#   options:
#     --skip-build      Skip building, deploy existing public/ directory
#     --functions       Also deploy Cloud Functions
#     --rules           Also deploy Firestore rules
#     --wizard-images   Also upload wizard images to Firebase Storage
#     --all             Deploy everything (hosting + functions + rules + wizard-images)
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
ENVIRONMENT=""
SKIP_BUILD=false
DEPLOY_FUNCTIONS=false
DEPLOY_RULES=false
DEPLOY_WIZARD_IMAGES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|prod)
            ENVIRONMENT="$1"
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --functions)
            DEPLOY_FUNCTIONS=true
            shift
            ;;
        --rules)
            DEPLOY_RULES=true
            shift
            ;;
        --wizard-images)
            DEPLOY_WIZARD_IMAGES=true
            shift
            ;;
        --all)
            DEPLOY_FUNCTIONS=true
            DEPLOY_RULES=true
            DEPLOY_WIZARD_IMAGES=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Validate environment
if [ -z "$ENVIRONMENT" ]; then
    echo -e "${RED}Error: Environment is required${NC}"
    echo "Usage: ./scripts/deploy.sh <dev|staging|prod> [--skip-build] [--functions] [--rules] [--wizard-images] [--all]"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Error: Invalid environment '$ENVIRONMENT'${NC}"
    echo "Valid environments: dev, staging, prod"
    exit 1
fi

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying to: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "${BLUE}========================================${NC}"

# Production deployment confirmation
if [ "$ENVIRONMENT" = "prod" ]; then
    echo -e "\n${RED}⚠️  WARNING: You are about to deploy to PRODUCTION${NC}"
    echo -e "This will affect live users.\n"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Deployment cancelled${NC}"
        exit 0
    fi
    echo ""
fi

# Run quality checks for production
if [ "$ENVIRONMENT" = "prod" ] && [ "$SKIP_BUILD" = false ]; then
    echo -e "${YELLOW}Running quality checks for production deployment...${NC}"

    echo "Running flutter analyze..."
    flutter analyze

    echo "Running tests..."
    flutter test

    echo -e "${GREEN}Quality checks passed${NC}\n"
fi

# Build if not skipped
if [ "$SKIP_BUILD" = false ]; then
    echo -e "${YELLOW}Building all components...${NC}"
    "$SCRIPT_DIR/build-all.sh" "$ENVIRONMENT"
else
    echo -e "${YELLOW}Skipping build (using existing public/ directory)${NC}"
    if [ ! -d "public" ]; then
        echo -e "${RED}Error: public/ directory does not exist. Run without --skip-build${NC}"
        exit 1
    fi
fi

# Map environment to Firebase hosting target
case $ENVIRONMENT in
    dev)
        HOSTING_TARGET="dev"
        ;;
    staging)
        HOSTING_TARGET="staging"
        ;;
    prod)
        HOSTING_TARGET="prod"
        ;;
esac

# Deploy hosting
echo -e "\n${YELLOW}Deploying to Firebase Hosting (target: $HOSTING_TARGET)...${NC}"
firebase deploy --only hosting:$HOSTING_TARGET

# Deploy functions if requested
if [ "$DEPLOY_FUNCTIONS" = true ]; then
    echo -e "\n${YELLOW}Deploying Cloud Functions...${NC}"
    firebase deploy --only functions
fi

# Deploy Firestore rules if requested
if [ "$DEPLOY_RULES" = true ]; then
    echo -e "\n${YELLOW}Deploying Firestore rules...${NC}"
    firebase deploy --only firestore:rules
fi

# Deploy wizard images if requested
if [ "$DEPLOY_WIZARD_IMAGES" = true ]; then
    echo -e "\n${YELLOW}Uploading wizard images to Firebase Storage...${NC}"
    if [ -f "$SCRIPT_DIR/upload-wizard-images.sh" ]; then
        "$SCRIPT_DIR/upload-wizard-images.sh"
    else
        echo -e "${RED}Error: upload-wizard-images.sh not found${NC}"
        exit 1
    fi
fi

# Get the deployed URL
case $ENVIRONMENT in
    dev)
        URL="https://retirement-dev.web.app"
        ;;
    staging)
        URL="https://retirement-app-staging.web.app"
        ;;
    prod)
        URL="https://{{FIREBASE_PROJECT_ID}}.web.app"
        ;;
esac

# Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}Deployment successful!${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Landing Page: ${YELLOW}$URL${NC}"
echo -e "Flutter App: ${YELLOW}$URL/app${NC}"

if [ "$DEPLOY_FUNCTIONS" = true ]; then
    echo -e "Functions: ${GREEN}deployed${NC}"
fi

if [ "$DEPLOY_RULES" = true ]; then
    echo -e "Firestore Rules: ${GREEN}deployed${NC}"
fi

if [ "$DEPLOY_WIZARD_IMAGES" = true ]; then
    echo -e "Wizard Images: ${GREEN}uploaded${NC}"
fi

echo -e "\n${YELLOW}Post-deployment checklist:${NC}"
echo "  [ ] Verify landing page loads correctly"
echo "  [ ] Verify /app loads Flutter application"
echo "  [ ] Test authentication flow"
echo "  [ ] Check for console errors"

if [ "$ENVIRONMENT" = "prod" ]; then
    echo -e "\n${YELLOW}Production monitoring:${NC}"
    echo "  - Firebase Console: https://console.firebase.google.com"
    echo "  - Check Crashlytics for new errors"
    echo "  - Monitor analytics for anomalies"
fi

#!/bin/bash
#
# Build All Components Script
# Builds Astro landing page and Flutter web app for deployment
#
# Usage: ./scripts/build-all.sh [environment]
#   environment: dev (default), staging, or prod
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default environment
ENVIRONMENT=${1:-dev}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Error: Invalid environment '$ENVIRONMENT'${NC}"
    echo "Usage: ./scripts/build-all.sh [dev|staging|prod]"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Building for environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "${BLUE}========================================${NC}"

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Clean public directory
echo -e "\n${YELLOW}Cleaning public directory...${NC}"
rm -rf public
mkdir -p public

# Build Astro landing page (if it exists)
LANDING_PAGE_DIR="$PROJECT_ROOT/landing-page"
if [ -d "$LANDING_PAGE_DIR" ]; then
    echo -e "\n${YELLOW}Building Astro landing page...${NC}"
    cd "$LANDING_PAGE_DIR"

    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "Installing npm dependencies..."
        npm install
    fi

    # Build
    npm run build

    # Copy to public
    echo "Copying landing page to public/"
    cp -r dist/* "$PROJECT_ROOT/public/"

    cd "$PROJECT_ROOT"
    echo -e "${GREEN}Landing page built successfully${NC}"
else
    echo -e "${YELLOW}No landing-page directory found, creating placeholder...${NC}"
    # Create a simple placeholder landing page
    cat > "$PROJECT_ROOT/public/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Retirement Planning App</title>
    <style>
        body { font-family: system-ui, sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; background: #f5f5f5; }
        .container { text-align: center; padding: 2rem; }
        h1 { color: #1976D2; }
        .cta { display: inline-block; margin-top: 1rem; padding: 1rem 2rem; background: #1976D2; color: white; text-decoration: none; border-radius: 8px; }
        .cta:hover { background: #1565C0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Retirement Planning App</h1>
        <p>Plan your financial future with confidence</p>
        <a href="/app" class="cta">Open App</a>
    </div>
</body>
</html>
EOF
fi

# Build Flutter web app
echo -e "\n${YELLOW}Building Flutter web app...${NC}"

# Set build flags based on environment
FLUTTER_BUILD_FLAGS="--dart-define=ENVIRONMENT=$ENVIRONMENT"

if [ "$ENVIRONMENT" = "prod" ]; then
    FLUTTER_BUILD_FLAGS="$FLUTTER_BUILD_FLAGS --release"
    echo "Building in RELEASE mode for production"
else
    echo "Building in DEBUG mode for $ENVIRONMENT"
fi

# Important: --base-href /app/ ensures assets load correctly from subdirectory
flutter build web $FLUTTER_BUILD_FLAGS --base-href /app/

# Copy Flutter build to public/app
echo "Copying Flutter app to public/app/"
mkdir -p "$PROJECT_ROOT/public/app"
cp -r build/web/* "$PROJECT_ROOT/public/app/"

echo -e "${GREEN}Flutter app built successfully${NC}"

# Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Output directory: ${YELLOW}public/${NC}"
echo -e "\nStructure:"
echo "  public/"
echo "  ├── index.html        (Landing page)"
echo "  ├── ...               (Landing page assets)"
echo "  └── app/"
echo "      ├── index.html    (Flutter app)"
echo "      └── ...           (Flutter assets)"
echo -e "\nNext step: ${YELLOW}./scripts/deploy.sh $ENVIRONMENT${NC}"

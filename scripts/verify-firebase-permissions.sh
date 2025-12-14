#!/bin/bash
# Verify Firebase Service Account Permissions for CI/CD
# This script checks if your service account has the correct roles for GitHub Actions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_ID="retirement-app-a734e"
REQUIRED_ROLES=(
    "roles/firebase.admin"
    "roles/cloudfunctions.admin"
    "roles/iam.serviceAccountUser"
)

# Functions
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "ℹ️  $1"
}

# Check if gcloud is installed
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK (gcloud) is not installed"
        echo ""
        echo "Install it from: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    print_success "Google Cloud SDK installed"
}

# Check if authenticated
check_auth() {
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        print_error "Not authenticated with gcloud"
        echo ""
        echo "Run: gcloud auth login"
        exit 1
    fi

    local account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
    print_success "Authenticated as: $account"
}

# Set project
set_project() {
    print_info "Setting project to: $PROJECT_ID"
    if gcloud config set project "$PROJECT_ID" &> /dev/null; then
        print_success "Project set successfully"
    else
        print_error "Failed to set project"
        echo ""
        echo "Verify you have access to project: $PROJECT_ID"
        exit 1
    fi
}

# List service accounts
list_service_accounts() {
    print_info "Fetching service accounts..."
    echo ""

    local accounts=$(gcloud iam service-accounts list --format="table(email, displayName)" 2>/dev/null)

    if [ -z "$accounts" ]; then
        print_error "No service accounts found or insufficient permissions"
        exit 1
    fi

    echo "$accounts"
    echo ""
}

# Prompt user to select service account
select_service_account() {
    echo "Enter the email of the service account to verify"
    echo "(e.g., github-actions@retirement-app-a734e.iam.gserviceaccount.com):"
    read -r SERVICE_ACCOUNT_EMAIL

    if [ -z "$SERVICE_ACCOUNT_EMAIL" ]; then
        print_error "No service account email provided"
        exit 1
    fi

    # Verify service account exists
    if ! gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" &> /dev/null; then
        print_error "Service account not found: $SERVICE_ACCOUNT_EMAIL"
        exit 1
    fi

    print_success "Service account found: $SERVICE_ACCOUNT_EMAIL"
    echo ""
}

# Check service account roles
check_roles() {
    print_info "Checking IAM roles for service account..."
    echo ""

    # Get project IAM policy
    local policy=$(gcloud projects get-iam-policy "$PROJECT_ID" \
        --flatten="bindings[].members" \
        --filter="bindings.members:serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --format="value(bindings.role)" 2>/dev/null)

    if [ -z "$policy" ]; then
        print_warning "No roles found for this service account at project level"
        echo ""
    fi

    local all_roles_present=true

    # Check each required role
    for role in "${REQUIRED_ROLES[@]}"; do
        local role_name="${role#roles/}"
        role_name="${role_name//./ }"
        role_name="$(echo "$role_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')"

        if echo "$policy" | grep -q "$role"; then
            print_success "$role_name ($role)"
        else
            print_error "$role_name ($role) - MISSING"
            all_roles_present=false
        fi
    done

    echo ""

    if [ "$all_roles_present" = true ]; then
        print_success "All required roles are present!"
        return 0
    else
        print_error "Some required roles are missing!"
        return 1
    fi
}

# Show how to add missing roles
show_add_roles_instructions() {
    echo ""
    print_header "How to Add Missing Roles"

    echo "Option 1: Using Google Cloud Console (Recommended for beginners)"
    echo "1. Go to: https://console.cloud.google.com/iam-admin/iam?project=$PROJECT_ID"
    echo "2. Find the principal: $SERVICE_ACCOUNT_EMAIL"
    echo "3. Click the pencil icon (Edit principal)"
    echo "4. Click 'ADD ANOTHER ROLE' and add missing roles"
    echo "5. Click 'SAVE'"
    echo ""

    echo "Option 2: Using gcloud CLI (For advanced users)"
    for role in "${REQUIRED_ROLES[@]}"; do
        echo "gcloud projects add-iam-policy-binding $PROJECT_ID \\"
        echo "    --member=\"serviceAccount:$SERVICE_ACCOUNT_EMAIL\" \\"
        echo "    --role=\"$role\""
        echo ""
    done
}

# Check if JSON key exists locally (optional)
check_json_key() {
    echo ""
    print_info "Do you have the JSON key file for this service account? (y/n)"
    read -r has_key

    if [ "$has_key" = "y" ] || [ "$has_key" = "Y" ]; then
        echo "Enter the path to the JSON key file:"
        read -r key_path

        if [ -f "$key_path" ]; then
            # Validate JSON
            if jq empty "$key_path" 2>/dev/null; then
                print_success "JSON key file is valid"

                # Check required fields
                local required_fields=("type" "project_id" "private_key_id" "private_key" "client_email")
                local all_fields_present=true

                for field in "${required_fields[@]}"; do
                    if ! jq -e ".$field" "$key_path" &> /dev/null; then
                        print_error "Missing required field: $field"
                        all_fields_present=false
                    fi
                done

                if [ "$all_fields_present" = true ]; then
                    print_success "All required fields present in JSON key"
                fi
            else
                print_error "Invalid JSON format in key file"
            fi
        else
            print_error "File not found: $key_path"
        fi
    fi
}

# GitHub secret instructions
show_github_instructions() {
    echo ""
    print_header "Next Steps: Add to GitHub Secrets"

    echo "1. Copy the content of your JSON key file"
    echo "2. Go to: https://github.com/[YOUR_USERNAME]/retirement_app/settings/secrets/actions"
    echo "3. Create or update secret: FIREBASE_SERVICE_ACCOUNT_RETIREMENT_APP"
    echo "4. Paste the JSON content as the secret value"
    echo "5. Test by pushing a commit to main branch"
    echo ""

    print_info "See detailed guide: docs/ci-cd/verify-service-account.md"
}

# Main execution
main() {
    print_header "Firebase Service Account Verification"

    # Step 1: Check prerequisites
    print_info "Step 1: Checking prerequisites..."
    echo ""
    check_gcloud
    check_auth
    echo ""

    # Step 2: Set project
    print_info "Step 2: Setting up project..."
    echo ""
    set_project
    echo ""

    # Step 3: List service accounts
    print_info "Step 3: Available service accounts..."
    echo ""
    list_service_accounts

    # Step 4: Select service account
    print_info "Step 4: Select service account to verify..."
    echo ""
    select_service_account

    # Step 5: Check roles
    print_info "Step 5: Verifying IAM roles..."
    echo ""
    if ! check_roles; then
        show_add_roles_instructions
        exit 1
    fi

    # Step 6: Check JSON key (optional)
    check_json_key

    # Step 7: Show GitHub instructions
    show_github_instructions

    # Success
    echo ""
    print_header "✅ Verification Complete!"
    print_success "Service account is properly configured for CI/CD"
}

# Run main
main

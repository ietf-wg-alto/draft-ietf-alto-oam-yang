#!/bin/bash
#
# YANG Validator using YANG Catalog REST API
#
# This script validates YANG modules from a local draft text file using the
# YANG Catalog validator API. It uploads the draft, extracts YANG modules
# using xym, and validates them using multiple validators (pyang, confdc,
# yanglint, yangdump-pro).
#
# Usage:
#   ./tools/yang-validator-api.sh [options] <draft-txt-file>
#
# Options:
#   -d, --debug    Show debug output (raw requests and responses)
#   -h, --help     Show this help message
#
# Example:
#   ./tools/yang-validator-api.sh draft-ietf-alto-oam-yang.txt
#   ./tools/yang-validator-api.sh --debug draft-ietf-alto-oam-yang.txt
#

set -e

YANG_CATALOG_API="https://www.yangcatalog.org/yangvalidator/v2"

# Debug mode flag
DEBUG=false

# Colors for output - disable if not a TTY (e.g., when redirected to file)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Function to print debug output (to stderr to avoid interfering with return values)
debug_echo() {
    if [ "$DEBUG" = true ]; then
        echo -e "${YELLOW}[DEBUG]${NC} $1" >&2
    fi
}

# Function to print colored output
print_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
}

print_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
}

print_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
}

# Function to set up upload cache
setup_upload() {
    echo "Step 1: Setting up upload cache..." >&2
    local response

    # Try with HTTP/1.1 first (some servers have issues with HTTP/2)
    debug_echo "POST ${YANG_CATALOG_API}/upload-files-setup"
    debug_echo "Body: {\"latest\": true}"

    response=$(curl -sL --http1.1 -X POST "${YANG_CATALOG_API}/upload-files-setup" \
        -H "Content-Type: application/json" \
        -d '{"latest": true}')

    debug_echo "Response: $response"

    # Check if response contains an error (starts with HTML error page)
    if echo "$response" | head -1 | grep -q "<!doctype"; then
        echo "Warning: API returned an error page" >&2
        echo "Response: $response" | head -10 >&2
        echo "" >&2
        echo "The YANG Catalog API may be temporarily unavailable." >&2
        echo "Please try again later or use local validation with pyang." >&2
        return 1
    fi

    # Extract cache from JSON response: {"output": {"cache": "..."}}
    local cache
    cache=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['output']['cache'])" 2>/dev/null || \
            echo "$response" | sed -n 's/.*"cache":[[:space:]]*"\([^"]*\)".*/\1/p')

    if [ -z "$cache" ]; then
        echo "Failed to extract cache from response" >&2
        echo "Response: $response" >&2
        return 1
    fi

    echo "  Cache: $cache" >&2
    echo "" >&2

    # Only output the cache value to stdout
    echo "$cache"
}

# Function to upload and validate the draft file
validate_draft_file() {
    local cache="$1"
    local draft_file="$2"

    echo "Step 2: Uploading and validating draft file: $draft_file" >&2
    echo "" >&2

    local response

    # Upload the draft file as multipart form data
    debug_echo "POST ${YANG_CATALOG_API}/draft-validator/${cache}"
    debug_echo "File: ${draft_file}"

    response=$(curl -sL --http1.1 -X POST "${YANG_CATALOG_API}/draft-validator/${cache}" \
        -F "data=@${draft_file};type=text/plain")

    debug_echo "Response: $response"

    # Check if response contains an error (starts with HTML error page)
    if echo "$response" | head -1 | grep -q "<!doctype"; then
        echo "Error: API returned an error page" >&2
        echo "Response: $response" | head -10 >&2
        echo "" >&2
        echo "The YANG Catalog API may be temporarily unavailable." >&2
        echo "Please try again later." >&2
        exit 1
    fi

    echo "$response"
}

# Function to parse and display results
parse_results() {
    local response="$1"
    local draft_file="$2"

    echo ""
    echo "============================================================"
    echo "VALIDATION RESULTS"
    echo "============================================================"
    echo "  Draft file: $draft_file"
    echo ""

    # Use python3 to parse JSON if available, otherwise use grep/sed fallback
    if command -v python3 &> /dev/null; then
        parse_results_python "$response"
    else
        parse_results_grep "$response"
    fi
}

# Parse results using Python (more reliable)
parse_results_python() {
    local response="$1"

    local total_modules=0
    local passed_modules=0
    local failed_modules=0
    local warning_count=0

    # Parse the JSON response
    local modules
    modules=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    output = data.get('output', {})
    # Get all keys that look like YANG modules (contain @ and end with .yang)
    for key in output.keys():
        if '@' in key and key.endswith('.yang'):
            print(key)
except Exception as e:
    sys.exit(1)
" 2>/dev/null) || true

    if [ -z "$modules" ]; then
        # Check if there was an error in the response
        local error_msg
        error_msg=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    error = data.get('Error', '')
    if error:
        print(error)
except:
    pass
" 2>/dev/null) || true

        if [ -n "$error_msg" ]; then
            print_fail "Failed to validate draft"
            echo "  Error: $error_msg"
        elif [ "$response" = "[]" ]; then
            print_warn "No YANG modules found in draft"
            echo "  The draft does not contain embedded YANG modules."
            echo "  Make sure YANG modules are included with xym tags:"
            echo "    @<CODE BEGINS>..."
            echo "    @<CODE ENDS>"
            echo ""
            echo "  To validate YANG files directly, use pyang or yanglint locally."
        else
            print_warn "No YANG modules found in draft"
            echo "  The draft may not contain any YANG modules."
        fi
        return 1
    fi

    for module in $modules; do
        total_modules=$((total_modules + 1))

        # Check if module passed validation by examining pyang code
        local pyang_code
        pyang_code=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    output = data.get('output', {})
    module_data = output.get('$module', {})
    pyang = module_data.get('pyang', {})
    print(pyang.get('code', 1))
except:
    print(1)
" 2>/dev/null) || pyang_code=1

        if [ "$pyang_code" = "0" ]; then
            print_pass "$module"
            passed_modules=$((passed_modules + 1))

            # Check for warnings
            local stderr
            stderr=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    output = data.get('output', {})
    module_data = output.get('$module', {})
    pyang = module_data.get('pyang', {})
    print(pyang.get('stderr', ''))
except:
    pass
" 2>/dev/null) || true

            if echo "$stderr" | grep -qi "warning:"; then
                warning_count=$((warning_count + 1))
            fi
        else
            print_fail "$module"

            # Show errors from pyang stderr
            local errors
            errors=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    output = data.get('output', {})
    module_data = output.get('$module', {})
    pyang = module_data.get('pyang', {})
    stderr = pyang.get('stderr', '')
    # Print first few error lines
    lines = [l.strip() for l in stderr.split('\n') if 'error:' in l.lower()][:3]
    for line in lines:
        print(line)
except:
    pass
" 2>/dev/null) || true

            if [ -n "$errors" ]; then
                echo "$errors" | while read -r error; do
                    if [ -n "$error" ]; then
                        echo "    $error"
                    fi
                done
            fi
            failed_modules=$((failed_modules + 1))
        fi
    done

    echo ""
    echo "------------------------------------------------------------"
    echo "Summary:"
    echo "  Total modules: $total_modules"
    echo "  Passed: $passed_modules"
    echo "  Failed: $failed_modules"
    if [ "$warning_count" -gt 0 ]; then
        echo "  Warnings: $warning_count"
    fi
    echo "------------------------------------------------------------"

    if [ "$failed_modules" -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# Fallback parse results using grep/sed (less reliable)
parse_results_grep() {
    local response="$1"

    # Extract module names (pattern: "module-name@revision.yang": {)
    local modules
    modules=$(echo "$response" | grep -oE '"[a-zA-Z0-9@-]+\.yang"[[:space:]]*:[[:space:]]*\{' | \
              sed 's/"[[:space:]]*:.*//' | sed 's/"//g' | sort -u || true)

    if [ -z "$modules" ]; then
        # Try alternative pattern
        modules=$(echo "$response" | grep -oE '"[a-zA-Z0-9@-]+@[0-9]{4}-[0-9]{2}-[0-9]{2}\.yang"' | \
                  sed 's/"//g' || true)
    fi

    local total_modules=0
    local passed_modules=0
    local failed_modules=0

    for module in $modules; do
        total_modules=$((total_modules + 1))

        # Extract the section for this module
        local module_section
        module_section=$(echo "$response" | sed -n "/\"${module}\":/,/^[[:space:]]*\},?$/p" | head -30 || true)

        # Check for pyang code: "code": 0 means success, 1 means error
        local pyang_code
        pyang_code=$(echo "$module_section" | grep -o '"code":[[:space:]]*[01]' | head -1 | grep -o '[01]' || echo "1")

        if [ "$pyang_code" = "0" ]; then
            print_pass "$module"
            passed_modules=$((passed_modules + 1))
        else
            print_fail "$module"

            # Show first error from stderr
            local first_error
            first_error=$(echo "$module_section" | grep -A2 '"stderr"' | grep "error:" | head -1 | sed 's/^[[:space:]]*//' || true)
            if [ -n "$first_error" ]; then
                echo "    $first_error"
            fi
            failed_modules=$((failed_modules + 1))
        fi
    done

    echo ""
    echo "------------------------------------------------------------"
    echo "Summary:"
    echo "  Total modules: $total_modules"
    echo "  Passed: $passed_modules"
    echo "  Failed: $failed_modules"
    echo "------------------------------------------------------------"

    if [ "$failed_modules" -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--debug)
                DEBUG=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [options] <draft-txt-file>"
                echo ""
                echo "Options:"
                echo "  -d, --debug    Show debug output (raw requests and responses)"
                echo "  -h, --help     Show this help message"
                echo ""
                echo "Example:"
                echo "  $0 draft-ietf-alto-oam-yang.txt"
                echo "  $0 --debug draft-ietf-alto-oam-yang.txt"
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done

    if [ $# -lt 1 ]; then
        echo "Usage: $0 [options] <draft-txt-file>"
        echo ""
        echo "Options:"
        echo "  -d, --debug    Show debug output (raw requests and responses)"
        echo "  -h, --help     Show this help message"
        echo ""
        echo "Example:"
        echo "  $0 draft-ietf-alto-oam-yang.txt"
        echo "  $0 --debug draft-ietf-alto-oam-yang.txt"
        exit 1
    fi

    local draft_file="$1"

    echo "============================================================"
    echo "YANG Validator using YANG Catalog API"
    echo "============================================================"
    echo ""

    # Verify file exists
    if [ ! -f "$draft_file" ]; then
        echo "Error: File not found: $draft_file"
        exit 1
    fi

    # Verify file extension
    if [[ ! "$draft_file" =~ \.txt$ ]]; then
        echo "Warning: File should have .txt extension"
        echo "  Provided: $draft_file"
        echo ""
    fi

    # Step 1: Set up upload cache
    local cache
    if ! cache=$(setup_upload); then
        echo ""
        echo -e "${YELLOW}⚠️  YANG Catalog API is unavailable.${NC}"
        echo ""
        echo "Alternative validation options:"
        echo "  1. Use pyang locally: pyang -W error -p <path> <file.yang>"
        echo "  2. Use yanglint: yanglint -i -p <path> <file.yang>"
        echo "  3. Try again later when the API is available"
        exit 1
    fi

    # Step 2: Upload and validate the draft file
    local response
    response=$(validate_draft_file "$cache" "$draft_file")

    # Step 3: Parse and display results
    if parse_results "$response" "$draft_file"; then
        echo ""
        echo -e "${GREEN}✅ All YANG modules passed validation!${NC}"
        exit 0
    else
        echo ""
        echo -e "${RED}❌ Some YANG modules have validation errors.${NC}"
        exit 1
    fi
}

main "$@"
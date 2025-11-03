#!/bin/bash
# Build all packages in the repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

print_info "Starting build process for all packages"
print_info "Root directory: $ROOT_DIR"

# Find all package directories (those containing CONTROL/control)
package_count=0
failed_packages=0

for pkg_dir in "$ROOT_DIR"/*-package; do
    if [ -d "$pkg_dir" ] && [ -f "$pkg_dir/CONTROL/control" ]; then
        pkg_name=$(basename "$pkg_dir")
        print_info "Found package: $pkg_name"
        
        # Read architecture from control file
        arch=$(grep "^Architecture:" "$pkg_dir/CONTROL/control" | cut -d' ' -f2)
        
        if [ -z "$arch" ]; then
            print_warning "No architecture specified in $pkg_name, defaulting to 'all'"
            arch="all"
        fi
        
        print_info "Building $pkg_name for architecture: $arch"
        
        # Build the package (temporarily disable exit on error for controlled failure handling)
        set +e
        "$SCRIPT_DIR/build-package.sh" "$pkg_dir" "$arch"
        build_result=$?
        set -e
        
        if [ $build_result -eq 0 ]; then
            print_info "Successfully built $pkg_name"
            package_count=$((package_count + 1))
        else
            print_error "Failed to build $pkg_name"
            failed_packages=$((failed_packages + 1))
        fi
        
        echo ""
    fi
done

if [ $package_count -eq 0 ]; then
    print_warning "No packages found to build"
    print_info "Packages should be in directories ending with '-package' and contain CONTROL/control file"
    exit 0
fi

print_info "Built $package_count package(s)"

if [ $failed_packages -gt 0 ]; then
    print_error "$failed_packages package(s) failed to build"
    print_error "Skipping index generation due to build failures"
    exit 1
fi

# Generate package indexes
print_info "Generating package indexes"
"$SCRIPT_DIR/generate-index.sh"

print_info "Build process completed successfully"

#!/bin/bash
# Generate package index files (Packages and Packages.gz) for opkg feed

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

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="$ROOT_DIR/packages"

# Check if packages directory exists
if [ ! -d "$PACKAGES_DIR" ]; then
    print_error "Packages directory not found: $PACKAGES_DIR"
    exit 1
fi

# Function to extract control information from .ipk file
extract_package_info() {
    local ipk_file="$1"
    local temp_dir=$(mktemp -d)
    
    # Extract the .ipk file
    if command -v ar &> /dev/null; then
        cd "$temp_dir"
        ar x "$ipk_file" 2>/dev/null || {
            # Try as tar.gz if ar fails
            tar xzf "$ipk_file" 2>/dev/null || {
                print_error "Failed to extract $ipk_file"
                rm -rf "$temp_dir"
                return 1
            }
        }
    else
        cd "$temp_dir"
        tar xzf "$ipk_file" 2>/dev/null || {
            print_error "Failed to extract $ipk_file"
            rm -rf "$temp_dir"
            return 1
        }
    fi
    
    # Extract control.tar.gz
    if [ -f "control.tar.gz" ]; then
        tar xzf control.tar.gz
        if [ -f "control" ]; then
            # Get file size (portable approach)
            local size=$(wc -c < "$ipk_file" | tr -d ' ')
            
            # Get MD5 checksum (portable approach)
            local md5
            if command -v md5sum &> /dev/null; then
                md5=$(md5sum "$ipk_file" | awk '{print $1}')
            elif command -v md5 &> /dev/null; then
                md5=$(md5 -q "$ipk_file")
            else
                md5="unknown"
            fi
            local filename=$(basename "$ipk_file")
            
            # Print control file content
            cat control
            echo "Filename: $filename"
            echo "Size: $size"
            echo "MD5Sum: $md5"
            echo ""
        fi
    fi
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Process each architecture directory
for arch_dir in "$PACKAGES_DIR"/*; do
    if [ -d "$arch_dir" ]; then
        arch=$(basename "$arch_dir")
        print_info "Generating index for architecture: $arch"
        
        # Create Packages file
        packages_file="$arch_dir/Packages"
        > "$packages_file"
        
        # Process all .ipk files
        ipk_count=0
        for ipk in "$arch_dir"/*.ipk; do
            if [ -f "$ipk" ]; then
                print_info "Processing: $(basename "$ipk")"
                extract_package_info "$ipk" >> "$packages_file"
                ipk_count=$((ipk_count + 1))
            fi
        done
        
        if [ $ipk_count -eq 0 ]; then
            print_error "No .ipk files found in $arch_dir"
            rm -f "$packages_file"
            continue
        fi
        
        # Create Packages.gz
        print_info "Creating Packages.gz for $arch"
        gzip -9 -c "$packages_file" > "$arch_dir/Packages.gz"
        
        print_info "Index generated for $arch: $ipk_count package(s)"
        ls -lh "$packages_file" "$arch_dir/Packages.gz"
    fi
done

print_info "Package index generation complete"

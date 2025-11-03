#!/bin/bash
# Build script for creating opkg packages (.ipk files)
# Usage: ./build-package.sh <package-directory> <architecture>

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

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    print_error "Usage: $0 <package-directory> <architecture>"
    print_error "Example: $0 example-package all"
    exit 1
fi

PACKAGE_DIR="$1"
ARCHITECTURE="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$ROOT_DIR/packages/$ARCHITECTURE"

# Validate package directory exists
if [ ! -d "$PACKAGE_DIR" ]; then
    print_error "Package directory '$PACKAGE_DIR' does not exist"
    exit 1
fi

# Validate CONTROL file exists
if [ ! -d "$PACKAGE_DIR/CONTROL" ]; then
    print_error "CONTROL directory not found in '$PACKAGE_DIR'"
    exit 1
fi

if [ ! -f "$PACKAGE_DIR/CONTROL/control" ]; then
    print_error "control file not found in '$PACKAGE_DIR/CONTROL'"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Read package information from control file
PACKAGE_NAME=$(grep "^Package:" "$PACKAGE_DIR/CONTROL/control" | cut -d' ' -f2)
PACKAGE_VERSION=$(grep "^Version:" "$PACKAGE_DIR/CONTROL/control" | cut -d' ' -f2)
PACKAGE_ARCH=$(grep "^Architecture:" "$PACKAGE_DIR/CONTROL/control" | cut -d' ' -f2)

print_info "Building package: $PACKAGE_NAME"
print_info "Version: $PACKAGE_VERSION"
print_info "Architecture: $PACKAGE_ARCH"

# Create temporary build directory
BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT

# Copy package contents to build directory
cp -r "$PACKAGE_DIR"/* "$BUILD_DIR/"

# Ensure proper permissions
chmod 755 "$BUILD_DIR/CONTROL"
if [ -f "$BUILD_DIR/CONTROL/control" ]; then
    chmod 644 "$BUILD_DIR/CONTROL/control"
fi
if [ -f "$BUILD_DIR/CONTROL/preinst" ]; then
    chmod 755 "$BUILD_DIR/CONTROL/preinst"
fi
if [ -f "$BUILD_DIR/CONTROL/postinst" ]; then
    chmod 755 "$BUILD_DIR/CONTROL/postinst"
fi
if [ -f "$BUILD_DIR/CONTROL/prerm" ]; then
    chmod 755 "$BUILD_DIR/CONTROL/prerm"
fi
if [ -f "$BUILD_DIR/CONTROL/postrm" ]; then
    chmod 755 "$BUILD_DIR/CONTROL/postrm"
fi

# Build the package using opkg-build or create tar.gz manually
PACKAGE_FILE="${PACKAGE_NAME}_${PACKAGE_VERSION}_${PACKAGE_ARCH}.ipk"

print_info "Creating package file: $PACKAGE_FILE"

# Check if opkg-build is available
if command -v opkg-build &> /dev/null; then
    print_info "Using opkg-build tool"
    opkg-build -o root -g root "$BUILD_DIR" "$OUTPUT_DIR"
else
    print_warning "opkg-build not found, using manual tar.gz method"
    
    # Manual package creation
    cd "$BUILD_DIR"
    
    # Create control.tar.gz
    tar czf control.tar.gz -C CONTROL .
    
    # Create data.tar.gz (exclude CONTROL directory)
    # List all items except CONTROL and build files
    if [ -n "$(find . -mindepth 1 -maxdepth 1 ! -name CONTROL ! -name control.tar.gz ! -name data.tar.gz ! -name debian-binary -print -quit)" ]; then
        tar czf data.tar.gz --exclude='./CONTROL' --exclude='./control.tar.gz' --exclude='./data.tar.gz' --exclude='./debian-binary' \
            $(find . -mindepth 1 -maxdepth 1 ! -name CONTROL ! -name '*.tar.gz' ! -name debian-binary -printf '%P\n')
    else
        # Empty data archive if no files found
        tar czf data.tar.gz --files-from /dev/null
    fi
    
    # Create debian-binary
    echo "2.0" > debian-binary
    
    # Create the .ipk file (which is an ar archive)
    if command -v ar &> /dev/null; then
        ar r "$OUTPUT_DIR/$PACKAGE_FILE" debian-binary control.tar.gz data.tar.gz
    else
        # Fallback to tar if ar is not available
        print_warning "ar command not found, creating tar.gz instead of ar archive"
        tar czf "$OUTPUT_DIR/$PACKAGE_FILE" debian-binary control.tar.gz data.tar.gz
    fi
    
    cd - > /dev/null
fi

# Verify the package was created
if [ -f "$OUTPUT_DIR/$PACKAGE_FILE" ]; then
    print_info "Package built successfully: $OUTPUT_DIR/$PACKAGE_FILE"
    ls -lh "$OUTPUT_DIR/$PACKAGE_FILE"
    exit 0
else
    print_error "Failed to create package"
    exit 1
fi

# Packages Directory

This directory contains built OPKG packages organized by architecture.

## Directory Structure

```
packages/
├── all/       # Architecture-independent packages
├── arm/       # ARM architecture packages
├── mips/      # MIPS architecture packages
└── x86_64/    # x86_64 architecture packages
```

## Contents

Each architecture directory contains:
- `.ipk` files - Built OPKG packages
- `Packages` - Package index (plain text)
- `Packages.gz` - Compressed package index

## Building Packages

Packages are built automatically by GitHub Actions or manually using:

```bash
./scripts/build-all.sh
```

## Package Index

The `Packages` file contains metadata for all packages in the directory:
- Package name and version
- Architecture
- Dependencies
- Description
- File size and checksums

## Adding to OPKG

Add the appropriate architecture feed to your Enigma2 receiver:

```bash
# For architecture-independent packages
src/gz cockpit https://codeisus.github.io/Cockpit/packages/all

# For ARM
src/gz cockpit-arm https://codeisus.github.io/Cockpit/packages/arm

# For MIPS
src/gz cockpit-mips https://codeisus.github.io/Cockpit/packages/mips

# For x86_64
src/gz cockpit-x86_64 https://codeisus.github.io/Cockpit/packages/x86_64
```

Then update and install:

```bash
opkg update
opkg install <package-name>
```

## Notes

- Built packages (`.ipk` files) are not committed to git
- Only the directory structure is tracked
- Package indexes are generated during the build process
- See [USAGE.md](../USAGE.md) for user documentation
- See [BUILDING.md](../BUILDING.md) for build documentation

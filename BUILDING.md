# Building Packages Guide

This guide explains how to build OPKG packages for the Cockpit feed, both manually and automatically.

## Prerequisites

### Required Tools

For building packages, you need:

- `bash` (shell scripting)
- `tar` (archiving)
- `gzip` (compression)
- `ar` or `tar` (package creation)
- `md5sum` or `md5` (checksums)

### Optional Tools

For better package building:

- `opkg-utils` - Standard OPKG packaging tools
- `opkg-build` - Package builder utility

Install on Debian/Ubuntu:

```bash
sudo apt-get install opkg-utils
```

## Package Structure

Every package must follow this structure:

```
package-name-package/
├── CONTROL/
│   ├── control          # Required: Package metadata
│   ├── postinst         # Optional: Post-installation script
│   ├── prerm            # Optional: Pre-removal script
│   ├── preinst          # Optional: Pre-installation script
│   └── postrm           # Optional: Post-removal script
└── [data files]         # Package contents in filesystem hierarchy
    ├── usr/
    ├── etc/
    ├── opt/
    └── ...
```

### CONTROL/control File

This is the most important file. Example:

```
Package: my-plugin
Version: 1.0.0
Architecture: all
Maintainer: Your Name <your.email@example.com>
Section: multimedia
Priority: optional
Description: Short description
 Long description line 1
 Long description line 2
 .
 Paragraph separator
Depends: enigma2, python
Source: https://github.com/YourOrg/YourRepo
```

**Required fields:**
- `Package` - Unique package identifier (lowercase, no spaces)
- `Version` - Package version (e.g., 1.0.0, 2.1.3-beta)
- `Architecture` - Target architecture

**Recommended fields:**
- `Maintainer` - Your name and email
- `Description` - What the package does
- `Depends` - Required packages

**Optional fields:**
- `Section` - Category (multimedia, utils, network, etc.)
- `Priority` - Installation priority
- `Source` - Source code location
- `Homepage` - Project website

### Installation Scripts

All scripts must be executable and start with a shebang:

```bash
#!/bin/sh
```

**Exit codes:**
- `0` - Success
- `1` or higher - Failure (aborts installation)

#### postinst Example

```bash
#!/bin/sh
# Post-installation script

echo "Configuring package..."

# Create configuration directory
mkdir -p /etc/mypackage

# Set permissions
chmod 755 /etc/mypackage

# Reload services if needed
# /etc/init.d/enigma2 restart

exit 0
```

#### prerm Example

```bash
#!/bin/sh
# Pre-removal script

echo "Stopping services..."

# Stop services before removal
# /etc/init.d/myservice stop

exit 0
```

## Building Packages Manually

### Step 1: Create Package Directory

```bash
mkdir my-plugin-package
cd my-plugin-package
```

### Step 2: Create CONTROL Directory

```bash
mkdir CONTROL
```

### Step 3: Create control File

```bash
cat > CONTROL/control << 'EOF'
Package: my-plugin
Version: 1.0.0
Architecture: all
Maintainer: Your Name <email@example.com>
Description: My Enigma2 plugin
 This is a longer description
 of what the plugin does.
Depends: enigma2
EOF
```

### Step 4: Add Package Files

```bash
# Create directory structure
mkdir -p usr/lib/enigma2/python/Plugins/Extensions/MyPlugin

# Add your plugin files
cp /path/to/source/* usr/lib/enigma2/python/Plugins/Extensions/MyPlugin/
```

### Step 5: Add Installation Scripts (Optional)

```bash
cat > CONTROL/postinst << 'EOF'
#!/bin/sh
echo "Installing My Plugin..."
exit 0
EOF

chmod +x CONTROL/postinst
```

### Step 6: Build the Package

```bash
cd ..
./scripts/build-package.sh my-plugin-package all
```

The package will be created in `packages/all/`.

## Building All Packages

To build all packages in the repository:

```bash
./scripts/build-all.sh
```

This script:
1. Finds all directories ending in `-package`
2. Builds each package for its specified architecture
3. Generates package indexes (Packages and Packages.gz)

## Automated Building with GitHub Actions

The repository includes a GitHub Actions workflow that automatically builds packages.

### Trigger Conditions

The workflow runs on:

1. **Push to main/develop branches** - When package files change
2. **Pull requests** - For testing before merge
3. **Releases** - When creating a new release
4. **Manual trigger** - Via GitHub Actions UI

### Workflow Steps

1. Checkout repository
2. Install build dependencies
3. Build all packages
4. Generate package indexes
5. Upload artifacts
6. (Optional) Publish to GitHub Pages
7. (Optional) Attach to releases

### Viewing Build Results

After a workflow run:

1. Go to the "Actions" tab in GitHub
2. Select the workflow run
3. Download the "opkg-packages" artifact
4. Extract to see built packages

### Manual Workflow Trigger

1. Go to Actions tab
2. Select "Build OPKG Packages" workflow
3. Click "Run workflow"
4. (Optional) Specify target architecture
5. Click "Run workflow" button

## Package Versioning

### Version Format

Use semantic versioning:

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

Examples:
- `1.0.0` - Initial release
- `1.0.1` - Patch release
- `1.1.0` - Minor update
- `2.0.0` - Major update
- `1.0.0-beta.1` - Pre-release
- `1.0.0+20240101` - Build metadata

### Updating Versions

When releasing a new version:

1. Update the `Version` field in `CONTROL/control`
2. Commit the change
3. Create a git tag:
   ```bash
   git tag -a v1.0.1 -m "Release version 1.0.1"
   git push origin v1.0.1
   ```
4. Create a GitHub release (triggers automatic build)

## Testing Packages

### Test Installation Locally

```bash
# Extract package to inspect contents
ar x packages/all/my-plugin_1.0.0_all.ipk
tar xzf control.tar.gz
cat control

tar xzf data.tar.gz
ls -la
```

### Test on Device

```bash
# Copy package to device
scp packages/all/my-plugin_1.0.0_all.ipk root@receiver:/tmp/

# SSH to device
ssh root@receiver

# Install package
opkg install /tmp/my-plugin_1.0.0_all.ipk

# Verify installation
opkg list-installed | grep my-plugin
opkg files my-plugin
```

## Troubleshooting

### Build Script Fails

**Error: CONTROL/control not found**
- Ensure the control file exists and has the correct name (lowercase)
- Check file permissions

**Error: ar command not found**
- The script will fallback to tar
- For proper .ipk format, install `binutils`

**Error: Package name/version not found**
- Verify control file has `Package:` and `Version:` fields
- Ensure proper formatting (no extra spaces)

### Package Won't Install

**Error: Depends on X**
- Install dependencies first
- Or build without dependency checking (for testing only)

**Error: Package architecture mismatch**
- Check the architecture in control file matches receiver
- Use `all` for architecture-independent packages

## Best Practices

1. **Always test packages** before publishing
2. **Use semantic versioning** for version numbers
3. **Document dependencies** accurately
4. **Test installation scripts** thoroughly
5. **Keep packages small** - split large packages if needed
6. **Use meaningful descriptions** in control files
7. **Include source references** for open source compliance
8. **Test on target hardware** before release
9. **Maintain a changelog** for version tracking
10. **Sign packages** for production use (optional)

## Advanced Topics

### Package Signing

For production environments, sign your packages:

```bash
# Generate GPG key
gpg --gen-key

# Sign package index
gpg --armor --detach-sign packages/all/Packages

# Creates Packages.sig
```

Configure opkg to verify signatures:

```bash
echo "option check_signature 1" >> /etc/opkg/opkg.conf
```

### Cross-Architecture Building

For building multiple architectures:

```bash
# Build for specific architecture
./scripts/build-package.sh my-package arm
./scripts/build-package.sh my-package mips
./scripts/build-package.sh my-package x86_64
```

### Custom Build Scripts

For packages requiring compilation:

```bash
# Add compilation step before packaging
cd my-plugin-package
make CC=arm-linux-gcc
make install DESTDIR=$PWD
cd ..
./scripts/build-package.sh my-plugin-package arm
```

## Resources

- [OPKG Documentation](https://openwrt.org/docs/guide-user/additional-software/opkg)
- [Enigma2 Plugin Development](https://wiki.openpli.org/Plugin_Development)
- [IPK Package Format](https://en.wikipedia.org/wiki/Opkg)

## Getting Help

If you need assistance:

1. Check this documentation
2. Review example-package for reference
3. Open an issue on GitHub
4. Check build logs in GitHub Actions

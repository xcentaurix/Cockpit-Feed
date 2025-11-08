# Building Packages for Submission

This guide explains how to build OPKG packages externally for submission to the Cockpit feed.

## Prerequisites

### Required Tools

For building packages, you need:

- `opkg-utils` - Standard OPKG packaging tools (recommended)
- `opkg-build` - Package builder utility

Install on Debian/Ubuntu:

```bash
sudo apt-get install opkg-utils
```

Alternatively, you can use basic tools:
- `bash` (shell scripting)
- `tar` (archiving)
- `gzip` (compression)
- `ar` (from binutils)

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

Using opkg-build (recommended):

```bash
cd ..
opkg-build -o root -g root my-plugin-package
```

This creates `my-plugin_1.0.0_all.ipk` in the current directory.

## Alternative: Manual Package Creation

If opkg-build is not available, you can create packages manually:

```bash
cd my-plugin-package

# Create control.tar.gz
tar czf control.tar.gz -C CONTROL .

# Create data.tar.gz (exclude CONTROL directory)
tar czf data.tar.gz --exclude='./CONTROL' --exclude='*.tar.gz' --exclude='debian-binary' \
    $(find . -mindepth 1 -maxdepth 1 ! -name CONTROL ! -name '*.tar.gz' ! -name debian-binary)

# Create debian-binary
echo "2.0" > debian-binary

# Create the .ipk file (ar archive)
ar r ../my-plugin_1.0.0_all.ipk debian-binary control.tar.gz data.tar.gz

cd ..
```

## Submitting Your Package

Once you've built your package:

1. **Test the package** locally to ensure it works
2. **Copy the .ipk file** to the appropriate directory in the Cockpit-Feed repository:
   ```bash
   cp my-plugin_1.0.0_all.ipk /path/to/Cockpit-Feed/packages/all/
   ```
3. **Commit and submit a pull request**

The GitHub Actions workflow will automatically:
- Generate package indexes when your PR is merged
- Publish the updated feed to GitHub Pages

## Package Versioning

### Version Format

Use semantic versioning in the `Version` field of your control file:

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

## Testing Packages

### Inspect Package Contents

```bash
# Extract package to inspect contents
ar x my-plugin_1.0.0_all.ipk
tar xzf control.tar.gz
cat control

tar xzf data.tar.gz
ls -la
```

### Test on Device

```bash
# Copy package to device
scp my-plugin_1.0.0_all.ipk root@receiver:/tmp/

# SSH to device
ssh root@receiver

# Install package
opkg install /tmp/my-plugin_1.0.0_all.ipk

# Verify installation
opkg list-installed | grep my-plugin
opkg files my-plugin

# Test functionality
# (Run your plugin and verify it works)

# Remove package when done testing
opkg remove my-plugin
```

## Troubleshooting

### Build Issues

**Error: opkg-build not found**
- Install opkg-utils: `sudo apt-get install opkg-utils`
- Or use the manual method described above

**Error: CONTROL/control not found**
- Ensure the control file exists and has the correct name (lowercase)
- Check file permissions

**Error: Package name/version format incorrect**
- Verify control file has `Package:` and `Version:` fields
- Ensure proper formatting (no extra spaces)

### Package Won't Install

**Error: Depends on X**
- Install dependencies first
- Or test without dependency checking: `opkg install --force-depends`

**Error: Package architecture mismatch**
- Check the architecture in control file matches receiver
- Use `all` for architecture-independent packages

## Best Practices

1. **Always test packages** on a real device before submission
2. **Use semantic versioning** for version numbers
3. **Document dependencies** accurately in the control file
4. **Test installation scripts** thoroughly
5. **Keep packages small** - split large packages if needed
6. **Use meaningful descriptions** in control files
7. **Include source references** for open source compliance
8. **Maintain a changelog** for version tracking
9. **Verify file permissions** are correct in the package

## Advanced Topics

### Cross-Architecture Building

For building packages for different architectures, use appropriate cross-compilation tools:

```bash
# Example for ARM
CC=arm-linux-gnueabihf-gcc make
make install DESTDIR=my-plugin-package
opkg-build my-plugin-package

# Example for MIPS
CC=mipsel-linux-gnu-gcc make
make install DESTDIR=my-plugin-package
opkg-build my-plugin-package
```

### Packages with Compiled Binaries

For packages requiring compilation:

1. Set up a cross-compilation environment
2. Compile your code for the target architecture
3. Install files to the package directory structure
4. Build the package with opkg-build

## Resources

- [OPKG Documentation](https://openwrt.org/docs/guide-user/additional-software/opkg)
- [Enigma2 Plugin Development](https://wiki.openpli.org/Plugin_Development)
- [IPK Package Format](https://en.wikipedia.org/wiki/Opkg)
- [opkg-utils on GitHub](https://git.yoctoproject.org/opkg-utils/)

## Getting Help

If you need assistance:

1. Check this documentation
2. Review [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
3. Open an issue on GitHub
4. Check existing packages in the repository for examples

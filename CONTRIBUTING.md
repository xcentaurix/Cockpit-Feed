# Contributing to Cockpit Package Feed

Thank you for your interest in contributing to the Cockpit OPKG package feed! This guide will help you get started.

## Ways to Contribute

- **Add new packages** - Submit pre-built `.ipk` files for new Enigma2 plugins
- **Update existing packages** - Submit updated versions with bug fixes and improvements
- **Improve documentation** - Help others understand the project
- **Report issues** - Let us know about problems
- **Test packages** - Try packages on different receivers and report results

## Getting Started

### Prerequisites

- Git
- Understanding of OPKG package format
- Tools to build OPKG packages (opkg-utils or equivalent)
- Enigma2 receiver for testing (recommended)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Cockpit-Feed.git
   cd Cockpit-Feed
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/dream-alpha/Cockpit-Feed.git
   ```

## Adding a New Package

### Step 1: Build Your Package Externally

Build your package using standard OPKG tools. See [BUILDING.md](BUILDING.md) for detailed instructions.

Quick example using opkg-build:

```bash
# Create package directory structure
mkdir -p my-plugin/CONTROL
mkdir -p my-plugin/usr/lib/enigma2/python/Plugins/Extensions/MyPlugin

# Create control file
cat > my-plugin/CONTROL/control << 'EOF'
Package: my-plugin
Version: 1.0.0
Architecture: all
Maintainer: Your Name <your.email@example.com>
Section: multimedia
Priority: optional
Description: One-line description
 Longer description
 spanning multiple lines.
Depends: enigma2
Source: https://github.com/YourUsername/YourRepo
EOF

# Add your plugin files
cp -r /path/to/source/* my-plugin/usr/lib/enigma2/python/Plugins/Extensions/MyPlugin/

# Build the package
opkg-build my-plugin
```

This creates `my-plugin_1.0.0_all.ipk`.

**Important:**
- Use lowercase package name with hyphens
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Specify correct architecture
- List all dependencies accurately

### Step 2: Test Your Package

Test the package on an Enigma2 receiver:

```bash
# Copy package to device
scp my-plugin_1.0.0_all.ipk root@receiver:/tmp/

# SSH to device and install
ssh root@receiver
opkg install /tmp/my-plugin_1.0.0_all.ipk

# Test functionality
# ...

# Remove package
opkg remove my-plugin
```

### Step 3: Inspect Package Contents

Verify the package contents are correct:

```bash
# Extract and inspect
ar x my-plugin_1.0.0_all.ipk
tar xzf control.tar.gz
cat control
tar xzf data.tar.gz
ls -la
```

## Submitting Your Contribution

### Before Submitting

1. **Build your package** using standard OPKG tools
2. **Test thoroughly**
   - Test installation on a receiver (required)
   - Verify all dependencies are listed
   - Check file permissions
   - Ensure the package works as expected
3. **Verify package quality**
   - Package follows naming conventions
   - Version number is correct
   - Control file has all required fields
   - Package size is reasonable

### Create Pull Request

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/YOUR-USERNAME/Cockpit-Feed.git
   cd Cockpit-Feed
   ```

2. **Create a branch**
   ```bash
   git checkout -b add-my-plugin
   ```

3. **Add your pre-built .ipk file**
   ```bash
   # Copy to the appropriate architecture directory
   cp /path/to/my-plugin_1.0.0_all.ipk packages/all/
   
   # Or for specific architecture
   cp /path/to/my-plugin_1.0.0_arm.ipk packages/arm/
   ```

4. **Commit your changes**
   ```bash
   git add packages/
   git commit -m "Add my-plugin package v1.0.0

   - Brief description of the plugin
   - Key features
   - Target architecture: all
   - Tested on: [your receiver model]"
   ```

5. **Push to your fork**
   ```bash
   git push origin add-my-plugin
   ```

6. **Open Pull Request**
   - Go to GitHub and create a pull request
   - Explain what your package does
   - Mention testing performed
   - List any special requirements or dependencies

### Pull Request Guidelines

- **Title**: Clear and descriptive (e.g., "Add my-plugin package v1.0.0")
- **Description**: 
  - What the package does
  - Why it's useful
  - Testing performed (receiver model, architecture)
  - Any special considerations or dependencies
- **One package per PR**: Submit separate PRs for different packages
- **Pre-built only**: Only submit `.ipk` files, not source directories
- **Package quality**: Ensure package is properly built and tested

## Package Guidelines

### Package Naming

- Use lowercase letters
- Use hyphens for word separation
- Be descriptive but concise
- Prefix with `cockpit-` if part of Cockpit series

Examples:
- ✅ `cockpit-weather`
- ✅ `cockpit-epg-enhancer`
- ❌ `Cockpit_Weather`
- ❌ `cpw` (too cryptic)

### Versioning

Follow semantic versioning:

- **1.0.0** - Initial release
- **1.0.1** - Patch (bug fixes)
- **1.1.0** - Minor (new features, backward compatible)
- **2.0.0** - Major (breaking changes)

### Architecture Selection

- **all** - Pure Python, scripts, configurations
- **arm** - Compiled for ARM processors
- **mips** - Compiled for MIPS processors
- **x86_64** - Compiled for Intel/AMD 64-bit

Use `all` unless your package includes compiled binaries.

### Dependencies

List all runtime dependencies:

```
Depends: enigma2, python-core, python-requests
```

Common dependencies:
- `enigma2` - Base system
- `python-core` - Python runtime
- `python-xxx` - Python modules

### File Permissions

Set appropriate permissions:
- Executables: `755`
- Configuration files: `644`
- Scripts in CONTROL: `755`
- Directories: `755`

## Review Process

After submitting a PR:

1. **Automated checks**: GitHub Actions will validate your submission
2. **Maintainer review**: A maintainer will review your package
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged
5. **Publication**: Package indexes are automatically generated and the package becomes available in the feed

## Testing Guidelines

### Required Testing

Before submitting, you **must** test your package on an actual Enigma2 receiver:

```bash
# Copy package to receiver
scp my-plugin_1.0.0_all.ipk root@receiver:/tmp/

# SSH to receiver
ssh root@receiver

# Install package
opkg install /tmp/my-plugin_1.0.0_all.ipk

# Test functionality thoroughly
# - Verify plugin appears in menu
# - Test all features
# - Check for errors in logs
# - Verify removal works correctly

# Remove package
opkg remove my-plugin
```

### Package Inspection

Verify package contents before submission:

```bash
# Inspect contents
mkdir /tmp/test-package
cd /tmp/test-package
ar x /path/to/my-plugin_1.0.0_all.ipk
tar xzf control.tar.gz
cat control

tar xzf data.tar.gz
tree .  # or ls -laR

# Verify:
# - All files are in correct locations
# - No unnecessary files included
# - Permissions are correct
```

## Common Issues

### Package Build Issues

**Problem**: opkg-build not found

**Solution**: 
- Install opkg-utils: `sudo apt-get install opkg-utils`
- Or follow manual build instructions in [BUILDING.md](BUILDING.md)

**Problem**: Control file format errors

**Solution**: 
- Check control file has all required fields
- Ensure proper formatting (no extra spaces)
- Use existing packages as reference

### Package Won't Install

**Problem**: Dependency errors

**Solution**:
- List all required packages in `Depends:`
- Test on a receiver with base system
- Check dependency package names are correct
- Verify dependencies are available in OPKG feeds

**Problem**: Files in wrong location

**Solution**:
- Check directory structure matches Enigma2 expectations
- Verify paths are relative (no leading slash in package directory structure)
- Use `opkg files <package>` to see where files were installed

## Getting Help

- **Documentation**: Read [BUILDING.md](BUILDING.md) and [USAGE.md](USAGE.md)
- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions for questions
- **Examples**: Examine existing `.ipk` files in the `packages/` directories

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on the code, not the person
- Assume good intentions
- Follow GitHub's Community Guidelines

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE)).

## Recognition

Contributors are recognized in:
- Git commit history
- Release notes
- Package maintainer field (for package authors)

Thank you for contributing to Cockpit! 🚀

# Contributing to Cockpit Package Feed

Thank you for your interest in contributing to the Cockpit OPKG package feed! This guide will help you get started.

## Ways to Contribute

- **Add new packages** - Submit new Enigma2 plugins
- **Update existing packages** - Bug fixes and improvements
- **Improve documentation** - Help others understand the project
- **Report issues** - Let us know about problems
- **Test packages** - Try packages on different receivers

## Getting Started

### Prerequisites

- Git
- Basic knowledge of Bash scripting
- Understanding of OPKG package format
- Enigma2 receiver for testing (recommended)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Cockpit.git
   cd Cockpit
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/CodeIsUs/Cockpit.git
   ```

## Adding a New Package

### Step 1: Create Package Structure

```bash
# Create package directory (must end with -package)
mkdir my-plugin-package
cd my-plugin-package

# Create CONTROL directory
mkdir CONTROL
```

### Step 2: Create Control File

Create `CONTROL/control` with package metadata:

```
Package: my-plugin
Version: 1.0.0
Architecture: all
Maintainer: Your Name <your.email@example.com>
Section: multimedia
Priority: optional
Description: One-line description
 Longer description
 spanning multiple lines.
 .
 Paragraph separator for additional info.
Depends: enigma2
Source: https://github.com/YourUsername/YourRepo
Homepage: https://yourwebsite.com
```

**Important:**
- Use lowercase package name with hyphens
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Specify correct architecture
- List all dependencies accurately

### Step 3: Add Package Files

Add your plugin files in the proper directory structure:

```bash
# For Enigma2 plugins
mkdir -p usr/lib/enigma2/python/Plugins/Extensions/MyPlugin

# Copy your plugin files
cp -r /path/to/source/* usr/lib/enigma2/python/Plugins/Extensions/MyPlugin/

# For configuration files
mkdir -p etc/mypackage
cp config.conf etc/mypackage/
```

### Step 4: Add Installation Scripts (Optional)

Create installation scripts if needed:

```bash
# Post-installation script
cat > CONTROL/postinst << 'EOF'
#!/bin/sh
echo "Installing My Plugin..."
# Add post-installation commands here
exit 0
EOF

chmod +x CONTROL/postinst
```

Available scripts:
- `preinst` - Before installation
- `postinst` - After installation
- `prerm` - Before removal
- `postrm` - After removal

### Step 5: Test Locally

Build and test your package:

```bash
cd ..
./scripts/build-package.sh my-plugin-package all

# Check the built package
ls -lh packages/all/my-plugin_*.ipk

# Inspect package contents
ar t packages/all/my-plugin_*.ipk
```

### Step 6: Create Package Documentation

Add a README.md to your package directory:

```bash
cat > my-plugin-package/README.md << 'EOF'
# My Plugin

Description of what your plugin does.

## Features

- Feature 1
- Feature 2

## Installation

```bash
opkg install my-plugin
```

## Configuration

Explain how to configure the plugin.

## Usage

Explain how to use the plugin.

## License

Specify the license.
EOF
```

## Submitting Your Contribution

### Before Submitting

1. **Test thoroughly**
   - Build the package successfully
   - Test installation on a receiver (if possible)
   - Verify all dependencies are listed
   - Check file permissions

2. **Follow code style**
   - Use consistent formatting
   - Add comments where needed
   - Follow existing patterns

3. **Update documentation**
   - Add package README
   - Update main README if needed
   - Document any special requirements

### Create Pull Request

1. **Create a branch**
   ```bash
   git checkout -b add-my-plugin
   ```

2. **Commit your changes**
   ```bash
   git add my-plugin-package/
   git commit -m "Add my-plugin package

   - Brief description of the plugin
   - Key features
   - Target architecture"
   ```

3. **Push to your fork**
   ```bash
   git push origin add-my-plugin
   ```

4. **Open Pull Request**
   - Go to GitHub and create a pull request
   - Fill in the PR template
   - Explain what your package does
   - Mention any testing performed

### Pull Request Guidelines

- **Title**: Clear and descriptive (e.g., "Add my-plugin package")
- **Description**: 
  - What the package does
  - Why it's useful
  - Any special considerations
  - Testing performed
- **One package per PR**: Don't mix multiple packages
- **Follow conventions**: Match existing structure

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

## Code Review Process

After submitting a PR:

1. **Automated checks**: GitHub Actions will build your package
2. **Maintainer review**: A maintainer will review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged
5. **Publication**: Package becomes available in the feed

## Testing Guidelines

### Local Testing

```bash
# Build package
./scripts/build-package.sh my-plugin-package all

# Inspect contents
mkdir /tmp/test-package
cd /tmp/test-package
ar x /path/to/package.ipk
tar xzf control.tar.gz
tar xzf data.tar.gz

# Verify files are in correct locations
ls -la
```

### On-Device Testing

If you have access to an Enigma2 receiver:

```bash
# Copy package to receiver
scp packages/all/my-plugin_*.ipk root@receiver:/tmp/

# SSH to receiver
ssh root@receiver

# Install package
opkg install /tmp/my-plugin_*.ipk

# Test functionality
# ...

# Remove package
opkg remove my-plugin
```

## Common Issues

### Build Fails

**Problem**: Script can't find CONTROL/control

**Solution**: 
- Ensure directory name ends with `-package`
- Check control file exists and is named correctly (lowercase)
- Verify file permissions

### Package Won't Install

**Problem**: Dependency errors

**Solution**:
- List all required packages in `Depends:`
- Test on a receiver with minimal packages
- Check package names are correct

### Files in Wrong Location

**Problem**: Files not appearing after installation

**Solution**:
- Check directory structure matches Enigma2 expectations
- Verify paths are relative (no leading slash)
- Use `opkg files <package>` to see where files go

## Getting Help

- **Documentation**: Read [BUILDING.md](BUILDING.md) and [USAGE.md](USAGE.md)
- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions for questions
- **Examples**: Look at `example-package` for reference

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

# Cockpit

OPKG Package Feed for Cockpit series OA Enigma2 plugins

[![Build OPKG Packages](https://github.com/CodeIsUs/Cockpit/actions/workflows/build-packages.yml/badge.svg)](https://github.com/CodeIsUs/Cockpit/actions/workflows/build-packages.yml)

## Overview

This repository provides an automated OPKG package feed for Enigma2 receiver plugins. It includes:

- ✅ Proper OPKG package feed structure
- ✅ Automated build process for `.ipk` packages
- ✅ GitHub Actions CI/CD integration
- ✅ Multi-architecture support (ARM, MIPS, x86_64)
- ✅ Automatic package index generation
- ✅ Example package template

## Quick Start

### For Users

Add the package feed to your Enigma2 receiver:

```bash
# Add feed configuration
echo "src/gz cockpit https://codeisus.github.io/Cockpit/packages/all" > /etc/opkg/cockpit.conf

# Update package list
opkg update

# Install packages
opkg install cockpit-example
```

See [USAGE.md](USAGE.md) for detailed instructions.

### For Developers

Build packages locally:

```bash
# Clone the repository
git clone https://github.com/CodeIsUs/Cockpit.git
cd Cockpit

# Build all packages
./scripts/build-all.sh

# Or build a specific package
./scripts/build-package.sh example-package all
```

See [BUILDING.md](BUILDING.md) for comprehensive building instructions.

## Package Feed Structure

```
Cockpit/
├── packages/              # Built packages (generated)
│   ├── all/              # Architecture-independent packages
│   ├── arm/              # ARM packages
│   ├── mips/             # MIPS packages
│   └── x86_64/           # x86_64 packages
├── scripts/              # Build scripts
│   ├── build-package.sh  # Build individual package
│   ├── build-all.sh      # Build all packages
│   └── generate-index.sh # Generate package indexes
├── example-package/      # Example package template
│   ├── CONTROL/          # Package metadata
│   └── usr/              # Package files
└── .github/
    └── workflows/
        └── build-packages.yml  # CI/CD workflow
```

## Creating New Packages

1. **Copy the example package:**
   ```bash
   cp -r example-package my-plugin-package
   ```

2. **Update the control file:**
   ```bash
   vi my-plugin-package/CONTROL/control
   ```
   
   Update package name, version, description, and dependencies.

3. **Add your plugin files:**
   ```bash
   # Add files in proper Enigma2 directory structure
   mkdir -p my-plugin-package/usr/lib/enigma2/python/Plugins/Extensions/MyPlugin
   cp -r /path/to/source/* my-plugin-package/usr/lib/enigma2/python/Plugins/Extensions/MyPlugin/
   ```

4. **Build the package:**
   ```bash
   ./scripts/build-package.sh my-plugin-package all
   ```

5. **Test installation:**
   ```bash
   opkg install packages/all/my-plugin_*.ipk
   ```

See the [example-package README](example-package/README.md) for detailed package structure.

## Automated Builds

Packages are automatically built via GitHub Actions when:

- Code is pushed to `main` or `develop` branches
- Pull requests are created
- New releases are published
- Manually triggered via Actions tab

Built packages are:
- Available as workflow artifacts (90 days retention)
- Attached to GitHub releases
- Published to GitHub Pages (optional)

## Architecture Support

The feed supports multiple architectures:

- **all** - Architecture-independent packages (Python scripts, configs)
- **arm** - ARM-based receivers (e.g., Raspberry Pi, many STBs)
- **mips** - MIPS-based receivers (common in older STBs)
- **x86_64** - Intel/AMD 64-bit receivers

Specify architecture in the package's `CONTROL/control` file.

## Documentation

- **[USAGE.md](USAGE.md)** - How to use the package feed on your receiver
- **[BUILDING.md](BUILDING.md)** - How to build packages manually
- **[example-package/README.md](example-package/README.md)** - Package structure reference

## Requirements

### For Building Packages

- bash
- tar
- gzip
- ar (optional, from binutils)
- opkg-utils (optional, for better compatibility)

### For Installing Packages

- Enigma2 receiver with OPKG support
- Network connectivity (for remote feeds)
- Sufficient storage space

## Contributing

1. Fork the repository
2. Create a new package directory (must end with `-package`)
3. Add your package files and CONTROL metadata
4. Test the build locally
5. Submit a pull request

All pull requests trigger automatic package builds for validation.

## Package Signing

For production use, consider signing packages:

```bash
# Generate GPG key
gpg --gen-key

# Sign package index
gpg --armor --detach-sign packages/all/Packages
```

Configure receivers to verify signatures in `/etc/opkg/opkg.conf`:

```
option check_signature 1
```

## Troubleshooting

### Build Issues

- Ensure scripts are executable: `chmod +x scripts/*.sh`
- Check package has valid `CONTROL/control` file
- Verify directory name ends with `-package`

### Installation Issues

- Update package list: `opkg update`
- Check network connectivity to feed
- Verify architecture matches receiver
- Check available disk space: `df -h`

See documentation for detailed troubleshooting.

## License

See [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/CodeIsUs/Cockpit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/CodeIsUs/Cockpit/discussions)
- **Documentation**: See docs in this repository

## Maintainers

Cockpit Team - Enigma2 Plugin Development

---

**Note**: This package feed is for Cockpit series plugins for Enigma2 receivers. Make sure to test packages thoroughly before deploying to production receivers.

# Cockpit

OPKG Package Feed for Cockpit series OA Enigma2 plugins

[![Publish Package Feed](https://github.com/CodeIsUs/Cockpit/actions/workflows/build-packages.yml/badge.svg)](https://github.com/CodeIsUs/Cockpit/actions/workflows/build-packages.yml)

## Overview

This repository provides an OPKG package feed for Enigma2 receiver plugins. It includes:

- ✅ Proper OPKG package feed structure
- ✅ Pre-built `.ipk` packages
- ✅ GitHub Actions for package index generation
- ✅ Multi-architecture support (ARM, MIPS, x86_64)
- ✅ Automatic package index generation and publishing

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

### For Contributors

To contribute packages to this feed:

```bash
# Clone the repository
git clone https://github.com/CodeIsUs/Cockpit.git
cd Cockpit

# Add your pre-built .ipk file to the appropriate architecture directory
cp /path/to/your-package.ipk packages/all/

# Commit and submit a pull request
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## Package Feed Structure

```
Cockpit/
├── packages/              # Pre-built packages
│   ├── all/              # Architecture-independent packages
│   │   └── *.ipk         # Package files (committed)
│   ├── arm/              # ARM packages
│   │   └── *.ipk         # Package files (committed)
│   ├── mips/             # MIPS packages
│   │   └── *.ipk         # Package files (committed)
│   └── x86_64/           # x86_64 packages
│       └── *.ipk         # Package files (committed)
├── scripts/              # Utility scripts
│   └── generate-index.sh # Generate package indexes
└── .github/
    └── workflows/
        └── build-packages.yml  # Package index generation workflow
```

## Adding Packages

To add a package to this feed:

1. **Build your package externally** using standard OPKG tools:
   ```bash
   # Build your package using opkg-build or similar tools
   opkg-build my-plugin-directory
   ```

2. **Copy the .ipk file** to the appropriate architecture directory:
   ```bash
   cp my-plugin_1.0.0_all.ipk packages/all/
   ```

3. **Submit a pull request** with your package.

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on preparing and submitting packages.

## Automated Package Index Generation

Package indexes are automatically generated via GitHub Actions when:

- `.ipk` files are pushed to the `main` branch
- Manually triggered via Actions tab

Generated indexes are:
- Published to GitHub Pages for the OPKG feed
- Available for immediate use by receivers

## Architecture Support

The feed supports multiple architectures:

- **all** - Architecture-independent packages (Python scripts, configs)
- **arm** - ARM-based receivers (e.g., Raspberry Pi, many STBs)
- **mips** - MIPS-based receivers (common in older STBs)
- **x86_64** - Intel/AMD 64-bit receivers

Specify architecture in the package's `CONTROL/control` file.

## Documentation

- **[USAGE.md](USAGE.md)** - How to use the package feed on your receiver
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute packages to this feed

## Requirements

### For Installing Packages

- Enigma2 receiver with OPKG support
- Network connectivity (for remote feeds)
- Sufficient storage space

## Contributing

1. Fork the repository
2. Build your package externally using standard OPKG tools
3. Add your pre-built `.ipk` file to the appropriate architecture directory
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

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

### Installation Issues

- Update package list: `opkg update`
- Check network connectivity to feed
- Verify architecture matches receiver
- Check available disk space: `df -h`

See [USAGE.md](USAGE.md) for detailed troubleshooting.

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

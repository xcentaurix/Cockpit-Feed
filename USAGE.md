# Package Feed Usage Guide

This guide explains how to use the Cockpit OPKG package feed on your Enigma2 receiver.

## What is OPKG?

OPKG is a lightweight package management system used in embedded Linux systems like Enigma2 receivers. It allows you to easily install, update, and remove software packages.

## Adding the Package Feed

### Method 1: Using GitHub Pages (Recommended)

If the package feed is published to GitHub Pages:

1. SSH into your Enigma2 receiver
2. Create or edit the opkg configuration file:

```bash
vi /etc/opkg/cockpit.conf
```

3. Add the package feed URL:

```
src/gz cockpit https://dream-alpha.github.io/Cockpit-Feed/packages/all
```

**Note:** Replace the URL with the actual GitHub Pages URL for this repository.

### Method 2: Using GitHub Releases

If packages are distributed via GitHub Releases:

1. Download the package feed archive from the latest release
2. Extract it to a web server or local directory
3. Configure opkg to point to that location

### Method 3: Local Package Feed

For testing or offline installations:

1. Copy the `packages` directory to your receiver (e.g., via FTP/SCP)
2. Add a local feed configuration:

```bash
echo "src/gz cockpit file:///path/to/packages/all" > /etc/opkg/cockpit.conf
```

## Architecture-Specific Feeds

If your receiver has a specific architecture, use the appropriate feed:

```bash
# For ARM-based receivers
src/gz cockpit-arm https://dream-alpha.github.io/Cockpit-Feed/packages/arm

# For MIPS-based receivers
src/gz cockpit-mips https://dream-alpha.github.io/Cockpit-Feed/packages/mips

# For x86_64-based receivers
src/gz cockpit-x86_64 https://dream-alpha.github.io/Cockpit-Feed/packages/x86_64

# For architecture-independent packages
src/gz cockpit-all https://dream-alpha.github.io/Cockpit-Feed/packages/all
```

## Installing Packages

Once the feed is configured:

1. Update the package list:

```bash
opkg update
```

2. Search for available packages:

```bash
opkg list | grep cockpit
```

3. Install a package:

```bash
opkg install cockpit-example
```

4. Check installed packages:

```bash
opkg list-installed | grep cockpit
```

## Updating Packages

To update all installed packages:

```bash
opkg update
opkg upgrade
```

To update a specific package:

```bash
opkg update
opkg upgrade cockpit-example
```

## Removing Packages

To remove a package:

```bash
opkg remove cockpit-example
```

To remove a package and its configuration files:

```bash
opkg remove --force-removal-of-dependent-packages cockpit-example
```

## Troubleshooting

### Package Not Found

If `opkg update` doesn't find packages:

1. Check the feed URL is correct
2. Verify network connectivity:
   ```bash
   wget -O- https://dream-alpha.github.io/Cockpit-Feed/packages/all/Packages
   ```
3. Check if the Packages.gz file exists on the server

### Installation Fails

If package installation fails:

1. Check dependencies:
   ```bash
   opkg info cockpit-example
   ```
2. Install missing dependencies manually
3. Check available disk space:
   ```bash
   df -h
   ```

### SSL/Certificate Issues

If you encounter SSL errors:

```bash
opkg update --no-check-certificate
```

**Warning:** Only use this for testing. For production, install proper certificates.

## Package Information

View detailed package information:

```bash
opkg info cockpit-example
```

View package files:

```bash
opkg files cockpit-example
```

## Advanced Configuration

### Multiple Feeds

You can add multiple feeds in separate configuration files:

```bash
/etc/opkg/cockpit.conf       # Cockpit feed
/etc/opkg/custom.conf        # Custom feed
/etc/opkg/testing.conf       # Testing feed
```

### Priority Configuration

Set feed priority in `/etc/opkg/opkg.conf`:

```
option overlay_root /overlay
option check_signature 1
```

## Security Notes

- Always verify package sources before installation
- Keep your system updated regularly
- Review package descriptions and dependencies
- Consider using package signing for production environments

## Getting Help

If you encounter issues:

1. Check the package feed documentation
2. Review package logs in `/var/log/`
3. Open an issue on the GitHub repository
4. Check Enigma2 forums for receiver-specific issues

## Feed URLs Quick Reference

```bash
# All architectures
src/gz cockpit-all https://dream-alpha.github.io/Cockpit-Feed/packages/all

# ARM
src/gz cockpit-arm https://dream-alpha.github.io/Cockpit-Feed/packages/arm

# MIPS
src/gz cockpit-mips https://dream-alpha.github.io/Cockpit-Feed/packages/mips

# x86_64
src/gz cockpit-x86_64 https://dream-alpha.github.io/Cockpit-Feed/packages/x86_64
```

**Remember to replace the URLs with your actual package feed location!**

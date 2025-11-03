# Example Package Structure

This is an example package demonstrating the proper structure for Cockpit Enigma2 plugins.

## Package Structure

```
example-package/
├── CONTROL/
│   ├── control          # Package metadata (required)
│   ├── postinst         # Post-installation script (optional)
│   ├── prerm            # Pre-removal script (optional)
│   ├── preinst          # Pre-installation script (optional)
│   └── postrm           # Post-removal script (optional)
├── usr/
│   └── lib/
│       └── enigma2/
│           └── python/
│               └── Plugins/
│                   └── Extensions/
│                       └── CockpitExample/
│                           └── __init__.py
└── README.md
```

## Creating Your Own Package

1. Copy this directory structure
2. Rename the directory to `your-plugin-package`
3. Update the `CONTROL/control` file with your package information:
   - Package name
   - Version
   - Description
   - Dependencies
   - Architecture (all, arm, mips, x86_64)
4. Add your plugin files in the appropriate location
5. Update or remove the installation/removal scripts as needed
6. Build the package using `scripts/build-package.sh`

## Control File Fields

- **Package**: Unique package identifier (lowercase, no spaces)
- **Version**: Package version (e.g., 1.0.0)
- **Architecture**: Target architecture (all, arm, mips, x86_64)
- **Maintainer**: Package maintainer name and email
- **Section**: Package category (e.g., multimedia, utils, network)
- **Priority**: Package priority (optional, standard, extra)
- **Description**: Short and long description
- **Depends**: Comma-separated list of dependencies

## Installation Scripts

- **preinst**: Executed before package installation
- **postinst**: Executed after package installation
- **prerm**: Executed before package removal
- **postrm**: Executed after package removal

All scripts must be executable and should exit with status 0 on success.

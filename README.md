
# QuickShell Lockscreen

> [!WARNING]
> **Disclaimer:** This project is fully "vibe coded." Use it at your own risk.

A customizable lockscreen built with QuickShell.

## Getting Started

### Installation

Clone the repository and navigate into the project directory:

```bash
git clone https://github.com/look-another-one/quickshell-lockscreen
cd quickshell-lockscreen
```

### Usage

To test the lockscreen configuration:
```bash
qs -p test.qml
```

To use it for production:
```bash
qs -p shell.qml
```

## Development

This project uses Nix Flakes for a reproducible development environment.

### Enter Development Shell
```bash
nix develop
```
```
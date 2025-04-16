# Amiwine-Kinco 🍷🖥️

A handy script that automates the installation and configuration of **Kinco DTools HMI** programming software on macOS using **Wine**.

## 🚀 Features

- ✅ Automatically downloads and installs **Kinco DTools HMI**.
- 📦 Installs required Windows libraries seamlessly using **Winetricks**.
- 🎨 Creates clean, ready-to-use macOS `.app` shortcuts with embedded application icons.
- 🔗 Option to quickly regenerate shortcuts without reinstalling software (`--links-only`).

## 📋 Prerequisites

Ensure you have [Homebrew](https://brew.sh/) installed. If not, install it with:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 🛠️ Installation

Clone this repository and navigate into the directory:

```bash
git clone <your-repository-url>
cd amiwine-kinco
```

Make the script executable:

```bash
chmod +x install_kinco.sh
```

Then run:

```bash
./install_kinco.sh
```

To create macOS application shortcuts **only** (if Kinco DTools is already installed):

```bash
./install_kinco.sh --links-only
```

## 📂 Application Shortcuts

Shortcuts will be created in:

```
~/Applications/Kinco
```

You can launch Kinco DTools directly from Finder or Spotlight!

## 🔧 Troubleshooting

- If shortcuts fail to launch via Finder, ensure Wine is correctly installed and accessible by scripts:

```bash
brew install --cask wine-stable
```

- Verify permissions if shortcuts aren't launching:

```bash
chmod +x ~/Applications/Kinco/*.app/Contents/MacOS/*
```

## 📌 Notes

- The script is compatible with both Intel and Apple Silicon Macs (via Rosetta).
- Ensure macOS permissions allow running third-party scripts and apps.

## 📃 License

MIT © robertoho


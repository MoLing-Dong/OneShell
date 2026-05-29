# OneShell

OneShell is a collection of simple shell scripts for installing, configuring and managing software on Linux/WSL. All scripts support bilingual interface (English/Chinese) and include both installation and uninstallation capabilities.

## 📦 Available Scripts

### Go Language Manager

Install, update or uninstall Go Language automatically from official website:

```bash
curl -fsSL https://raw.githubusercontent.com/MoLing-Dong/OneShell/master/golang_manager.sh | sudo bash
```

**Features:**
- Version selection: latest, choose from list, or enter manually
- Automatically fetches latest version from go.dev
- Detects system architecture (amd64/arm64/armv6l/386)
- Supports installation to `/usr/local` (root) or `~/.local` (user)
- Auto-configures environment variables in `.bashrc`, `.zshrc`, `.profile`
- Complete uninstall option, can optionally remove GOPATH
- English/Chinese bilingual interface

---

### Java JDK Manager

Install or uninstall Java JDK from Adoptium (Eclipse Temurin):

```bash
curl -fsSL https://raw.githubusercontent.com/MoLing-Dong/OneShell/master/jdk_manager.sh | sudo bash
```

**Features:**
- Uses Adoptium (Eclipse Temurin) - free, open source, LTS support
- Version selection: latest LTS, choose from list (8/11/17/21), or enter manually
- Detects system architecture (x64/aarch64/arm/s390x/ppc64le)
- Supports installation to `/usr/local` (root) or `~/.local` (user)
- Auto-configures `JAVA_HOME` and `PATH`
- Complete uninstall capability
- English/Chinese bilingual interface

---

### Apache Maven Manager

Install or uninstall Maven from official Apache archive:

```bash
curl -fsSL https://raw.githubusercontent.com/MoLing-Dong/OneShell/master/maven_manager.sh | sudo bash
```

**Features:**
- Version selection: latest, choose from list, or enter manually
- Automatically fetches latest version from maven.apache.org
- Downloads from official Apache archive
- Checks for Java installation (does not install Java automatically)
- Auto-configures environment variables
- Complete uninstall capability
- English/Chinese bilingual interface

> **Note:** You need to install Java (JDK) manually before installing Maven.

---

### OpenSSH Server Setup (for WSL)

Install, configure or uninstall OpenSSH Server on WSL (Debian/Ubuntu):

```bash
curl -fsSL https://raw.githubusercontent.com/MoLing-Dong/OneShell/master/ssh_setup.sh | sudo bash
```

**Features:**
- Designed specifically for WSL (Windows Subsystem for Linux)
- Enables root login and password authentication
- Applies performance optimizations (UseDNS no, GSSAPIAuthentication no)
- Auto-generates random password if root has no password
- Configures keep-alive settings
- Complete uninstall capability
- English/Chinese bilingual interface

After installation, you can SSH directly into your WSL from Windows.

---

## ShellCrash

Install ShellCrash (simple installer):

```bash
wget -O install_shellcrash.sh https://raw.githubusercontent.com/MoLing-Dong/OneShell/master/shellcrash.sh && bash install_shellcrash.sh
```

---

## Node.js

We recommend using [fnm](https://github.com/Schniz/fnm) to manage Node.js versions:

```bash
curl -fsSL https://fnm.vercel.app/install | bash
```

---

## Python

We recommend using [venv](https://docs.python.org/3/library/venv.html) or [uv](https://github.com/astral-sh/uv) to manage Python environments.

---

## 📝 Features

- **Bilingual** - English and Chinese interface
- **Interactive** - Menu-driven, easy to use
- **Safe** - Automatic backups before modifying configuration
- **Clean** - Temporary files cleaned automatically
- **Complete** - Both installation and uninstallation

## 📄 License

MIT

# 🚀 TorGuard V2Ray OpenWRT App (tgv2ray)

<p align="center">
  <img src="https://img.shields.io/badge/OpenWRT-00B5E2?style=for-the-badge&logo=openwrt&logoColor=white" alt="OpenWRT">
  <img src="https://img.shields.io/badge/V2Ray-000000?style=for-the-badge&logo=v&logoColor=white" alt="V2Ray">
  <img src="https://img.shields.io/badge/Sing--box-FF6B6B?style=for-the-badge&logo=box&logoColor=white" alt="Sing-box">
</p>

A lightweight LuCI-based OpenWRT application for managing V2Ray/VLESS/Trojan/Shadowsocks connections via TorGuard's subscription service, powered by Sing-box.

## ✨ Features

- 🌐 **Server Subscription Management**: Automatically fetch and manage server lists from TorGuard API
- 🔐 **Multiple Protocol Support**: VLESS, VMess, Trojan, and Shadowsocks protocols
- 🎭 **Dual Mode Operation**:
  - **Proxy Mode**: SOCKS5 (port 1080) and HTTP (port 8080) proxy
  - **VPN Mode**: Full tunnel using TUN interface for system-wide VPN
- 🛠️ **Custom Server Import**: Add your own V2Ray/VLESS/Trojan/SS servers
- 💻 **LuCI Web Interface**: User-friendly web UI integrated with OpenWRT
- 🔄 **Automatic Sing-box Management**: Auto-download and update Sing-box binary

## 📋 Table of Contents

- [Installation](#-installation)
- [Building from Source](#-building-from-source)
- [Usage Guide](#-usage-guide)
- [File Structure](#-file-structure)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## 📦 Installation

### Prerequisites

- OpenWRT router with LuCI installed
- Required packages: `curl`, `jq`, `bash`, `coreutils-base64`

### Installing Release IPK

1. **Download the latest release IPK**:
   ```bash
   wget https://github.com/yourusername/tgv2ray/releases/latest/download/tgv2ray_1.0.0-2_all.ipk
   ```

2. **Install dependencies**:
   ```bash
   opkg update
   opkg install curl jq bash coreutils-base64
   ```

3. **Install the IPK package**:
   ```bash
   opkg install tgv2ray_1.0.0-2_all.ipk
   ```

4. **Access the web interface**:
   - Navigate to `http://your-router-ip/cgi-bin/luci`
   - Go to **Services → TorGuard V2Ray**

## 🔨 Building from Source

### Using OpenWRT SDK

1. **Set up OpenWRT SDK**:
   ```bash
   # Download and extract OpenWRT SDK for your platform
   wget https://downloads.openwrt.org/releases/23.05.0/targets/YOUR_TARGET/openwrt-sdk-*.tar.xz
   tar -xf openwrt-sdk-*.tar.xz
   cd openwrt-sdk-*/
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/tgv2ray.git package/tgv2ray
   ```

3. **Update feeds**:
   ```bash
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

4. **Configure and build**:
   ```bash
   make menuconfig
   # Navigate to: LuCI → 7. TorGuard → tgv2ray (select as <M>)
   make package/tgv2ray/compile V=s
   ```

5. **Find the built package**:
   ```bash
   ls bin/packages/*/luci/tgv2ray_*.ipk
   ```

## 📖 Usage Guide

### 🔑 Initial Setup

1. **Enable the service**:
   - Check the "Enable V2Ray" checkbox
   
2. **Add your TorGuard UUID**:
   - Enter your TorGuard UUID in the UUID field
   - Click the **🔄** button to fetch available servers

### 🌐 Connection Modes

#### Proxy Mode
Perfect for applications that support proxy configuration:
- **SOCKS5 Proxy**: `192.168.1.1:1080`
- **HTTP Proxy**: `192.168.1.1:8080`
- No system-wide routing changes
- Ideal for browsers and specific applications

#### VPN Mode
Routes all traffic through the VPN tunnel:
- Creates a TUN interface (`tun0`)
- System-wide VPN protection
- Automatic routing configuration
- All device traffic secured

### 🎮 Service Control

#### Via Web Interface
- **Start**: Click the "▶️ Start" button
- **Stop**: Click the "⏹️ Stop" button
- **Status**: View connection status in real-time

#### Via Command Line
```bash
# Start the service
/etc/init.d/tgv2ray start

# Stop the service
/etc/init.d/tgv2ray stop

# Restart the service
/etc/init.d/tgv2ray restart

# Check status
/etc/init.d/tgv2ray status
```

### 📥 Server Management

#### Update Server List
```bash
# Via CLI
/usr/bin/tgv2ray-subscription

# Or click "Update Server List" in web UI
```

#### Custom Server Import

1. Click on "Custom Server Import" section
2. Paste your V2Ray/VLESS/Trojan/SS URL:
   ```
   vless://uuid@server.com:443?encryption=none&security=tls&sni=server.com#Custom-Server
   trojan://password@server.com:443?sni=server.com#Trojan-Server
   ss://base64string@server.com:8388#Shadowsocks-Server
   ```
3. Click "Import Server"

## 📁 File Structure

```
tgv2ray/
├── 📄 Makefile                     # OpenWRT package makefile
├── 📄 README.md                    # This file
└── 📁 files/
    ├── 📁 etc/
    │   ├── 📁 config/
    │   │   └── 📄 tgv2ray         # UCI configuration
    │   ├── 📁 init.d/
    │   │   └── 🔧 tgv2ray         # Init script
    │   ├── 📁 tgv2ray/
    │   │   ├── 📄 config.json.template
    │   │   └── 📄 v2ray_default.conf
    │   └── 📁 uci-defaults/
    │       └── 🔧 tgv2ray_def     # Default settings
    ├── 📁 htdocs/
    │   └── 📁 luci-static/
    │       └── 📁 resources/
    │           └── 📁 view/
    │               └── 📁 tgv2ray/
    │                   └── 🌐 main.js
    └── 📁 usr/
        ├── 📁 bin/
        │   ├── 🔧 tgv2ray-config-gen      # Config generator
        │   └── 🔧 tgv2ray-subscription    # Subscription updater
        └── 📁 lib/
            └── 📁 lua/
                └── 📁 luci/
                    ├── 📁 controller/
                    │   └── 📄 tgv2ray.lua
                    └── 📁 model/
                        └── 📁 cbi/
                            └── 📄 tgv2ray.lua
```

## ⚙️ Configuration

### UCI Configuration Options

```bash
# View current configuration
uci show tgv2ray

# Common settings
uci set tgv2ray.settings.enabled='1'        # Enable/disable service
uci set tgv2ray.settings.mode='vpn'         # Mode: 'vpn' or 'proxy'
uci set tgv2ray.settings.uuid='YOUR-UUID'   # TorGuard UUID
uci set tgv2ray.settings.server='US-LA'     # Selected server
uci set tgv2ray.settings.log_level='info'   # Log level

# Apply changes
uci commit tgv2ray
/etc/init.d/tgv2ray restart
```

### Configuration Files

- **UCI Config**: `/etc/config/tgv2ray`
- **Sing-box Config**: `/etc/tgv2ray/config.json` (auto-generated)
- **Server List**: `/etc/tgv2ray/servers.json`
- **Logs**: `/var/log/tgv2ray.log`

## 🔧 Troubleshooting

### Check Service Status
```bash
# View service logs
logread | grep tgv2ray | tail -20

# Check if sing-box is running
ps | grep sing-box

# View generated configuration
cat /etc/tgv2ray/config.json
```

### Common Issues

#### 🚫 Cannot Connect in VPN Mode
- Ensure firewall rules are properly configured
- Check DNS settings: `nslookup google.com`
- Verify TUN interface: `ip addr show tun0`

#### 🚫 No Servers Available
- Check UUID is correct
- Verify internet connectivity
- Update server list manually

#### 🚫 Service Won't Start
```bash
# Check for errors
/etc/init.d/tgv2ray start
logread | grep tgv2ray

# Verify sing-box binary exists
ls -la /usr/bin/sing-box
```

### Reset Configuration
```bash
# Reset to defaults
rm -f /etc/config/tgv2ray
/etc/init.d/tgv2ray restart
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Sing-box](https://github.com/SagerNet/sing-box) - The powerful proxy platform
- [OpenWRT](https://openwrt.org/) - The Linux operating system for embedded devices
- [TorGuard](https://torguard.net/) - VPN service provider

---

<p align="center">
  Made with ❤️ for OpenWRT users
</p>
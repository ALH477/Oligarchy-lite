# Oligarchy-Lite NixOS 

![](https://github.com/ALH477/Oligarchy-lite/blob/main/modules/assets/1766653327186.jpg)

**Ultra-minimal, declarative NixOS distribution optimized for single/dual-core legacy hardware, virtual machines, ARM boards (aarch64), and emerging RISC-V systems.**

Copyright © 2025 DeMoD LLC  
Licensed under the **BSD 3-Clause License** (see [LICENSE](#license) below).

Oligarchy NixOS Lite is a highly stripped-down, reproducible NixOS configuration designed to:

- Revive forgotten x86_64 hardware (Core 2 Duo, Pentium 4 64-bit era, etc.)
- Run efficiently as a lightweight guest in VMs (QEMU/KVM, VirtualBox, Proxmox, etc.)
- Provide a clean, minimal base for modern ARM64 single-board computers (Raspberry Pi 4/5, Pine64, Orange Pi, etc.)
- Offer an experimental starting point for RISC-V development boards (VisionFive 2, Milk-V Mars/Pioneer, LicheeRV, SiFive, etc.)

The system emphasizes **zero bloat**, **offline-first operation**, and **toddler-simple usability** via a colorful console menu.

## Features

### Core Design Principles

- Idle RAM consumption: ~50–150 MB (console mode)
- Everything is optional and disabled by default
- Pure Nix flakes — fully declarative and reproducible
- Architecture-aware configuration (x86_64, aarch64, riscv64)
- Manual/lazy networking by default (wpa_supplicant, NetworkManager optional)
- Toddler-friendly console launcher with large ASCII art commands

### Available Build Profiles

| Profile              | System         | Primary Use Case                          | Idle RAM (approx) | Graphical / Gaming | Open WebUI / Ollama |
|----------------------|----------------|-------------------------------------------|-------------------|---------------------|----------------------|
| `minimal-x86_64`     | x86_64-linux   | Legacy PCs, virtual machines, servers     | 50–120 MB         | No                  | No                   |
| `gaming-x86_64`      | x86_64-linux   | Retro & open-source gaming terminal       | 150–350 MB        | Yes (X11)           | Optional             |
| `minimal-aarch64`    | aarch64-linux  | Raspberry Pi, Pine64, Ampere Altra, etc.  | 60–150 MB         | No                  | No                   |
| `gaming-aarch64`     | aarch64-linux  | ARM-based gaming / creative workstation   | 180–400 MB        | Yes (native)        | Optional             |
| `minimal-riscv64`    | riscv64-linux  | VisionFive 2, Milk-V, LicheeRV, etc.      | 70–180 MB         | No                  | Experimental / No    |

### Included Optional Modules

- **Kernel optimizations** — Zen/latest kernel, performance governor, low-latency sysctl
- **Networking** — manual (default), wpa_supplicant auto, NetworkManager
- **Audio** — ALSA (default), JACK (pro low-latency), PipeWire
- **Bluetooth** — basic console support (`bluetoothctl`)
- **Firewall** — disabled (default), basic (established/related), strict (drop-all)
- **Web server** — none (default), nginx, caddy (auto-HTTPS), python http.server
- **Python environment** — enhanced with requests, flask, pyserial, pyusb, zeroconf, etc.
- **Open WebUI/Alpaca/OTERM + Ollama** — self-hosted LLM chat interface (CPU mode default) and containerized
- **Gaming terminal** (x86_64 & aarch64 only) — OpenGL welcome screen, X11 + xterm + 16+ open-source games

## Hardware Compatibility & Requirements

| Component       | Absolute Minimum (console) | Recommended (gaming / Open WebUI) |
|-----------------|-----------------------------|------------------------------------|
| CPU             | Single-core ≥ 1.5 GHz       | Dual-core ≥ 2.0 GHz                |
| RAM             | 512 MB (tight)              | 2 GB or more                       |
| Storage         | 4 GB                        | 16 GB+ (models, games, data)       |
| GPU (gaming)    | Not required                | Basic OpenGL 1.1+ support          |

**RISC-V note**: Many packages still fail to build or cross-compile cleanly in late 2025. Use the minimal profile only; gaming and Open WebUI are not reliably supported yet.

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/your-org/oligarchy-nixos-lite.git
cd oligarchy-nixos-lite
```

### 2. Build and switch to your desired profile

```bash
# Minimal console (recommended starting point)
nixos-rebuild switch --flake .#minimal-x86_64

# Full gaming terminal
nixos-rebuild switch --flake .#gaming-x86_64

# ARM64 (e.g. Raspberry Pi 5)
nixos-rebuild switch --flake .#minimal-aarch64

# RISC-V minimal (VisionFive 2, Milk-V, etc.)
nixos-rebuild switch --flake .#minimal-riscv64
```

### 3. Cross-compile RISC-V image from x86_64 / aarch64 host (recommended)

Enable QEMU user-mode emulation once on your build host:

```nix
# /etc/nixos/configuration.nix or equivalent
boot.binfmt.emulatedSystems = [ "riscv64-linux" ];
```

Then generate an SD-card image:

```bash
nix build .#nixosConfigurations.minimal-riscv64.config.system.build.sdImage

# Flash to SD card (adjust device!)
zstdcat result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M status=progress oflag=sync conv=fsync
sync
```

## First Boot Experience

- The system auto-logins to console as user
- A colorful ASCII-art menu appears automatically
- Available commands (type and press Enter):

  ```
  info     → htop system stats
  edit     → nvim text editor
  files    → ranger file browser
  scan     → list nearby WiFi networks
  wifi     → connect to WiFi (interactive)
  disconnect → stop WiFi connection
  reboot   → restart system
  off      → power off
  ```

Gaming profile only:

- Boots into OpenGL welcome screen (ESC to continue)
- Full-screen green terminal with large game launcher menu
- Windows-key hotkeys + typed commands launch games instantly

## Enabling Optional Features

Edit the target configuration file (e.g. `configuration-base.nix` or a host-specific override) and set module options:

```nix
# Example: enable Open WebUI + Python networking + basic firewall
custom.openwebui.enable     = true;
custom.python.enable        = true;
custom.python.networking    = true;
custom.firewall.mode        = "basic";
custom.firewall.extraAllowedTCPPorts = [ 8080 5000 ];  # WebUI + Flask
```

Rebuild:

```bash
nixos-rebuild switch --flake .#minimal-x86_64
```

## Included Open-Source Games (gaming profiles only)

All titles use fully free content:

- Doom engine (prboom-plus + freedoom)
- Zandronum (multiplayer Doom source port)
- OpenArena (Quake III-style arena shooter)
- Warfork (fast-paced arena FPS)
- vkQuake (Quake 1 engine)
- dhewm3 (Doom 3 engine)
- SuperTux (classic platformer)
- Minetest (voxel sandbox)
- Battle for Wesnoth (turn-based fantasy strategy)
- OpenTTD (transport tycoon simulation)
- Hedgewars (Worms-like artillery)
- Frozen-Bubble (color-matching puzzle)
- Teeworlds (cute 2D multiplayer shooter)
- Neverball (tilt-controlled marble puzzle)
- Armagetron Advanced (Tron light cycles)
- Freeciv (open-source Civilization-like)

## License

Copyright © 2025 DeMoD LLC

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Contributing

Contributions are welcome:

- Board-specific hardware modules (Raspberry Pi, VisionFive 2, etc.)
- Additional lightweight console tools
- More Python networking / automation examples
- Workarounds for riscv64 package build failures
- Improved cross-compilation documentation

Please open issues or pull requests at the project repository.

## Acknowledgments

Built with NixOS, flakes, home-manager, and the amazing open-source gaming, AI, and embedded communities.

Revive old hardware, experiment on RISC-V, or run featherweight systems — enjoy!  
— DeMoD LLC, December 2025

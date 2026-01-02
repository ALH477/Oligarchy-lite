# Oligarchy-Lite NixOS: The Prospector’s OS

![Oligarchy-Lite Header](https://github.com/ALH477/Oligarchy-lite/blob/main/modules/assets/1766653327186.jpg)

[![License: BSD 3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Docker Pulls: alh477/dcf-rs](https://img.shields.io/docker/pulls/alh477/dcf-rs.svg?logo=docker&style=flat-square)](https://hub.docker.com/r/alh477/dcf-rs)
[![Platform: x86_64 | aarch64 | riscv64](https://img.shields.io/badge/platform-x86__64%20%7C%20aarch64%20%7C%20riscv64-lightgrey)](./flake.nix)

Ultra-minimal, declarative NixOS distribution optimized for single/dual-core iron, virtual void-craft, ARM boards (aarch64), and emerging RISC-V holdfasts.

## The Guild License and The Ancestors' Due

Copyright © 2025–2026 DeMoD LLC

Vox-Caster Warning: All Warhammer 40,000 lore, Kin slang, and concepts are © Games Workshop Limited 2000–2026. This project is not affiliated with Games Workshop. It is a transformative fan expression—a labor of the Great Guilds.

Oligarchy NixOS Lite is a stripped-down, reproducible configuration forged to:

* [cite_start]**Revive Ancestral Iron**: Salvage x86_64 hardware from the Core 2 Duo and Pentium 4 eras[cite: 1].
* [cite_start]**Void-Craft Ready**: Run as a featherweight guest in VMs like QEMU/KVM and Proxmox[cite: 1].
* [cite_start]**Kin-Sized SBCs**: A clean base for Raspberry Pi, Pine64, and Orange Pi holdfasts[cite: 1].
* [cite_start]**Experimental Prospecting**: A starting point for RISC-V development (VisionFive 2, Milk-V)[cite: 1].

[cite_start]The system emphasizes zero bloat, offline-first operation, and Kin-simple usability via a high-contrast console menu[cite: 1].

---

## Features of the Hold

### Core Design Principles
* [cite_start]**Rationing RAM**: Idle consumption stays between ~50–150 MB in console mode[cite: 1].
* [cite_start]**Waste Not**: Everything is optional and disabled by default—no excess mass[cite: 1].
* [cite_start]**Forged in Code**: Pure Nix flakes ensure your system is fully declarative and reproducible[cite: 1].
* [cite_start]**Multi-Kindred Support**: Architecture-aware for x86_64, aarch64, and riscv64[cite: 1].
* [cite_start]**Manual Data-Links**: Lazy networking by default (wpa_supplicant)[cite: 1].
* [cite_start]**Prospector Launcher**: A simplified console menu with large ASCII art for tired eyes[cite: 1].

### Build Profiles (The Kindred List)
| Profile | System | Primary Use Case | Idle RAM |
| :--- | :--- | :--- | :--- |
| `minimal-x86_64` | x86_64-linux | Legacy Iron, void-servers | [cite_start]50–120 MB [cite: 1] |
| `gaming-x86_64` | x86_64-linux | Retro Gaming Terminal | [cite_start]150–350 MB [cite: 1] |
| `minimal-aarch64` | aarch64-linux | Raspberry Pi & SBC Holdfasts | [cite_start]60–150 MB [cite: 1] |
| `minimal-riscv64` | riscv64-linux | VisionFive 2, Milk-V (Experimental) | [cite_start]70–180 MB [cite: 1] |

---

## Hardware Requirements: Is Your Iron Worthy?

| Component | Absolute Minimum (Console) | Recommended (Gaming / AI) |
| :--- | :--- | :--- |
| **CPU** | [cite_start]Single-core ≥ 1.5 GHz [cite: 1] | [cite_start]Dual-core ≥ 2.0 GHz [cite: 1] |
| **RAM** | [cite_start]512 MB (Tight Ration) [cite: 1] | [cite_start]2 GB or more [cite: 1] |
| **Storage** | [cite_start]4 GB [cite: 1] | [cite_start]16 GB+ (For Models/Games) [cite: 1] |

[cite_start]**RISC-V Warning**: Many STCs (packages) still fail to compile in late 2025. Stick to the minimal profile for these experimental holds[cite: 1].

---

## Quick Start: Forging Your System

### 1. Acquire the STC
```bash
git clone [https://github.com/your-org/oligarchy-nixos-lite.git](https://github.com/your-org/oligarchy-nixos-lite.git)
cd oligarchy-nixos-lite

```

### 2. Ignite the Forge

```bash
# Minimal Console (For the efficient Prospector)
nixos-rebuild switch --flake .#minimal-x86_64

# Full Gaming Terminal (For the off-duty Hearthkyn)
nixos-rebuild switch --flake .#gaming-x86_64

# RISC-V SD-Image Generation (For the bold)
nix build .#nixosConfigurations.minimal-riscv64.config.system.build.sdImage

```

---

## The First Boot: The Kin Menu

The system auto-logins to the console. Use these commands to manage your holdfast:

* 
`info`: System Vitals (htop stats).


* 
`edit`: Loom-Scripting (nvim editor).


* 
`files`: Cargo Inventory (ranger browser).


* 
`scan`: Vox-Scanning (WiFi search).


* 
`wifi`: Link-Up (Connect to WiFi).


* 
`reboot`: Cycle the Hold (Restart).


* 
`off`: Seal the Vault (Shutdown).



---

## Modifying the Hold (Optional Modules)

Edit `configuration-base.nix` to enable Guild-specific tech:

```nix
# Example: Enable the DCF Community Node & AI Hold
custom.dcfCommunityNode.enable = true;  # Contribute to the Mesh
services.ollamaAgentic.enable  = false; # Local Cogitator AI (Keep it secret)
custom.networking.mode         = "manual"; # Kin handle their own links

```

### Included Optional Tech:

* 
**Kernel Forge**: Zen/latest kernels with performance governors.


* **DCF Node**: Integrate into the DeMoD Distributed Computing Framework.
* 
**Audio Holds**: ALSA (standard), PipeWire, or pro-grade low-latency.


* 
**Gaming STCs**: Includes freedoom, vkQuake, OpenArena, and SuperTux.



---

## Contributing to the Great Hold

Contributions are as precious as refined ore! We seek:

* Hardware modules for new SBC Kindreds.


* Lightweight console tools for the long-haul.


* Workarounds for the finicky RISC-V logic-cores.



Ancestors are watching. Keep your iron clean and your code optimized. — DeMoD LLC, The Votann Core, 2026.

---

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](https://www.google.com/search?q=./LICENSE) file for details.

```

---

### 2. LICENSE

```text
BSD 3-Clause License

Copyright (c) 2025-2026, DeMoD LLC
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

```

# **Oligarchy-Lite NixOS**
### *The Prospector’s OS*

![Oligarchy-Lite Header](https://github.com/ALH477/Oligarchy-lite/blob/main/modules/assets/1766653327186.jpg)

[![License: BSD 3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Docker Pulls: alh477/dcf-rs](https://img.shields.io/docker/pulls/alh477/dcf-rs.svg?logo=docker&style=flat-square)](https://hub.docker.com/r/alh477/dcf-rs)
[![Platform: x86_64 | aarch64 | riscv64](https://img.shields.io/badge/platform-x86__64%20%7C%20aarch64%20%7C%20riscv64-lightgrey)](./flake.nix)

**Oligarchy-Lite** is an ultra-minimal, declarative NixOS distribution forged for:

- Ancestral x86_64 iron  
- Lightweight virtual machines  
- ARM single-board computers  
- Experimental RISC-V holdfasts  

Built to run lean, offline-first, and reproducibly—without bloat, ceremony, or wasted cycles.

---

## The Guild License & the Ancestors’ Due

**Copyright © 2025–2026 DeMoD LLC**

**Vox-Caster Warning**  
All Warhammer 40,000 lore, Kin slang, and thematic references are © Games Workshop Limited (2000–2026).  
This project is **not affiliated** with Games Workshop. It is a **transformative fan work**—a labor of the Great Guilds.

---

## What This OS Is Forged To Do

Oligarchy-Lite is a stripped-down, reproducible NixOS configuration designed to:

- **Revive Ancestral Iron**  
  Salvage and repurpose legacy x86_64 hardware (Pentium 4, Core 2 Duo era).

- **Void-Craft Ready**  
  Operate as a featherweight guest under QEMU/KVM, Proxmox, and similar hypervisors.

- **Kin-Sized Holdfasts**  
  Provide a clean, stable base for Raspberry Pi, Pine64, Orange Pi, and related SBCs.

- **Experimental Prospecting**  
  Serve as a foundation for RISC-V systems such as VisionFive 2 and Milk-V.

**Design focus:** zero bloat, offline-first operation, and Kin-simple usability via a high-contrast console launcher.

---

## Features of the Hold

### Core Design Principles

- **Rationed RAM**  
  Approximately 50–150 MB idle usage in console mode.

- **Waste Nothing**  
  All services are optional and disabled by default.

- **Forged in Code**  
  Fully declarative Nix flakes—reproducible by design.

- **Multi-Kindred Support**  
  Architecture-aware configurations for x86_64, aarch64, and riscv64.

- **Manual Data-Links**  
  Minimal networking by default using `wpa_supplicant`.

- **Prospector Launcher**  
  High-contrast console menu with large ASCII art, suitable for aging panels and long sessions.

---

## Mesh Networking — DeMoD DCF Integration (Optional)

Oligarchy-Lite includes first-class, optional support for the  
**DeMoD Distributed Computing Framework (DCF)**.

When enabled, a system may operate as a voluntary node in the global **HydraMesh**, contributing bandwidth and compute capacity using the custom-built `dcf-rs` engine.

This integration is fully declarative and disabled by default.

---

### The DCF Community Node

The DCF module deploys a hardened OCI container running:

```

alh477/dcf-rs

```

The node is engineered for high-frequency, low-latency workloads, including real-time gaming infrastructure and distributed computation.

---

### Hardened Performance Engineering

To maintain a sustained **125 Hz processing loop**, even on legacy hardware or low-tier cloud instances, the module applies several “Hardened Hold” optimizations:

- **Logic-Core Pinning**  
  The container is bound to Core 0 (`--cpuset-cpus=0`) to reduce cache thrashing and scheduling overhead.

- **Real-Time Priority**  
  The node is granted `SYS_NICE` capabilities and assigned an `rtprio` of 99, allowing it to preempt standard background tasks.

- **Memory Sovereignty**  
  Through `IPC_LOCK` and an unlimited `memlock` setting, the mesh logic is protected from swap eviction.

- **Raw Vox-Link**  
  The container uses `NET_RAW` to bypass standard networking overhead and handle mesh packets directly.

---

### Declarative Mesh Control

- **Dynamic Configuration Forging**  
  `dcf_config.toml` is generated during system activation, injecting the unique node ID into a read-only runtime environment.

- **Automated Perimeter Defense**  
  When enabled, the firewall is adjusted to allow:
  - UDP 7777 for mesh data traffic  
  - TCP 50051 for gRPC control channels  

- **Self-Healing Logic**  
  A dedicated systemd unit monitors the DCF container and enforces a 10-second restart policy to ensure persistent connectivity.

---

### Deployment

To join the mesh, register your node at:

```

[https://dcf.demod.ltd/register](https://dcf.demod.ltd/register)

````

(Work in progress)

Once registered, enable the module and insert your assigned node ID into `configuration-base.nix`.

---

## Build Profiles (The Kindred List)

| Profile              | Architecture   | Primary Use                         | Idle RAM    |
|----------------------|----------------|-------------------------------------|-------------|
| `minimal-x86_64`     | x86_64-linux   | Legacy iron, servers                | ~50–120 MB  |
| `gaming-x86_64`      | x86_64-linux   | Retro gaming terminal               | ~150–350 MB |
| `minimal-aarch64`    | aarch64-linux  | SBCs and ARM boards                 | ~60–150 MB  |
| `minimal-riscv64`    | riscv64-linux  | VisionFive 2, Milk-V (experimental) | ~70–180 MB  |

---

## Hardware Requirements

### Is Your Iron Worthy?

| Component   | Absolute Minimum      | Recommended             |
|------------|-----------------------|-------------------------|
| **CPU**     | Single-core ≥ 1.5 GHz | Dual-core ≥ 2.0 GHz     |
| **RAM**     | 512 MB (tight ration) | 2 GB or more            |
| **Storage** | 4 GB                  | 16 GB+ (games / models) |

**RISC-V Warning**  
As of late 2025, many packages still fail to compile on RISC-V.  
Stick to the **minimal** profile when prospecting experimental silicon.

---

## Quick Start: Forging Your System

### 1. Acquire the STC

```bash
git clone https://github.com/ALH477/Oligarchy-lite.git
cd Oligarchy-lite
````

### 2. Ignite the Forge

```bash
# Minimal console (efficient Prospector)
nixos-rebuild switch --flake .#minimal-x86_64

# Gaming terminal (off-duty Hearthkyn)
nixos-rebuild switch --flake .#gaming-x86_64

# RISC-V SD image (bold prospectors only)
nix build .#nixosConfigurations.minimal-riscv64.config.system.build.sdImage
```

---

## First Boot: The Kin Menu

The system auto-logins to the console. Available commands:

* `info` – System vitals (htop)
* `edit` – Loom-scripting (Neovim)
* `files` – Cargo inventory (ranger)
* `scan` – Vox-scan for Wi-Fi
* `wifi` – Establish a data-link
* `reboot` – Cycle the hold
* `off` – Seal the vault

---

## Modifying the Hold (Optional Modules)

Edit `configuration-base.nix` to enable Guild-specific technologies:

```nix
custom.dcfCommunityNode.enable = true;    # Join the Mesh
services.ollamaAgentic.enable  = false;   # Local cogitator AI
custom.networking.mode         = "manual"; # Kin manage their own links
```

### Included Optional Tech

* **Kernel Forge**
  Zen or latest kernels with tuned governors

* **DCF Node**
  DeMoD Distributed Computing Framework integration

* **Audio Holds**
  ALSA, PipeWire, or low-latency professional audio

* **Gaming STCs**
  freedoom, vkQuake, OpenArena, SuperTux

---

## Contributing to the Great Hold

Refined ore is always welcome. Contributions sought include:

* New SBC and architecture modules
* Lightweight console tooling
* RISC-V fixes and workarounds

Ancestors are watching. Keep your iron clean and your code optimized.
— **DeMoD LLC, The Votann Core (2026)**

---

## License

This project is licensed under the **BSD 3-Clause License**.
See the `LICENSE` file for full details.

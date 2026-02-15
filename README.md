# nixos-homelab

Multi-node NixOS homelab managed with Colmena, featuring a remote build server, Tailscale gateway, gaming VM, and reproducible installer ISO.

---

## What It Does

- Manages multiple NixOS hosts declaratively using Colmena.
- Provisions disk layouts via `disko` (GPT + LVM).
- Deploys a distributed Nix builder with binary cache (`nix-serve`).
- Enables remote builds across nodes with trusted substituters.
- Configures a Tailscale NAT gateway with route advertisement.
- Deploys a SteamOS-based gaming machine using Jovian + Chaotic overlays.
- Generates a reproducible installer ISO via `nixos-generators`.
- Supports remote deployment using `nixos-anywhere`.

This repository defines a fully reproducible, multi-host infrastructure topology.

---

## Topology

```
                   ┌──────────────────────┐
                   │      Colmena         │
                   │  (Deployment Host)   │
                   └─────────┬────────────┘
                             │ SSH
         ┌───────────────────┼────────────────────┐
         ▼                   ▼                    ▼
   ┌────────────┐      ┌──────────────┐      ┌─────────────┐
   │  Gateway   │      │  Gaming VM   │      │  Nix Builder│
   │ Tailscale  │      │  SteamOS     │      │  Binary Cache│
   └─────┬──────┘      └──────┬───────┘      └──────┬──────┘
         │                     │                     │
         │ NAT + Routing       │ Sunshine + Steam    │ nix-serve
         │                     │ GPU tuning          │ distributed builds
         │
         ▼
   192.168.0.0/24
```

---

## Nodes

### Gateway

- Enables IPv4 + IPv6 forwarding.
- Configures NixOS NAT between `tailscale0` and LAN.
- Advertises routes via Tailscale.
- Runs OpenSSH with remote management.
- Built via disko-managed GPT + LVM layout.

Purpose: secure remote access and subnet routing.

---

### Gaming Host

- Uses `chaotic` + `Jovian-NixOS` modules for SteamOS.
- Enables Sunshine for remote streaming.
- Configures Intel Arc GPU stack (VAAPI, Vulkan, media drivers).
- Disables sleep and CPU power throttling for stability.
- Applies kernel tuning (CachyOS kernel, scheduler tweaks).
- Runs Steam in gamescope Wayland session.

Purpose: dedicated SteamOS-style gaming appliance.

---

### Builder

- Dedicated Nix remote builder node.
- Enables distributed builds (`buildOnTarget = true`).
- Exposes binary cache via `nix-serve` (port 5000).
- Supports `kvm`, `big-parallel`, and `nixos-test` features.
- Configured as trusted substituter for other nodes.
- Supports 32-bit builds via `extra-platforms`.

Purpose: offload heavy builds and accelerate deployments.

---

## Disk Provisioning

Uses `disko` to declaratively define:

- GPT partition table
- BIOS boot partition (EF02)
- EFI system partition (vfat)
- LVM volume group
- Ext4 root filesystem

All hosts share a consistent, reproducible disk layout.

---

## Installer ISO

Generates a minimal NixOS installation ISO:

```bash
nix build .#installer-iso
```

Includes:

- SSH enabled
- Root password preset (for lab use)
- Nix flakes + experimental features
- Serial console configuration

This allows automated remote installation via `nixos-anywhere`.

---

## Deployment

Colmena-managed deployment:

```bash
colmena apply
```

Gateway initial bootstrap:

```bash
just deploy
```

Remote builder and distributed builds are configured automatically.

---

## Tech Stack

- NixOS
- Nix flakes
- Colmena
- disko
- nixos-anywhere
- nixos-generators
- nix-serve
- Tailscale
- Jovian-NixOS
- Chaotic overlays
- SteamOS stack
- Sunshine
- LVM
- GPT

---

## Why This Is Interesting

This repository demonstrates:

- Multi-node NixOS infrastructure managed declaratively.
- Remote build acceleration with distributed Nix builders.
- Self-hosted binary cache topology.
- Reproducible disk provisioning with disko.
- Gaming appliance configuration using upstream SteamOS modules.
- End-to-end deployment via ISO → SSH → Colmena orchestration.

It models real-world infrastructure concerns — build scaling, routing, reproducibility, and host specialization — within a fully declarative NixOS environment.

---

## Development Shell

```bash
nix develop
```

Includes:

- Colmena CLI
- `just` task runner

All infrastructure definitions are flake-pinned and reproducible.

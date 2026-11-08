---
tags:
  - flatpak
  - applications
description: Commands for managing Flatpak apps and runtimes
---

# Flatpak

## update flatpak

Update all installed Flatpak apps and runtimes, and remove runtimes that are no longer used. Run this after every NVIDIA driver upgrade. Flatpak apps need a `GL.nvidia-*` runtime that exactly matches the host driver version. Without it, they fall back to the iGPU or software rendering and get laggy. Asks for confirmation and may show new app permissions before applying.

```bash
flatpak update
```

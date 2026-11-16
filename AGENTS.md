# Dotfiles conventions

- Keep configuration portable across different VMs and PCs. Prefer `~/...` for paths under the user's home directory rather than hard-coded absolute paths such as `/home/mark/...`.
- Verify that the relevant application or configuration field supports tilde expansion. Where it does not, use a supported home-directory variable or another portable mechanism instead of hard-coding a username or home directory.

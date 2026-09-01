# Scoop bucket for shoon projects

This is the official project-owned Scoop bucket for Windows releases from
[`@shoon`](https://github.com/shoon).

Add the bucket once:

```powershell
scoop bucket add shoon https://github.com/shoon/scoop-bucket
```

Then install either application:

```powershell
scoop install shoon/fv-ssh-unlock
scoop install shoon/audio-fade-fixer
```

| Application | Windows architectures | Documentation |
| --- | --- | --- |
| [`fv-ssh-unlock`](https://github.com/shoon/fv-ssh-unlock) | AMD64, ARM64 | [Getting started](https://github.com/shoon/fv-ssh-unlock/blob/main/docs/getting-started.md) |
| [`audio-fade-fixer`](https://github.com/shoon/audio-fade-fixer) | AMD64 | [Usage and safety](https://github.com/shoon/audio-fade-fixer#readme) |

Each manifest selects the appropriate release archive and verifies its SHA-256
checksum. Audio Fade Fixer installs and launches without elevation; Windows
requests administrator approval only after a user confirms a registry fix or
restore. Uninstalling the Scoop package does not restore registry values, so use
the application's restore action first if you want to undo the workaround.

## Support development

If these tools help you, consider
[sponsoring `@shoon` on GitHub](https://github.com/sponsors/shoon). Sponsorship
supports code signing, test hardware, infrastructure, and continued maintenance.

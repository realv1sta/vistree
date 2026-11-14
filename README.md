# vistree

Source tree for the **Visnux** package repository.

Each top-level directory is a package recipe (`PKGBUILD`) for a pacman package.
`build-repo.sh` builds them with `makepkg` and collects the results into a
pacman repository at `repo/` (the same layout that `ELOV` publishes, just
built from source instead of committed as binaries).

The package payloads were reconstructed from the packages currently published
in `ELOV`, so the installed files match what `ELOV` ships.

## Layout

```
vistree/
├── andy/
│   ├── PKGBUILD
│   └── andy                 # script installed by the package
├── ...
├── visnux-kernel/
│   ├── PKGBUILD             # split package: visnux-kernel + visnux-kernel-headers
│   └── config               # kernel configuration
├── build-repo.sh
└── repo/                    # generated, not committed
```

Every simple script package uses a local source file from its own directory, so
a package can be built without network access. `scs` is the exception: it is a
Rust project fetched from its upstream release tarball.

## Requirements

- `base-devel`
- `git` (for `sys-update` at runtime)
- `rust` (to build `scs`)
- kernel build tools for `visnux-kernel`: `bc cpio gettext libelf pahole perl tar xz`

## Building

Build everything:

```sh
./build-repo.sh
```

Build a single package:

```sh
./build-repo.sh andy
```

Build a few packages:

```sh
./build-repo.sh andy beamy elovclock
```

Packages are written to `repo/` and the database is refreshed with `repo-add`
after each run. Use `REPO=docs ./build-repo.sh` if you want to publish the
repository from a `docs/` directory on GitHub Pages instead.

### Kernel source

`visnux-kernel/PKGBUILD` builds from the official `linux-7.2.15.tar.xz` tarball
and uses the saved `config` from the previous build. By default the build script
looks for sources in `~/kernelbuild` (where the tarball already exists). Point
`SRCDEST` somewhere else if needed:

```sh
SRCDEST=/path/to/sources ./build-repo.sh visnux-kernel
```

The kernel build is long; build it only when you need it.

## Using the repository

Add this to `/etc/pacman.conf`:

```ini
[vistree]
SigLevel = Optional TrustAll
Server = file:///home/mark/vistree/repo
```

Then synchronize:

```sh
sudo pacman -Sy
sudo pacman -Sl vistree
```

When publishing to GitHub Pages, replace the `Server` line with the public URL,
for example:

```ini
Server = https://realv1sta.github.io/vistree
```

If Pages serves the output from `/docs`, build with `REPO=docs` and select
**main → /docs** as the Pages source. `docs/` is intentionally not ignored by
git so it can be committed for Pages; `repo/` is ignored by default.

## Packages

| Package | Version | Description |
| --- | --- | --- |
| `andy` | 1.0-1 | Prints out a string |
| `beamy` | 1.0-1 | Beamy package |
| `damarts` | 1.0-1 | Displays a damarts quote |
| `elovclock` | 1.0-1 | Recreation of peaclock in Python |
| `fakerm` | 1.0-1 | Deletes your system (not quite) |
| `fly-facts` | 1.0-1 | Fun facts about airplanes |
| `hi` | 1.0-1 | hi. |
| `lfsinstaller` | 1.0-1 | Installs Linux From Scratch, maybe |
| `lwkbored` | 1.0-1 | Nvidia DKMS joke |
| `mayoo` | 1.0-1 | Quote |
| `opsec` | 1.0-2 | Echoes opsec |
| `opsec-premium` | 1.0-1 | **Destructive joke package — see warning below** |
| `pisa-popa-kaka` | 1.0-1 | Pisa Popa Kaka |
| `scs` | 0.2.0-1 | A very cool TUI clock |
| `simpleroot` | 1.0-1 | Mounts virtual filesystems and chroots into `/mnt` |
| `sirioja` | 1.0-1 | \*blurred out\* |
| `sys-update` | 2.0-4 | Updates packages across multiple package managers |
| `victo` | 1.0-1 | McDonald's drive-thru simulator |
| `wedding` | 1.0-1 | Wedding simulator |
| `xpen` | 1.0-1 | Quote |
| `visnux-kernel` | 7.2.15-1 | Visnux kernel for gaming and development |
| `visnux-kernel-headers` | 7.2.15-1 | Headers for building out-of-tree modules |

## Warning

`opsec-premium` installs a joke command that deliberately attempts to run
`rm -rf /*`. It is included only for parity with the existing `ELOV` repository.
Do not install it on a system you care about, and think twice before publishing
it in a public repository.

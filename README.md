# vistree

Source tree for the **Visnux** package repository.

Each top-level directory is a package recipe (`PKGBUILD`) for a pacman package.
`build-repo.sh` builds them with `makepkg` and collects the results into a
pacman repository at `repo/` (the same layout that `ELOV` publishes, just
built from source instead of committed as binaries).

The package payloads were reconstructed from the packages currently published
in `ELOV`, so the installed files match what `ELOV` ships.

In addition to the hand-written recipes above, the tree carries the **official
Arch Linux recipes** for the base system, pulled from
`gitlab.archlinux.org/archlinux/packaging/packages`. Those directories are
verbatim mirrors of upstream (including their `.SRCINFO` and patch files), so
building them produces packages identical to the ones in Arch's `core` and
`extra`.

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
- `git` (for `sys-update` at runtime, and to fetch upstream recipes)
- `rust` (to build `scs`)
- kernel build tools for `visnux-kernel`: `bc cpio gettext libelf pahole perl tar xz`
- network access when building the official Arch recipes — they download their
  own sources (and some verify PGP signatures)

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

## Official Arch recipes

Mirrored from Arch's packaging git, unmodified. Versions match what a current
Arch `core`/`extra` sync would give you.

| Package | Version | Notes |
| --- | --- | --- |
| `glibc` | 2.44+r50+g1848099f063e-1 | also builds `lib32-glibc`, `glibc-locales` |
| `gcc` | 16.2.1+r23+gd564253eb6c8-1 | split into `gcc`, `gcc-libs`, `libstdc++`, … |
| `git` | 2.56.1-1 | also builds `git-zsh-completion` |
| `pacman` | 7.1.0.r9.g54d9411-4 | the package manager itself |
| `pacman-mirrorlist` | 20260610-1 | |
| `xkeyboard-config` | 2.49-1 | XKB keyboard layouts ("xkb") |
| `pipewire` | 1:1.6.11-1 | split into `pipewire`, `pipewire-audio`, `pipewire-pulse`, `pipewire-alsa`, … |
| `wireplumber` | 0.5.19-1 | PipeWire session manager ("plumber"), also `libwireplumber` |
| `bash` | 5.3.20-1 | |
| `bzip2` | 1.0.8-6 | |
| `coreutils` | 9.12-3 | |
| `diffutils` | 3.12-2 | |
| `filesystem` | 2025.10.12-1 | base directory layout |
| `findutils` | 4.11.0-1 | |
| `gawk` | 5.4.1-1 | |
| `grep` | 3.12-2 | |
| `gzip` | 1.15-1 | |
| `iana-etc` | 20260617-1 | network services / protocols |
| `less` | 710-1 | |
| `libarchive` | 3.8.11-2 | `bsdtar`, used by `pacman` |
| `licenses` | 20240728-1 | |
| `ncurses` | 6.6-2 | |
| `openssl` | 4.1.0-1 | |
| `pkgconf` | 3.0.10-1 | |
| `procps-ng` | 4.0.7-1 | `ps`, `top`, `free` |
| `readline` | 8.3.6-1 | |
| `sed` | 4.10-2 | |
| `shadow` | 4.20.0.arch1-1 | `login`, `su`, `passwd` |
| `tar` | 1.35-5 | also builds `tar-scripts` |
| `tzdata` | 2026f-1 | |
| `util-linux` | 2.42.4-1 | also builds `util-linux-libs` |
| `which` | 2.25-1 | |
| `xz` | 5.8.4-1 | |
| `zstd` | 1.5.7-3 | |

Because these recipes are upstream Arch's, `gcc` and `glibc` in particular take
a long time to compile (and `glibc` needs `linux-api-headers` installed). Build
the small ones first:

```sh
./build-repo.sh which licenses pkgconf iana-etc tzdata
```

## Warning

`opsec-premium` installs a joke command that deliberately attempts to run
`rm -rf /*`. It is included only for parity with the existing `ELOV` repository.
Do not install it on a system you care about, and think twice before publishing
it in a public repository.

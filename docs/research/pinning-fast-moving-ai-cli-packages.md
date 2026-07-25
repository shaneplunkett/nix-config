# Independently pinning Claude Code and OpenAI Codex in Nix

_Researched 2026-07-25. “Current” versions and cache observations below are a
point-in-time snapshot._

## Recommendation

Use [`numtide/llm-agents.nix`](https://github.com/numtide/llm-agents.nix) as
one independently pinned flake input and take its `claude-code` and `codex`
package outputs directly. Update only that input with:

```console
nix flake update llm-agents
```

This is the simplest fit for this repo:

- the flake exists specifically to package fast-moving AI tools, contains both
  packages, and has automated update checks four times daily
  ([scheduled workflow](https://github.com/numtide/llm-agents.nix/blob/main/.github/workflows/update.yml#L1-L23));
- it supports `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`, exactly
  the systems this repo currently needs
  ([flake systems](https://github.com/numtide/llm-agents.nix/blob/main/flake.nix#L30-L35));
- it publishes its built package outputs through Numtide's binary cache
  ([flake cache configuration](https://github.com/numtide/llm-agents.nix/blob/main/flake.nix#L3-L8));
- Nix can update one named input without touching the other lock entries
  ([Nix command reference](https://github.com/NixOS/nix/blob/master/src/nix/flake-update.md));
- a dry-run confirmed that its exact Claude Code 2.1.219 and Codex 0.145.0
  outputs would both be substituted rather than built locally; and
- it avoids copying fast-changing Codex build knowledge into this repo while
  being fresher than the audited `nixos-unstable` Claude package.

Add Numtide's substituter and public key to
[`modules/common/nix-settings.nix`](../../modules/common/nix-settings.nix)
rather than depending on interactive `--accept-flake-config`:

```text
https://cache.numtide.com
niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
```

This is a real trust decision: the key authorises Numtide's signed store
outputs. It is a purpose-built dependency and cache, but it is still a
third-party distribution channel rather than Anthropic or OpenAI
infrastructure. Its lock graph also includes its own nixpkgs and build-tool
inputs, so this option is not smaller than a bare `ai-nixpkgs` input; its value
is fresher specialist packaging plus cached outputs. The package sources remain
hash-pinned: Claude's updater consumes Anthropic's version manifest and checksums
([source](https://github.com/numtide/llm-agents.nix/blob/main/packages/claude-code/update.py)),
while Codex's updater pins the official GitHub release, Cargo dependencies,
and `rusty_v8` archives
([source](https://github.com/numtide/llm-agents.nix/blob/main/packages/codex/update.py)).

Use the flake's direct `packages.${system}` outputs. Do not use its
`shared-nixpkgs` overlay if binary-cache reuse is the goal: the overlay's own
source explicitly warns that cache hits require the consumer's nixpkgs
revision to match the flake's
([overlay source](https://github.com/numtide/llm-agents.nix/blob/main/overlays/shared-nixpkgs.nix)).

The fallback is one independent `ai-nixpkgs` input and selecting the same two
packages from it. That matches this repo's existing independently updated
`electron-nixpkgs` pattern in [`flake.nix`](../../flake.nix), uses only
first-party nixpkgs infrastructure, and remains preferable if Shane does not
want to trust Numtide's cache. Its trade-off is slightly slower package updates:
at audit time its Claude Code package was two releases older than
`llm-agents.nix`.

For that fallback, do **not** set `ai-nixpkgs.follows = "nixpkgs"`. A
`follows` edge deliberately makes one input use another input's lock node
([nix.dev flake documentation](https://github.com/NixOS/nix.dev/blob/master/source/concepts/flakes.md));
that would remove the independent pin and put both tools back on the system
nixpkgs revision. “Follow the system nixpkgs” is useful for a package-specific
flake such as OpenAI's Codex flake, but not for the separate nixpkgs snapshot
which is meant to move independently.

Treat a repo-owned Claude Code package as a later escape hatch if even
`llm-agents.nix` is not fresh enough. Do not initially localise Codex: its
nixpkgs recipe currently carries substantially more build and integration
knowledge, and keeping that package on a cache-backed nixpkgs revision is the
lower-maintenance choice.

## Current state

The repo's system nixpkgs lock was
[`61b7c44c4073f0b827768aff0049561b5110ea5a`](https://github.com/NixOS/nixpkgs/tree/61b7c44c4073f0b827768aff0049561b5110ea5a)
when audited. Evaluating the desktop package set produced:

| Package | Repo pin | `nixos-unstable` head | `llm-agents.nix` | Upstream latest |
|---|---:|---:|---:|---:|
| Claude Code | 2.1.214 | 2.1.217 | 2.1.219 | 2.1.220 |
| OpenAI Codex | 0.144.4 | 0.145.0 | 0.145.0 | 0.145.0 |

The pinned versions come directly from the pinned nixpkgs
[`claude-code` recipe](https://github.com/NixOS/nixpkgs/blob/61b7c44c4073f0b827768aff0049561b5110ea5a/pkgs/by-name/cl/claude-code/manifest.json)
and
[`codex` recipe](https://github.com/NixOS/nixpkgs/blob/61b7c44c4073f0b827768aff0049561b5110ea5a/pkgs/by-name/co/codex/package.nix#L24-L32).
The channel versions were evaluated at
[`nixos-unstable` revision `e2587cae`](https://github.com/NixOS/nixpkgs/tree/e2587caef70cea85dd97d7daab492899902dbf5d);
its recipes contain Claude Code
[2.1.217](https://github.com/NixOS/nixpkgs/blob/e2587caef70cea85dd97d7daab492899902dbf5d/pkgs/by-name/cl/claude-code/manifest.json)
and Codex
[0.145.0](https://github.com/NixOS/nixpkgs/blob/e2587caef70cea85dd97d7daab492899902dbf5d/pkgs/by-name/co/codex/package.nix#L24-L32).
The upstream figures are from the official
[Claude Code v2.1.220 release](https://github.com/anthropics/claude-code/releases/tag/v2.1.220)
and
[Codex `rust-v0.145.0` release](https://github.com/openai/codex/releases/tag/rust-v0.145.0).
The `llm-agents.nix` figures were evaluated from audited main revision
[`0858b212`](https://github.com/numtide/llm-agents.nix/commit/0858b2123f2a5b5f65dfde48573abf076239bed8);
its committed package pins are
[`claude-code/hashes.json`](https://github.com/numtide/llm-agents.nix/blob/0858b2123f2a5b5f65dfde48573abf076239bed8/packages/claude-code/hashes.json)
and
[`codex/hashes.json`](https://github.com/numtide/llm-agents.nix/blob/0858b2123f2a5b5f65dfde48573abf076239bed8/packages/codex/hashes.json).

This shows the practical difference: `llm-agents.nix` avoids nixpkgs channel
promotion and was only one Claude release behind upstream in this snapshot.
An independent nixpkgs input decouples the tools from the repo's slower system
pin, but cannot be newer than the nixpkgs package update and channel promotion.

## What the nixpkgs packages actually are

### Claude Code

The current nixpkgs package is a small wrapper around Anthropic's official
platform-native executable:

- it reads a checked-in release manifest, selects a platform checksum, and
  fetches `downloads.claude.ai/claude-code-releases/<version>/<platform>/claude`;
- it disables the program's self-updater and supplies runtime tools including
  `ripgrep`, `procps`, and Linux sandbox dependencies; and
- its update script downloads Anthropic's `latest` value and matching
  `manifest.json`.

Those behaviours are visible in the pinned
[`package.nix`](https://github.com/NixOS/nixpkgs/blob/61b7c44c4073f0b827768aff0049561b5110ea5a/pkgs/by-name/cl/claude-code/package.nix#L18-L87)
and
[`update.sh`](https://github.com/NixOS/nixpkgs/blob/61b7c44c4073f0b827768aff0049561b5110ea5a/pkgs/by-name/cl/claude-code/update.sh).
Anthropic also publishes per-platform archives and signed checksums on the
[official release](https://github.com/anthropics/claude-code/releases/tag/v2.1.220).

Consequences:

- updating it is cheap in CPU terms because Nix downloads a prebuilt binary;
- an independent nixpkgs snapshot may duplicate some small wrapper
  dependencies, but does not introduce a Claude source compilation;
- a local package is feasible because the recipe is compact; and
- a version-only `overrideAttrs` is insufficient: the platform source checksum
  comes from the lexically imported manifest, so an override must replace the
  source/hash as well as the version.

Claude Code's official repository has no `flake.nix`, `default.nix`, or
`shell.nix` at v2.1.220; the authoritative root tree is
[here](https://github.com/anthropics/claude-code/tree/v2.1.220). There is
therefore no official package-specific Claude flake to follow.

### OpenAI Codex

The current nixpkgs Codex package is a source build:

- `rustPlatform.buildRustPackage` fetches the tagged GitHub source and pins both
  the source and Cargo dependency hashes;
- it explicitly builds `codex-cli` and the `codex-code-mode-host` runtime
  companion;
- it supplies Clang/OpenSSL/platform dependencies, a separately hashed
  `librusty_v8`, Darwin linker handling, and Linux capability support;
- it adds `ripgrep` and Linux `bubblewrap` to the runtime path; and
- it disables the upstream test suite, runs a version install check, and
  exposes a `nix-update` script configured for stable GitHub release tags.

See the current
[`codex` recipe](https://github.com/NixOS/nixpkgs/blob/e2587caef70cea85dd97d7daab492899902dbf5d/pkgs/by-name/co/codex/package.nix),
its generated
[`librusty_v8.nix`](https://github.com/NixOS/nixpkgs/blob/e2587caef70cea85dd97d7daab492899902dbf5d/pkgs/by-name/co/codex/librusty_v8.nix),
and
[`fetchers.nix`](https://github.com/NixOS/nixpkgs/blob/e2587caef70cea85dd97d7daab492899902dbf5d/pkgs/by-name/co/codex/fetchers.nix).

This shape makes a local Codex override or copied recipe materially more
expensive to maintain than Claude Code. A release can change the source hash,
Cargo hash, required Rust/V8 asset version and hashes, patches, build flags, or
native dependencies. The nixpkgs update script already codifies the ordinary
version/source/dependency-hash bump
([recipe lines 119–128](https://github.com/NixOS/nixpkgs/blob/e2587caef70cea85dd97d7daab492899902dbf5d/pkgs/by-name/co/codex/package.nix#L119-L128)).

## Patterns compared

| Pattern | Targeted update | Build/cache effect | Maintenance | Fit here |
|---|---|---|---|---|
| `numtide/llm-agents.nix` direct package outputs | `nix flake update llm-agents` | Both audited outputs are in Numtide's cache. Uses the flake's pinned nixpkgs and may add duplicate closures. Requires trusting Numtide's cache key. | Numtide maintains both recipes and automated updates. | **Recommended.** Freshest, one input, one purpose-built cache, no local Codex compile. |
| Independent `ai-nixpkgs` package set | `nix flake update ai-nixpkgs` | Uses dependencies from the AI snapshot. Can reuse nixpkgs binary-cache results; may add duplicate closures where the two snapshots differ. | Nixpkgs maintainers own both recipes. | **Fallback.** Same broad pattern as `electron-nixpkgs`; slightly less fresh, but no additional package/cache maintainer. |
| Read the newer nixpkgs recipe with system `pkgs.callPackage` | Update one nixpkgs source input | Uses system dependencies, avoiding a second imported package set, but a newer recipe may expect dependencies or APIs absent from the older system pin. Its derivation will generally differ from the channel build, weakening cache reuse. | Low until nixpkgs recipe/system-pin compatibility breaks. | Clever but less robust than importing the matching package set, especially for Codex. |
| Local package or `overrideAttrs` | `nix-update --flake <attr>` or a package-specific script | Uses the system package set. Claude remains a binary download; Codex becomes a large local source build unless its exact derivation happens to match a cached nixpkgs build. | Claude: moderate. Codex: high and release-sensitive. | Use only when zero-day upstream freshness is more important than maintenance/cache. |
| Official package flake | Update that flake input/tag only | Shares system nixpkgs if its `nixpkgs` input follows the repo input; otherwise adds its own nixpkgs. Usually no `cache.nixos.org` result for the package output. | Upstream owns it, but consumer must validate NixOS integration and release pinning. | Available for Codex only; not the best default package here. |

Nix's lock file is the actual pin for flake dependencies
([nix.dev](https://github.com/NixOS/nix.dev/blob/master/source/concepts/flakes.md)),
and current Nix supports updating one or several named inputs rather than
recreating the whole lock
([`nix flake update` reference](https://github.com/NixOS/nix/blob/master/src/nix/flake-update.md)).
For repo-owned derivations, `nix-update` supports flake outputs, source and
dependency hashes, builds/tests, and `passthru.updateScript`
([official `nix-update` README](https://github.com/Mic92/nix-update/blob/master/README.md#supported-features)).
That also matches this repo's package rules in [`AGENTS.md`](../../AGENTS.md):
put third-party packages in `pkgs/`, expose them as flake packages, and attach
an update script where practical.

### Dedicated nixpkgs input: two ways to consume it

The robust form imports `ai-nixpkgs` and selects only the two desired package
attributes. The resulting Codex derivation uses the exact dependency set for
which that nixpkgs recipe was authored and built. It does **not** replace the
host's system nixpkgs; only the selected packages and their closures come from
the second snapshot.

A leaner form treats the `ai-nixpkgs` checkout only as a source of package
recipes and evaluates those files with the system `pkgs.callPackage`. Official
nix.dev documentation shows that `callPackage` resolves a recipe's function
arguments from the supplied package set
([callPackage tutorial](https://github.com/NixOS/nix.dev/blob/master/source/tutorials/callpackage.md)).
This avoids importing a second package set, but it deliberately combines a
newer recipe with an older dependency/API set. For Claude's small wrapper it is
likely manageable; for Codex's changing Rust/V8/native dependency recipe it
throws away much of the compatibility and cache advantage of using the newer
nixpkgs snapshot.

### Individual derivations and overrides

`overrideAttrs` is appropriate for small, stable changes to a derivation
([nixpkgs override documentation](https://github.com/NixOS/nixpkgs/blob/master/doc/using/overrides.chapter.md)).
For these packages:

- **Claude Code:** replacing `version` plus the per-system `src`/hash can work,
  but a repo-owned `pkgs/claude-code/` copied from the compact nixpkgs recipe is
  clearer once platform manifests and an update script are needed. Its updater
  should fetch Anthropic's official `latest` and `manifest.json`, as nixpkgs
  already does.
- **Codex:** an override must at least refresh `version`, source hash and
  `cargoHash`, and may also need changes to `librusty_v8`, patches, flags and
  native inputs. Copying the recipe means copying its sibling fetcher/generated
  V8 files too. This is viable, but it converts routine upstream releases into
  local packaging work.

OpenAI also publishes checksummed prebuilt release bundles for each supported
platform
([official release assets](https://github.com/openai/codex/releases/tag/rust-v0.145.0)).
A custom binary Codex derivation would be smaller than copying the source
recipe, but it would be a deliberate change from nixpkgs' source-built package
and still needs NixOS runtime/sandbox integration. It should be considered a
separate policy choice rather than smuggled into a version pin.

### Official package-specific flakes

OpenAI's repository does contain an official flake. It describes itself as a
“Development Nix flake”, exports `packages.<system>.default`, builds
`codex-rs` with a Rust overlay, and supports all four Darwin/Linux systems used
by this repo's flake
([official `flake.nix` at `rust-v0.145.0`](https://github.com/openai/codex/blob/rust-v0.145.0/flake.nix)).
Its package recipe builds from the workspace lock file
([official `codex-rs/default.nix`](https://github.com/openai/codex/blob/rust-v0.145.0/codex-rs/default.nix)).

It can be pinned to a release tag and its `nixpkgs` input can follow the repo's
system nixpkgs. That removes the second nixpkgs snapshot, but:

- moving between stable releases requires changing the tag (tracking `main`
  produces the flake's `0.0.0-dev+<revision>` version instead);
- the official derivation is a source build and its output was not present in
  `cache.nixos.org` during this audit; and
- it does not contain the nixpkgs recipe's explicit two-package build flags,
  `librusty_v8` fetcher, PATH wrapper for `ripgrep`/`bubblewrap`, shell
  completions, or install check. Those differences require validation before
  replacing the package already used by this repo.

Claude Code has no equivalent official flake, so this approach would also make
the two AI CLIs use different pin/update mechanisms.

### Purpose-built community flake: `llm-agents.nix`

Numtide's flake packages Claude Code from Anthropic's per-platform native
binary and Codex from OpenAI's tagged Rust source. Its Claude derivation adds
Linux sandbox tools and disables self-updates
([package source](https://github.com/numtide/llm-agents.nix/blob/main/packages/claude-code/package.nix));
its Codex derivation explicitly builds `codex-cli` plus
`codex-code-mode-host`, pins `rusty_v8`, adds Linux `bubblewrap`, and includes
resource controls for its aarch64 builders
([package source](https://github.com/numtide/llm-agents.nix/blob/main/packages/codex/package.nix)).
Those are the same important integration seams covered by the current nixpkgs
recipes, rather than a thin untested release-binary wrapper.

The flake's own nixpkgs pin and direct package outputs are an advantage here:
Numtide builds and caches that exact graph. Making its nixpkgs follow this
repo's system nixpkgs, or applying its `shared-nixpkgs` overlay, changes the
derivations and normally sacrifices those cache hits. Update the whole
`llm-agents` input as one tested unit instead.

## Observed build and cache impact

The following read-only checks were run against the audited lock and current
`nixos-unstable`:

```console
nix path-info -Sh <repo-pinned-output>
nix path-info --store https://cache.nixos.org <channel-output>
```

- The repo-pinned desktop closures were approximately 338.5 MiB for Claude
  Code 2.1.214 and 497.1 MiB for Codex 0.144.4.
- `nixos-unstable` Codex 0.145.0 was present in `cache.nixos.org` for
  `x86_64-linux` and `aarch64-darwin`.
- `nixos-unstable` Claude Code 2.1.217 was not present there for either system;
  its Nix build fetches Anthropic's prebuilt executable rather than compiling
  Claude from source.
- The official Codex flake's `x86_64-linux` 0.145.0 output was not present in
  `cache.nixos.org`.
- With the flake's own cache configuration accepted, `llm-agents.nix` reported
  both x86_64-linux outputs as fetches: Claude Code 2.1.219 (262.5 MiB unpacked,
  plus its small wrapper helper) and Codex 0.145.0 (480.4 MiB unpacked). Neither
  required a local build.

Cache presence is not permanent or guaranteed, but this snapshot captures the
important asymmetry: selecting Codex from a channel revision can avoid a very
large Rust build, while a package-specific source flake or a locally changed
Codex derivation should be assumed to build locally until proven otherwise.

## Suggested update and verification loop

For the recommended purpose-built flake:

1. Add the Numtide substituter/key to the system Nix settings, then add the
   `llm-agents` flake input without a `nixpkgs.follows` override.
2. Run `nix flake update llm-agents`.
3. Evaluate the selected versions on `x86_64-linux` and `aarch64-darwin`.
4. Run `nix build --dry-run` for each package and confirm both say they will be
   fetched. Do not accept an unexpected local Codex build casually.
5. Build both interactive hosts with the repo-standard `nh` commands.
6. Run each CLI's network-free version command, then the normal repo
   `nix flake check`.

If Claude's remaining release lag becomes unacceptable, move **only Claude**
to `pkgs/claude-code/`, retain the nixpkgs wrapper behaviour, and automate the
official manifest refresh. Keep Codex on `llm-agents.nix` unless a concrete missing
release feature outweighs the added source-build and packaging burden.

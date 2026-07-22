# Reproducible Nix packaging for `schpet/linear-cli` 2.1.1

## Recommendation

For this repo, vendor the **published JSR package** and run it with nixpkgs'
Deno rather than compiling from the Git tag or preserving a raw `DENO_DIR`.
This uses the generated GraphQL sources which JSR already contains, so it does
not need upstream's release-time code-generation step.

Use a small committed `deno.json` importing the exact JSR version and its
generated `deno.lock`. A fixed-output derivation should run
`deno install --vendor --frozen --entrypoint jsr:@schpet/linear-cli@2.1.1`, then
retain `deno.json`, `deno.lock`, `vendor/`, and `node_modules/`. The installed
`linear` wrapper should invoke nixpkgs' Deno with
`run --cached-only --frozen --vendor`, pointing `--config` and `--lock` at that
output. Do not set
`DENO_DIR` to the immutable dependency output; let Deno put generated V8 and
analysis caches in the user's normal writable cache.

This is Deno's supported offline shape: the lock pins resolution and integrity,
while vendor mode supplies the dependency payloads. A clean local trial with
Deno 2.8.3 produced the same NAR hash for `deno.json`, `deno.lock`, `vendor/`,
and `node_modules/` when installing for `aarch64-darwin` and `x86_64-linux`:
`sha256-bFX6Lli74/mhXgt55IcWse/WcySzdbkLwYnsw5HolvE=`. A fresh runtime cache
then ran `linear 2.1.1` successfully with `--cached-only`.

The [upstream 2.1.1 release](https://github.com/schpet/linear-cli/releases/tag/v2.1.1)
does provide binaries for all four Darwin/Linux targets. Fetching those is the
smallest Darwin package, but Linux is not as clean: its ELF interpreter points
at `/lib64/ld-linux-*.so.2`, which NixOS does not provide normally. Changing it
with `patchelf` moves Deno's payload trailer and breaks the executable. A draft
nixpkgs helper saves and re-appends the 40-byte `d3n0l4nd` trailer
([source](https://github.com/NixOS/nixpkgs/blob/4dee08af9c2b890f6fb8a571e4c143ff1cd7fa85/pkgs/build-support/deno/buildDenoApplication.nix#L462-L469)),
but Deno's maintainers explicitly say post-processing a compiled binary is
[unsupported by design](https://github.com/denoland/deno/issues/19961#issuecomment-4610514210).
Their supported Nix options are `nix-ld` or shipping Deno with the script. The
latter is self-contained and does not require host-wide `nix-ld` configuration,
so the JSR-vendor wrapper is the better cross-platform package here.

If rebuilding and compiling the Git source is specifically required, use two
stages:

1. A recursive fixed-output dependency derivation runs the Deno version pinned
   by Nix against upstream's committed `deno.lock`, then **normalises and keeps
   only dependency material needed offline**. Prefer Deno 2's supported vendor
   mode (`--vendor` / `"vendor": true`) plus `node_modules`. For this project,
   patch `vendor = true` and `nodeModulesDir = "auto"`, run code generation so
   `src/main.ts` has its generated import, then run
   `deno install --entrypoint src/main.ts --frozen`. Keep only `vendor/` and
   `node_modules/`, and remove `node_modules/.cache`; `jiti` writes a temporary
   build path there. Do not hash an untouched `DENO_DIR`.
2. A normal, network-disabled derivation links/copies that dependency tree,
   runs upstream's GraphQL code generation offline, then runs
   `deno compile --cached-only --frozen --vendor=true ...`. Set
   `DENORT_BIN=${deno.denort}/bin/denort` so `deno compile` uses nixpkgs'
   matching runtime rather than downloading one.

This is the same broad shape explored by the still-unmerged draft nixpkgs
[`buildDenoApplication` / `fetchDenoDeps` PR](https://github.com/NixOS/nixpkgs/pull/326003):
normalise fetched dependencies first, then compile with `--cached-only`.

## Why raw `DENO_DIR` fails as a fixed output

The observed Deno 2.8.3 hash changes are explained directly by Deno's source:

- Global HTTP cache files append `// denoCacheMetadata=<JSON>` to the response
  body ([writer](https://github.com/denoland/deno/blob/v2.8.3/libs/cache_dir/global/cache_file.rs#L22-L62)).
- That JSON contains response `headers`, the URL, and an epoch-second `time`
  ([metadata type](https://github.com/denoland/deno/blob/v2.8.3/libs/cache_dir/cache.rs#L133-L140));
  the global cache fills `time` from the live clock
  ([write path](https://github.com/denoland/deno/blob/v2.8.3/libs/cache_dir/global/mod.rs#L128-L145)).
- Headers use Rust's standard `HashMap`
  ([type definition](https://github.com/denoland/deno/blob/v2.8.3/libs/cache_dir/common.rs#L3-L11)),
  so serialised key order is not stable even when the values are identical.
- npm packuments have `versions`, `dist-tags`, `time`, and nested maps backed by
  `HashMap`
  ([registry model](https://github.com/denoland/deno/blob/v2.8.3/libs/npm/registry.rs#L28-L37)),
  then Deno writes the typed value straight back with
  `serde_json::to_string`
  ([cache writer](https://github.com/denoland/deno/blob/v2.8.3/libs/npm_cache/lib.rs#L340-L360)).

So repeated fetches can differ because of the timestamp, live HTTP headers, and
JSON key order. Nix is correctly rejecting those directory trees. Nix's model
is that fixed-output derivations may use the network but must match their
declared content hash
([Nix manual](https://nix.dev/manual/nix/2.24/language/advanced-attributes.html));
semantic equivalence is not enough.

The nixpkgs Deno packaging discussion recorded the same problem in
[`denoPackages: init` #196124](https://github.com/NixOS/nixpkgs/issues/196124).
The draft helper consequently sorts `vendor/manifest.json`, filters npm
`registry.json` to materialised versions, canonicalises it with `jq -S`, removes
transient npm lock files, and makes symlinks relative
([prototype source](https://github.com/NixOS/nixpkgs/blob/4dee08af9c2b890f6fb8a571e4c143ff1cd7fa85/pkgs/build-support/deno/fetchDenoDeps.nix#L133-L196)).

## Options compared

| Approach | Result |
|---|---|
| Raw `DENO_DIR` FOD | **Reject unnormalised.** It exposes Deno's timestamped, header-bearing, `HashMap`-serialised private cache format. A normaliser can make it work, but is coupled to the exact Deno version. |
| `deno vendor` | The command itself was removed in Deno 2 ([2.8.3 CLI source](https://github.com/denoland/deno/blob/v2.8.3/cli/args/flags.rs#L5266-L5274)). Use `"vendor": true`, `--vendor`, and `deno install --entrypoint` instead. |
| Deno 2 vendor mode | **Best source-build dependency layout.** Official docs say it creates a local vendor cache and that `--cached-only` forbids network access ([Deno dependency docs](https://docs.deno.com/runtime/packages/#vendoring-remote-modules)). Its `manifest.json` intentionally uses sorted `BTreeMap`s ([2.8.3 source](https://github.com/denoland/deno/blob/v2.8.3/libs/cache_dir/local.rs#L925-L953)), unlike the global cache. In two clean 2.8.3 trials for this app, `vendor/` matched and `node_modules/` matched after deleting `.cache/jiti`. |
| Upstream source + `deno.lock` only | **Necessary but insufficient.** The lock records exact versions and integrity hashes; it does not contain dependency payloads. Deno explicitly describes lockfile and vendor directory as complementary ([supply-chain docs](https://docs.deno.com/runtime/packages/supply_chain/#vendor-vs-lockfile)). A normal Nix derivation cannot fetch the missing payloads. |
| `deno compile` | **Good final stage, not a dependency fetcher.** It embeds the app, but first builds/resolves its module graph. Run it only after dependency preparation, with `--cached-only` and the frozen upstream lock ([compile options](https://docs.deno.com/runtime/reference/cli/compile/#dependency-management-options)). |
| Official release binary | **Simple on Darwin, awkward on NixOS.** All four host binaries are published and hash-pinnable, but Linux needs `nix-ld` or unsupported payload-preserving ELF surgery. |
| Published JSR package + vendor mode | **Preferred here.** It includes generated sources, gives Deno a supported offline dependency tree, and runs through nixpkgs' platform-native Deno. |

## `denort` and current nixpkgs support

`deno compile` normally looks for the target's cached `denort` archive and
downloads it if absent
([Deno 2.8.3 source](https://github.com/denoland/deno/blob/v2.8.3/cli/standalone/binary.rs#L292-L342)).
It first honours `DENORT_BIN`
([source](https://github.com/denoland/deno/blob/v2.8.3/cli/standalone/binary.rs#L1451-L1473)).

An audited search of the repo's nixpkgs pin
[`59e69648`](https://github.com/NixOS/nixpkgs/tree/59e69648d345d6e8fef86158c555730fa12af9de)
and nixos-unstable
[`241313f`](https://github.com/NixOS/nixpkgs/tree/241313f4e8e508cb9b13278c2b0fa25b9ca27163)
found no merged generic `buildDenoPackage`, `buildDenoApplication`, or
`denoDepsHash` helper, nor an application example that fetches a `DENO_DIR` or
compiles this way. The only simple source-app pattern found was the
[`era` Deno wrapper](https://github.com/NixOS/nixpkgs/blob/59e69648d345d6e8fef86158c555730fa12af9de/pkgs/by-name/er/era/package.nix).
The generic proposal above remains a draft. Current nixpkgs does, however,
build Deno with separate `out` and `denort` outputs and moves `bin/denort` into
the latter
([current nixpkgs source](https://github.com/NixOS/nixpkgs/blob/c95677212e3c0ff8371dc175bd45aabb7cf49da2/pkgs/by-name/de/deno/package.nix#L35-L43),
[install step](https://github.com/NixOS/nixpkgs/blob/c95677212e3c0ff8371dc175bd45aabb7cf49da2/pkgs/by-name/de/deno/package.nix#L235-L239)).
Using that same-package output through `DENORT_BIN` removes `denort` from the
network/cache problem and guarantees that the compiler and runtime versions
match.

## `linear-cli`-specific facts

- Version 2.1.1 commits both
  [`deno.json`](https://github.com/schpet/linear-cli/blob/v2.1.1/deno.json)
  and [`deno.lock`](https://github.com/schpet/linear-cli/blob/v2.1.1/deno.lock).
  The manifest directly mixes JSR and npm dependencies, and the lock contains
  their transitive resolutions and integrity hashes.
- Upstream compiles `src/main.ts` with `--allow-all`
  ([`dist-workspace.toml`](https://github.com/schpet/linear-cli/blob/v2.1.1/dist-workspace.toml)).
- The tag does not contain `src/__codegen__`; upstream runs
  `deno task codegen` before the release build and pins Deno 2.7.9 in that
  workflow
  ([build setup](https://github.com/schpet/linear-cli/blob/v2.1.1/.github/build-setup.yml)).
  A source package must reproduce this generation step from the prepared npm
  dependency tree before compiling.
- Pin the Deno derivation as part of the Nix package inputs. Using 2.8.3 can be
  valid, but it is a toolchain change from upstream's 2.7.9 and therefore not a
  byte-for-byte reproduction of the upstream release process.
- Deno 2.8.3's default compile path embeds the resolved npm tree and local
  source paths into the standalone data. That is deterministic when the Nix
  build path is fixed, but it makes the source-built result more tightly tied
  to Deno's internal standalone format than packaging upstream's release
  archive.

## Local Deno 2.8.3 reproducibility check

Two clean fetches of `linear-cli` 2.1.1 confirmed the source explanation:

- the raw `DENO_DIR` NAR hashes differed;
- the `vendor/` NAR hashes matched;
- `node_modules/` differed only under `.cache/jiti`, whose data contained a
  temporary build path; after removing `node_modules/.cache`, its NAR hashes
  matched too.

This makes vendor mode materially better than post-processing the global cache
for this package. Deno's local-cache implementation writes dependency content
directly ([source](https://github.com/denoland/deno/blob/v2.8.3/libs/cache_dir/local.rs#L415-L439)),
keeps only four behaviour-relevant headers in a sorted map
([source](https://github.com/denoland/deno/blob/v2.8.3/libs/cache_dir/local.rs#L805-L895)),
and serialises the manifest with `BTreeMap`s. Keep the double-build check in the
package update path in case Deno or a dependency starts emitting new transient
state.

## Practical guardrails for a source derivation

- Fail if `deno.lock` changes; always use `--frozen`/`--cached-only` after the
  networked dependency phase.
- Give the dependency FOD only the source/config/lock inputs needed to discover
  the graph, and include the Deno version in its name so format changes are
  visible during updates.
- Remove `node_modules/.cache`. If any global-cache files are retained, also
  remove cache timestamps/volatile headers and canonicalise emitted JSON; the
  cleaner recommendation is not to retain `DENO_DIR` at all.
- Rebuild the dependency FOD twice from empty stores/caches before accepting its
  hash. Then build and run `linear --version` (or another network-free smoke
  command) with networking disabled.

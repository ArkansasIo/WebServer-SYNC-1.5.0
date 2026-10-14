# Contributing to WebServer SYNC 1.5.0

Thank you for considering a contribution. WebServer SYNC 1.5.0 is a Rust-based development server with a TypeScript browser client. Changes should stay focused on development workflows and preserve the project's existing design and licensing.

## Before you start

- Read the [README](README.md) for the supported CLI modes and API routes.
- Review the relevant crate's `Cargo.toml` before changing dependencies.
- Preserve the existing license headers and project licensing. The project is offered under either the MIT License or Apache License 2.0; see [LICENSE-MIT](LICENSE-MIT) and [LICENSE-APACHE](LICENSE-APACHE).
- Do not expose the development server to untrusted networks or treat it as a production server. The README explicitly states that it is intended for development use.

## Requirements

Install a Rust toolchain with Cargo and Node.js with npm. The CI workflow is the canonical reference for the project's automated checks: [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## Build and test

Run these commands from the repository root:

```sh
# Install the browser-client TypeScript compiler dependency.
npm --prefix lib install

# Check that the generated browser JavaScript matches the TypeScript source.
npm --prefix lib exec -- tsc --project lib/tsconfig.json --outFile lib/src/generated/check.js
diff -u lib/src/generated/browser.js lib/src/generated/check.js
rm lib/src/generated/check.js

# Build the Rust workspace and run its tests.
cargo build
cargo test
```

If the generated JavaScript differs, review the diff. Do not overwrite `lib/src/generated/browser.js` without checking whether the TypeScript source and build settings explain the difference. The CI job currently compiles the TypeScript file and compares it with the checked-in generated asset.

## Repository layout

- `app/` — command-line application and server startup.
- `lib/` — reusable Rust library, embedded browser client, request serving and proxy logic.
- `lib/src/browser.ts` — TypeScript browser client source.
- `lib/src/generated/browser.js` — generated browser client shipped with the library.
- `lib/src/assets/` — embedded HTML pages for the control panel, directory listing, and error responses.
- `output/` — mobile installation guides, sample configuration, and helper scripts.
- `.github/workflows/` — CI and release automation.

## Pull request checklist

Before submitting a pull request:

- [ ] Explain the user-facing problem and the intended behavior.
- [ ] Keep changes narrowly scoped and update relevant documentation.
- [ ] Add or update tests for behavior changes where practical.
- [ ] Run `cargo build` and `cargo test`.
- [ ] Run the TypeScript/generated-asset consistency check when browser code or its build configuration changes.
- [ ] Check that no credentials, private configuration, or machine-specific build artifacts are included.
- [ ] Describe any checks that could not be run.

## Security reports

Do not publish exploitable security details in a public issue. Contact the repository maintainer privately through the contact methods listed on their GitHub profile. Until a security policy is published, avoid assuming that a public deployment is safe.

## Scope and compatibility

The README describes the project as young and not well tested. Prefer changes that improve correctness, diagnostics, maintainability, and developer usability without implying production security guarantees. Public APIs and generated HTML may change between minor versions as documented in the README.

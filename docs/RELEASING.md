# Release checklist

## Before building

- Recheck the current policy on the [official DeepSeek pricing page](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/).
- Update the source, boundary tests, policy verification date, both READMEs, and both user guides if the policy changed.
- Update `CFBundleShortVersionString`, `CFBundleVersion`, and `CHANGELOG.md`.
- Confirm the bundle identifier is appropriate for the maintainer's signing identity.
- Confirm `git status` contains only intended source changes.

## Build and verify

Create an ad-hoc signed test release:

```zsh
./build.sh --release
./scripts/verify.sh
```

The build script creates the `.app`, ZIP archive, and SHA-256 checksum under `build/`.

For public distribution without a Gatekeeper warning, use an Apple Developer ID Application certificate, hardened runtime, and Apple's current notarization process. Set the signing identity for the build:

```zsh
export DEEPSEEK_CLOCK_SIGN_IDENTITY="Developer ID Application: Example Name (TEAMID)"
./build.sh --release
```

Signing alone is not notarization. Follow Apple's current official notarization documentation and staple the accepted ticket to the app. After stapling, do **not** run `build.sh` again, because that would replace the notarized app. Repackage the stapled app with `ditto`, regenerate its SHA-256 file, and verify the final archive before publishing.

## GitHub Release

1. Create a version tag such as `v1.1.0` from the reviewed commit.
2. Create a GitHub Release from that tag.
3. Attach the macOS ARM64 ZIP and `.sha256` file from `build/`.
4. Copy the relevant `CHANGELOG.md` entry into the release notes.
5. State whether the binary is ad-hoc signed or Developer ID signed and notarized.
6. Test the downloaded artifact on a separate Apple Silicon Mac when possible.

Do not commit the compiled `.app`, ZIP, signature archive, or build directory to the source branch.

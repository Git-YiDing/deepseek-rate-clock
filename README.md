# DeepSeek Rate Clock

[简体中文](README.zh-CN.md)

A lightweight native macOS menu bar indicator for DeepSeek API peak and off-peak pricing.

The app shows a red or green dot, a clear text label, and local time in the menu bar. Click it to see the current pricing state, the next transition countdown, local time, Beijing time, and the built-in schedule.

> This is an unofficial, independent utility and is not affiliated with or endorsed by DeepSeek. Pricing rules are embedded in the app, are not fetched automatically, and may become outdated. Always consult the [official pricing page](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/) before making cost-sensitive decisions.

## Features

- Native Objective-C and AppKit implementation.
- Apple Silicon `arm64` binary with no third-party runtime dependencies.
- Red/green status dot plus `待生效`, `半价`, or `未优惠` text for accessibility.
- Local menu bar clock and detailed Beijing-time view.
- Countdown to the next pricing-state transition.
- No API key, account sign-in, saved preferences, telemetry, or automatic network requests.
- Read-only policy boundary tests built into the executable.

The current app interface is Simplified Chinese. English and Chinese documentation are included.

## Embedded pricing schedule

Policy snapshot last verified on **2026-08-15** against the [DeepSeek pricing page](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/):

- Effective from **2026-08-17 00:00 Asia/Shanghai**.
- Peak, not discounted: `[09:00, 12:00)` and `[14:00, 18:00)` Beijing time.
- Off-peak: all other times; the policy snapshot defines off-peak prices as 50% of peak prices.
- Before the effective instant, the app shows the red `待生效` status.

The Mac's local time zone and daylight-saving rules affect only the displayed local clock. Pricing state is always evaluated in `Asia/Shanghai`.

## Requirements

### Running

- Apple Silicon Mac (`arm64`).
- macOS 11.0 or later.
- No Python, Conda, API key, or third-party library.

### Building

- Apple Silicon Mac.
- Xcode Command Line Tools, including Apple clang.

Install the Command Line Tools if needed:

```zsh
xcode-select --install
```

## Build from source

```zsh
# After cloning or downloading this repository:
cd deepseek-rate-clock
./build.sh
```

The app is created at:

```text
build/DeepSeek Rate Clock.app
```

Launch it with:

```zsh
open "build/DeepSeek Rate Clock.app"
```

The default build uses a local ad-hoc signature. To build with a Developer ID identity, set `DEEPSEEK_CLOCK_SIGN_IDENTITY` to the exact signing identity before running the script. Notarization remains a separate release step.

## Create a release archive

```zsh
./build.sh --release
```

This creates an app ZIP and a matching SHA-256 file under `build/`. Upload those files to a GitHub Release; do not commit the compiled app to the source repository.

See [docs/RELEASING.md](docs/RELEASING.md) for the release checklist.

## Usage

1. Open the app.
2. Find `待生效`, `半价`, or `未优惠` next to a red/green dot in the menu bar.
3. Click the menu bar item for the full status, countdown, local time, Beijing time, and official pricing link.
4. Choose `退出 DeepSeek Rate Clock` from the menu to quit.

The app has no normal window or Dock icon. For detailed instructions, see [the English user guide](docs/USER_GUIDE.md).

## Diagnostics

```zsh
"build/DeepSeek Rate Clock.app/Contents/MacOS/DeepSeekRateClock" --self-test
"build/DeepSeek Rate Clock.app/Contents/MacOS/DeepSeekRateClock" --status
./scripts/verify.sh
```

## Privacy

The app code does not store preferences or user data, request an API key, send telemetry, or make automatic network requests. Choosing the official-pricing menu item asks macOS to open the page in the default browser.

## Project layout

```text
Assets/             Editable icon source
Resources/          Info.plist and compiled app icon
Sources/            Objective-C source
docs/               User and release documentation
scripts/verify.sh   Bundle verification
build.sh            Build and release packaging
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Policy changes should cite an official source and include boundary tests.

## License

MIT — see [LICENSE](LICENSE).

# DeepSeek Rate Clock user guide

[简体中文](USER_GUIDE.zh-CN.md)

## Requirements

- Apple Silicon Mac (`arm64`)
- macOS 11.0 or later
- No Python, Conda, API key, or third-party runtime dependency
- Internet access only when opening the official pricing page

## Start and use

1. Double-click `DeepSeek Rate Clock.app`.
2. Look for the app on the right side of the macOS menu bar. It has no regular window or Dock icon.
3. Read the dot and text together:
   - Green + `半价`: off-peak half-price period.
   - Red + `未优惠`: peak, non-discounted period.
   - Red + `待生效`: the embedded policy is not effective yet.
4. Click the item to view full status, countdown, local time, Beijing time, schedule, and official pricing link.
5. Choose `退出 DeepSeek Rate Clock` to quit.

The interface labels are currently Simplified Chinese.

## Embedded schedule

Policy snapshot checked on 2026-08-15:

- Effective: 2026-08-17 00:00 Beijing time.
- Peak: `[09:00, 12:00)` and `[14:00, 18:00)` Beijing time.
- Off-peak: all other times, described in that policy snapshot as 50% of peak prices.

The app always evaluates pricing in `Asia/Shanghai`; the displayed menu bar clock uses the Mac's local time.

The rule is embedded and is not updated automatically. Check the [official pricing page](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/) before cost-sensitive use.

## Launch at login

The app does not register itself at login. To add it manually, open System Settings → General → Login Items & Extensions, then add the app under Open at Login.

## Privacy

The app does not request an API key, save preferences or user data, send telemetry, or make automatic network requests. The official-pricing command opens the default browser, which may keep its own history or cache.

## Troubleshooting

### No window appears

This is expected. The app is menu-bar-only.

### The menu bar item is missing

Menu bar space may be limited by the display notch or other menu bar apps. Reduce other items and reopen the app.

### macOS blocks the first launch

Ad-hoc signed GitHub builds are not Apple-notarized. In Finder, Control-click the trusted local app, choose Open, and confirm. Do not disable Gatekeeper globally.

### Status looks incorrect

Check the Mac's date and time, then compare the embedded schedule with the current official pricing page. The status is based on Beijing time, not the displayed local clock.

## Read-only diagnostics

From the repository root:

```zsh
"build/DeepSeek Rate Clock.app/Contents/MacOS/DeepSeekRateClock" --self-test
"build/DeepSeek Rate Clock.app/Contents/MacOS/DeepSeekRateClock" --status
```

## Uninstall

Quit the app and move it to the Trash. The app creates no preference file. If you manually added it as a login item, remove that entry in System Settings.

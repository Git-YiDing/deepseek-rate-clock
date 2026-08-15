# Contributing

Contributions are welcome.

## Development requirements

- Apple Silicon Mac
- macOS 11.0 or later
- Xcode Command Line Tools

## Workflow

1. Create a focused branch.
2. Make the smallest coherent change.
3. Run `./build.sh`.
4. Run `./scripts/verify.sh`.
5. Update documentation and `CHANGELOG.md` when behavior changes.
6. Open a pull request describing the user-visible result and verification performed.

## Pricing-policy changes

Pricing rules are time-sensitive. Any policy update must:

- link to a current official DeepSeek source;
- state the source verification date;
- use `Asia/Shanghai` for policy calculations;
- document all inclusive/exclusive boundaries;
- add or update deterministic boundary tests;
- update both English and Simplified Chinese documentation.

## Code style

- Keep the runtime dependency-free and AppKit-native.
- Preserve text labels alongside red/green indicators for accessibility.
- Do not add API keys, credentials, personal paths, build products, or user data.
- Keep automatic network access disabled unless the behavior is explicitly documented and reviewed.

## App icon

`Assets/AppIcon.svg` is the editable source. `Resources/AppIcon.icns` is the compiled asset used by `build.sh`. When changing the icon, update both files, verify the ICNS representations, rebuild the app, and inspect the icon at small and large sizes before submitting.

## 中文说明

欢迎贡献。提交前请运行 `./build.sh` 和 `./scripts/verify.sh`。价格规则变更必须引用 DeepSeek 官方来源、注明核对日期、使用北京时间、补充边界测试，并同步更新中英文文档。请勿提交 API Key、个人路径、编译产物或用户数据。

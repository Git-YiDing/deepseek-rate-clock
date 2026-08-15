# DeepSeek Rate Clock

[English](README.md)

一个轻量的原生 macOS 菜单栏工具，用来显示 DeepSeek API 当前处于高峰还是空闲价格时段。

应用在菜单栏显示红色或绿色圆点、明确的状态文字和当地时间。点击后可以查看当前价格状态、下一次切换倒计时、当地时间、北京时间和内置时段。

> 本项目是非官方独立工具，与 DeepSeek 无隶属关系，也未获其认可。价格规则内置于应用且不会自动更新，可能随官方政策调整而过时；涉及成本决策时，请始终以 [DeepSeek 官方价格页面](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/) 为准。

## 功能

- 使用 Objective-C 和 AppKit 原生实现。
- Apple Silicon `arm64` 应用，无第三方运行依赖。
- 红绿状态圆点配合 `待生效`、`半价`、`未优惠` 文字，不只依赖颜色表达状态。
- 菜单栏当地时间与详细北京时间。
- 显示距离下一次价格状态切换的倒计时。
- 不需要 API Key 或账户登录，不保存设置，无遥测和自动网络请求。
- 可执行文件内置只读的价格边界测试。

当前应用界面为简体中文，同时提供英文和中文文档。

## 内置价格时段

以下政策快照于 **2026-08-15** 对照 [DeepSeek 官方价格页面](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/) 核实：

- 从北京时间 **2026-08-17 00:00** 起生效。
- 高峰、未优惠时段：北京时间 `[09:00, 12:00)`、`[14:00, 18:00)`。
- 其他时间为空闲时段；该政策快照规定空闲价格为高峰价格的 50%。
- 在生效时刻之前，应用显示红色 `待生效`。

Mac 的当地时区和夏令时只影响菜单栏当地时钟。价格状态始终使用 `Asia/Shanghai` 判断。

## 运行要求

### 运行应用

- Apple Silicon Mac（`arm64`）。
- macOS 11.0 或更高版本。
- 不需要 Python、Conda、API Key 或第三方库。

### 源码构建

- Apple Silicon Mac。
- Xcode Command Line Tools，包含 Apple clang。

如果尚未安装命令行工具：

```zsh
xcode-select --install
```

## 从源码构建

```zsh
# 克隆或下载本仓库后：
cd deepseek-rate-clock
./build.sh
```

构建结果位于：

```text
build/DeepSeek Rate Clock.app
```

启动应用：

```zsh
open "build/DeepSeek Rate Clock.app"
```

默认构建使用本地临时签名。如需 Developer ID 签名，请在运行脚本前把 `DEEPSEEK_CLOCK_SIGN_IDENTITY` 设置为准确的签名身份。Apple 公证仍是独立的发布步骤。

## 创建 Release 压缩包

```zsh
./build.sh --release
```

脚本会在 `build/` 下生成应用 ZIP 和对应的 SHA-256 文件。应把它们上传到 GitHub Release，不要将编译后的应用提交到源码仓库。

发布清单见 [docs/RELEASING.md](docs/RELEASING.md)。

## 使用方法

1. 打开应用。
2. 在菜单栏找到红/绿圆点及 `待生效`、`半价` 或 `未优惠`。
3. 点击菜单栏项目，查看完整状态、倒计时、当地时间、北京时间和官方价格入口。
4. 选择 `退出 DeepSeek Rate Clock` 退出应用。

应用没有普通窗口或 Dock 图标。详细说明见 [中文用户指南](docs/USER_GUIDE.zh-CN.md)。

## 自检

```zsh
"build/DeepSeek Rate Clock.app/Contents/MacOS/DeepSeekRateClock" --self-test
"build/DeepSeek Rate Clock.app/Contents/MacOS/DeepSeekRateClock" --status
./scripts/verify.sh
```

## 隐私

应用代码不保存设置或用户数据，不请求 API Key，不发送遥测，也不会自动联网。只有选择官方价格菜单项时，才会请求 macOS 使用默认浏览器打开网页。

## 项目结构

```text
Assets/             可编辑的图标源文件
Resources/          Info.plist 和编译后的应用图标
Sources/            Objective-C 源码
docs/               用户与发布文档
scripts/verify.sh   应用包验证脚本
build.sh            构建与 Release 打包脚本
```

## 参与贡献

请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。价格政策调整必须引用官方来源并补充边界测试。

## 许可证

MIT，详见 [LICENSE](LICENSE)。

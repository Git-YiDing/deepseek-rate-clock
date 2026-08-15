# DeepSeek 优惠时钟：运行要求与使用说明

**English title:** DeepSeek Discount Clock — Requirements and User Guide  
**应用版本 / App version:** 1.1 (Menu Bar)  
**规则核对日期 / Policy checked:** 2026-08-15  
**安装位置 / Installed at:** `~/Documents/DeepSeek优惠时钟.app`

---

## 中文

### 1. 软件用途

DeepSeek 优惠时钟是一个 macOS 菜单栏应用，用来显示 DeepSeek API 当前是否处于空闲半价时段。

- 绿色圆点和“半价”：当前为空闲时段。
- 红色圆点和“未优惠”：当前为高峰时段。
- 红色圆点和“待生效”：峰谷价格尚未开始执行。
- 菜单栏同时显示 Mac 当地时间；所有价格状态均按北京时间计算。

### 2. 运行要求

| 项目 | 要求 |
| --- | --- |
| Mac 芯片 | Apple Silicon（M1、M2、M3、M4 或更新型号），ARM64 |
| 操作系统 | macOS 11.0 或更高版本 |
| Python / Conda | 不需要；当前版本为原生 AppKit 应用 |
| 第三方依赖 | 无 |
| DeepSeek API Key | 不需要 |
| 网络连接 | 日常显示不需要；仅“查看官方价格”需要浏览器联网 |
| 系统权限 | 不需要通知、定位、辅助功能或文件访问权限 |

Intel Mac 无法运行当前 ARM64 版本。

### 3. 启动和使用

1. 在 Finder 中打开 `Documents`。
2. 双击 `DeepSeek优惠时钟.app`。
3. 应用不会显示普通窗口或 Dock 图标；请查看屏幕右上角的菜单栏。
4. 菜单栏项目会显示彩色圆点、状态文字和当地时间，例如：
   - 绿色圆点 `半价 10:25`
   - 红色圆点 `未优惠 10:25`
   - 红色圆点 `待生效 10:25`
5. 点击菜单栏项目，可以查看：
   - 当前价格状态；
   - 距离下一次状态切换的倒计时；
   - Mac 当地时间和北京时间；
   - 北京时间高峰时段；
   - DeepSeek 官方价格页面入口。
6. 如需退出，点击菜单栏项目，然后选择“退出 DeepSeek 优惠时钟”。

### 4. 内置价格时段规则

根据 2026-08-15 核对的 [DeepSeek 官方价格页面](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/)：

- 新峰谷价格从北京时间 **2026-08-17 00:00** 生效。
- 高峰时段为北京时间：
  - **09:00–12:00**；
  - **14:00–18:00**。
- 其余时间均为空闲时段，价格为高峰价格的一半。
- 软件采用半开区间计算：`[09:00, 12:00)` 和 `[14:00, 18:00)`。因此 12:00 和 18:00 整立即变为绿色，09:00 和 14:00 整立即变为红色。
- 生效日期之前显示红色“待生效”。

判断始终使用 `Asia/Shanghai`（北京时间），不受 Mac 所在国家、当前时区或夏令时影响。菜单栏时钟仍显示 Mac 的当地时间。

> DeepSeek 可能调整价格政策。本应用不会自动下载新规则；如官方页面发生变化，需要更新应用中的内置时段。

### 5. 开机自动运行（可选）

应用默认不会开机自启。如需登录后自动启动：

1. 打开“系统设置”。
2. 进入“通用”→“登录项与扩展”。
3. 在“登录时打开”区域点击 `+`。
4. 选择 `Documents/DeepSeek优惠时钟.app`。

这一步会修改 macOS 的登录项设置，只有在你主动操作后才会发生。

### 6. 隐私和文件行为

- 应用不要求或读取 DeepSeek API Key。
- 应用不收集、保存或上传用户数据。
- 应用不保存配置，不修改现有用户文件。
- 应用不会自动联网或自动更新。
- 只有点击“查看 DeepSeek 官方价格”时，系统才会调用默认浏览器；浏览器本身可能保存历史记录或缓存。

### 7. 故障排查

**双击后看不到窗口**  
这是正常行为。当前版本只显示在菜单栏，不显示普通窗口或 Dock 图标。

**菜单栏没有出现应用**  
菜单栏空间不足时，项目可能被刘海或其他图标隐藏。请退出不需要的菜单栏应用，或减少菜单栏项目后重新打开本应用。

**macOS 阻止首次打开**  
此应用为本机编译并使用本地签名，没有经过 Apple Developer ID 公证。如出现安全提示，可在 Finder 中按住 Control 点击应用，选择“打开”，再确认一次。只应对你信任的这份本地应用执行此操作。

**显示的状态似乎不正确**  
先确认 Mac 的日期和时间设置正确，再点击菜单中的官方价格链接核对最新政策。本应用按北京时间判断，而不是按Mac当地时间直接判断。

### 8. 只读自检命令（可选）

在“终端”中运行以下命令可以检查内置边界逻辑，不会修改文件：

```zsh
"~/Documents/DeepSeek优惠时钟.app/Contents/MacOS/DeepSeekDiscountClock" --self-test
```

查看当前判断结果：

```zsh
"~/Documents/DeepSeek优惠时钟.app/Contents/MacOS/DeepSeekDiscountClock" --status
```

### 9. 卸载

先从菜单中退出应用，然后将 `DeepSeek优惠时钟.app` 移到废纸篓。应用没有额外的配置文件需要清理。如已添加为登录项，请同时从“系统设置”中的登录项列表移除。

---

## English

### 1. Purpose

DeepSeek Discount Clock is a macOS menu bar app that shows whether the DeepSeek API is currently in its half-price off-peak period.

- Green dot and “半价”: the off-peak half-price period is active.
- Red dot and “未优惠”: the peak, non-discounted period is active.
- Red dot and “待生效”: the peak/off-peak policy has not taken effect yet.
- The menu bar also shows the Mac's local time. Pricing status is always calculated in Beijing time.

The status labels remain in Chinese to match the app interface.

### 2. System requirements

| Item | Requirement |
| --- | --- |
| Mac processor | Apple Silicon (M1, M2, M3, M4, or newer), ARM64 |
| Operating system | macOS 11.0 or later |
| Python / Conda | Not required; this version is a native AppKit app |
| Third-party dependencies | None |
| DeepSeek API key | Not required |
| Internet connection | Not required for status display; required only to open the official pricing page |
| System permissions | No notification, location, accessibility, or file-access permission required |

The current ARM64 build does not run on Intel Macs.

### 3. Starting and using the app

1. Open `Documents` in Finder.
2. Double-click `DeepSeek优惠时钟.app`.
3. The app does not open a regular window or display a Dock icon. Look for it on the right side of the macOS menu bar.
4. The menu bar item displays a colored dot, a status label, and local time, for example:
   - Green dot: `半价 10:25` — half price.
   - Red dot: `未优惠 10:25` — not discounted.
   - Red dot: `待生效 10:25` — policy pending.
5. Click the menu bar item to view:
   - the current pricing status;
   - the countdown to the next state change;
   - local Mac time and Beijing time;
   - the Beijing-time peak schedule;
   - a link to DeepSeek's official pricing page.
6. To quit, click the menu bar item and choose “退出 DeepSeek 优惠时钟”.

### 4. Built-in pricing schedule

According to the [official DeepSeek pricing page](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/), checked on 2026-08-15:

- The new peak/off-peak pricing takes effect at **2026-08-17 00:00 Beijing time**.
- Peak periods in Beijing time are:
  - **09:00–12:00**;
  - **14:00–18:00**.
- All other times are off-peak, with prices at half the peak rate.
- The app uses half-open intervals: `[09:00, 12:00)` and `[14:00, 18:00)`. It therefore turns green exactly at 12:00 and 18:00, and red exactly at 09:00 and 14:00.
- Before the effective date, the app shows the red “待生效” status.

All decisions use `Asia/Shanghai` time, regardless of the Mac's country, local time zone, or daylight-saving rules. The clock shown in the menu bar remains the Mac's local time.

> DeepSeek may revise its pricing policy. The app does not download policy updates automatically. If the official policy changes, the built-in schedule must be updated.

### 5. Launch at login (optional)

The app does not start automatically by default. To launch it after login:

1. Open System Settings.
2. Go to General → Login Items & Extensions.
3. Under Open at Login, click `+`.
4. Select `Documents/DeepSeek优惠时钟.app`.

This changes the macOS login-items setting only when you perform these steps yourself.

### 6. Privacy and file behavior

- The app neither requests nor reads a DeepSeek API key.
- It does not collect, store, or upload user data.
- It does not save preferences or modify existing user files.
- It makes no automatic network requests and has no automatic updater.
- Clicking “查看 DeepSeek 官方价格” opens the default browser. The browser may maintain its own history or cache.

### 7. Troubleshooting

**No window appears after double-clicking**  
This is expected. The current version appears only in the menu bar and has no regular window or Dock icon.

**The menu bar item is missing**  
If menu bar space is limited, the item may be hidden behind the display notch or other icons. Quit unnecessary menu bar apps or reduce the number of menu bar items, then reopen this app.

**macOS blocks the first launch**  
This app was compiled locally and uses a local ad-hoc signature; it is not notarized with an Apple Developer ID. If macOS shows a security warning, Control-click the app in Finder, choose Open, and confirm. Do this only for this local copy if you trust it.

**The displayed status seems incorrect**  
Confirm that the Mac's date and time are correct, then use the official pricing link in the menu to check the latest policy. The app evaluates Beijing time rather than directly applying Mac local clock hours.

### 8. Read-only diagnostics (optional)

Run the following command in Terminal to test all built-in boundary cases. It does not modify files:

```zsh
"~/Documents/DeepSeek优惠时钟.app/Contents/MacOS/DeepSeekDiscountClock" --self-test
```

Print the current evaluated status:

```zsh
"~/Documents/DeepSeek优惠时钟.app/Contents/MacOS/DeepSeekDiscountClock" --status
```

### 9. Uninstalling

Quit the app from its menu, then move `DeepSeek优惠时钟.app` to the Trash. There are no additional preference files to remove. If you added the app as a login item, remove it from the Login Items list in System Settings as well.

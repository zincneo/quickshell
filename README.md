# quickshell

个人 [Quickshell](https://quickshell.outfoxxed.me/) 配置，包含一个自建的 `Blobs`
QML 插件（SDF "metaball" 渲染），用于让面板从窗口边框**无缝生长**出来。

## 目录结构

| 路径 | 说明 |
| --- | --- |
| `shell.qml` | Quickshell 入口 |
| `windows/`, `components/`, `themes/` | QML 界面代码 |
| `codes/` | 插件 **源码**：每个插件一个子目录 `codes/<Name>/`（含各自的 `CMakeLists.txt`）。现有 `codes/Blobs/`（边框融合）、`codes/M3Shapes/`（Material 形状，移植自 soramanew/m3shapes） |
| `codes/<Name>/build/` | CMake 构建中间产物（**gitignore**） |
| `plugin/<Name>/` | `just build` 生成的**插件产物**：`qmldir` + `.so` + `.qmltypes`（**gitignore**） |
| `services/` | QML 单例服务：`Time`/`SysInfo`/`SysUsage`/`Weather` |
| `justfile` | 构建任务 |
| `flake.nix` | 提供构建工具链的 `nix develop` 环境 |
| `caelestia-ref/` | 参考仓库，不追踪（**gitignore**） |

运行时把 **`plugin/`** 加入 QML import path，即可 `import Blobs`。

## 构建

需要 `just` 与 Nix（flake 已配好 Qt 工具链；编译都在 `nix develop` 内进行）。

```sh
just build     # 编译并把必要文件安装到 plugin/Blobs
just clean     # 删除 codes/build 与 plugin/Blobs
just run       # 本地调试运行（临时设置 import path 启动 quickshell）
```

改了 `codes/` 下的 C++/着色器后重新 `just build` 即可；改 QML 文件 quickshell 会自动热重载。

## 让 systemd 服务加载插件

`programs.quickshell`（home-manager）生成的 `quickshell.service` 默认没有 QML
import path。在 home-manager 配置中给该服务追加环境变量，指向本仓库的 `plugin/`：

```nix
# 函数参数需要 config
systemd.user.services.quickshell.Service.Environment = [
  "QML2_IMPORT_PATH=${config.home.homeDirectory}/.config/quickshell/plugin"
];
```

随后：

```sh
sudo nixos-rebuild switch      # 或 home-manager switch
systemctl --user restart quickshell
```

> 前提：已先 `just build` 把插件生成到 `plugin/Blobs`。插件 `.so` 的依赖全部指向
> Nix store（rpath 已 baked），无系统库依赖；后端库通过 `$ORIGIN` 就近解析。

## 边框弹出面板（Popout）

`components/Popout.qml` 是通用的「从边框生长出来」的弹出面板：融合边固定贴住边框（并向边框内微量 `overlap` 确保 SDF 融合），面板沿 `edge` 的垂直方向从 0 生长到满尺寸，收起时缩成边框处一条缝——动画全程与边框无缝、无空隙。

用法：实例化并传入共享图层与几何即可。

```qml
Popout {
    blobLayer: blobLayer        // 放 BlobGroup/BlobInvertedRect 的层
    group: blobGroup            // 与边框共用的 BlobGroup（决定融合）
    overlayLayer: overlayLayer  // 阴影之上的清晰内容层
    edge: "left"               // left/right/top/bottom：贴哪条边、往反方向生长
    expandedX: ...; expandedY: ...; expandedWidth: ...; expandedHeight: ...
    openDuration: 260          // 动画时长
    triggerZone: Qt.rect(...)  // 悬停触发区（通常落在边框上）
    // 这里写面板内容（子项）
}
```

- 让某条相邻边与边框内缘齐平即可实现**角融合**（如左+下角）。
- 窗口 `mask` 需为每个 popout 追加一块它的当前区域（`popout.px/py/gw/gh`），hover 才能保持展开。

`components/PopoutDemo/` 下有 **8 个演示**，覆盖全部融合/方向组合（不同位置、大小、动画速度，内容为空，仅示范用法，实际使用时移除）：

| 文件 | 融合位置 | 展开方向 |
| --- | --- | --- |
| `TopDown.qml` | 顶边 | 向下 |
| `TopLeftRight.qml` | 左上角 | 向右 |
| `LeftRight.qml` | 左边 | 向右 |
| `LeftBottomRight.qml` | 左下角 | 向右 |
| `BottomUp.qml` | 底边 | 向上 |
| `BottomRightLeft.qml` | 右下角 | 向左 |
| `RightLeft.qml` | 右边 | 向左 |
| `RightTopDown.qml` | 右上角 | 向下 |

## 顶部下拉 Dashboard

`components/dashboard/Dashboard.qml` 是顶部正中的下拉面板（基于 `Popout` edge="top"，
从顶边融合下拉），布局参考 caelestia 的 dashboard（标签栏 + 内容）。当前实现了
**Dashboard 标签**（大时钟 + 月历 `CalendarView.qml`），主题用我们自己的 Macchiato；
Media / Performance / Weather 为占位，待接入对应服务后补齐。

### 完整对齐 caelestia 还需安装的依赖（NixOS）

> 这些是 caelestia 运行期依赖/字体，按需在系统配置里安装；没有也不影响当前的
> 时钟+月历（它们只用 Nerd Font，纯 QML）。

字体（最影响观感，用于图标与排版）：

```nix
fonts.packages = with pkgs; [
  material-symbols            # 图标（MaterialIcon）
  rubik                       # UI 字体
  nerd-fonts.caskaydia-cove   # 等宽（或继续用现有的 Iosevka Nerd Font）
];
```

各标签内容所需的运行期程序/服务：

| 标签/部件 | 依赖 | 现状 |
| --- | --- | --- |
| Dashboard·Weather | `curl` + 网络（wttr.in） | ✅ 已接 |
| Dashboard·User | `/etc/os-release`、`/proc/uptime`、`XDG_CURRENT_DESKTOP` | ✅ 已接 |
| Dashboard·Resources | `/proc/stat`、`/proc/meminfo`、`df` | ✅ 已接 |
| Dashboard·Media（右侧播放器） | **任一 MPRIS 播放器**在运行（`spotify`/`mpv`(带 mpris)/浏览器/`playerctl` 兼容应用） | ✅ 已接（无播放器则显示 No media） |
| 头像 | `~/.face` 图片 | 放一张即可 |
| Media 节拍可视化（bongocat） | `cava`、`aubio`、`pipewire` | ⬜ 待接 |
| Performance 标签 | CPU/GPU 传感器、内存与存储 | ✅ 已接 |

工作区入口位于左侧栏：按当前屏幕每组显示最多 5 个工作区，每区最多显示 5 个窗口图标，超出显示 `+N`。悬停后从左上角展开工作区面板，与顶部和左侧边框融合；面板可切换全部工作区并滚动查看、聚焦全部窗口。顶部 Dashboard 仅保留 Dashboard、Media、Performance 三个标签。

> **音乐播放器（右侧面板）**：用的是 Quickshell 内置的 `Quickshell.Services.Mpris`，
> **不需要额外安装包**，但需要有一个正在运行的 MPRIS 播放器才能显示（封面/标题/
> 上一首·播放·下一首）。例如安装并运行 `spotify`，或 `mpv --idle`（它自带 MPRIS），
> 或任意支持 MPRIS 的浏览器/音乐软件。可选装 `playerctl` 便于调试。

> 注：caelestia 的精确 Material 形状（头像 Pill、今天指示器等）来自其 `M3Shapes`
> C++ 插件；如需完全一致，可像 `Blobs` 一样把它单独编译进来（告诉我即可）。

## 许可

`codes/Blobs/` 的算法与着色器改编自
[caelestia-dots/shell](https://github.com/caelestia-dots/shell)（GPL-3.0），
分发需遵守 GPL-3.0。

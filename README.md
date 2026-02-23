# VTS - Voice Typing Studio

<p align="center">
  <img src="public/logo_new.svg" alt="VTS Logo" width="150">
  <br>
  <strong>等待已久的 macOS 开源语音输入工具！🚀</strong>
  <br>
  <em>v1.5.6 - 品牌全面升级 & 极致权限修复</em>
</p>

---

<p align="center">
  <a href="https://github.com/Feng-H/VTS-silliconflow/releases/latest">
    <img src="https://img.shields.io/badge/📦%20下载%20DMG-最新版本-brightgreen?style=for-the-badge&logo=apple&logoColor=white&labelColor=000000&color=007ACC" alt="下载 DMG" width="300">
  </a>
</p>

<p align="center">
  <strong>或者使用 Homebrew 安装：</strong>
</p>

```bash
brew install Feng-H/tap/vts
```

**更新到最新版本：**

```bash
brew update && brew upgrade vts
```

> ⚠️ **安装提示**：由于本项目采用开源签名方式，首次打开时若提示 **"无法验证开发者"** 或 **"应用已损坏"**：
> 1. 请将 VTS 拖入 **"应用程序" (Applications)** 文件夹
> 2. 在"应用程序"中找到 VTS，**右键点击图标**，选择 **"打开"**
> 3. 在弹出的对话框中点击 **"打开"** 即可

---

利用 **SiliconFlow (硅基流动)** 和 **BigModel (智谱 AI)** 的强大能力，让你的声音瞬间变成文字。告别 macOS 自带听写的限制，体验闪电般快速、精准的转写体验，还支持自定义全局快捷键！⚡️

## ✨ 为什么选择 VTS?

- 🤖 **AI 驱动的高精度**: 使用 SiliconFlow 和 BigModel 的顶尖模型，识别率远超系统自带功能
- 🧠 **Typeless 风格润色**: 内置 LLM 文本润色功能，自动去除语气词、修正逻辑，甚至将口语转换为正式书面语
- 🎯 **应用感知模式**: 根据当前使用的应用（Xcode, WeChat, Mail等）自动调整润色风格，更懂你的语境
- 🛠️ **一键权限修复**: 针对 macOS 升级后权限失效的顽疾，提供一键重置功能，告别繁琐设置
- 🔑 **你掌握控制权**: 使用你自己的 API Key，无需订阅，没有任何限制
- ⌨️ **按住说话**: 按住 **右侧 Command (⌘)** 键立即开始录音，松开即识别
- 🔓 **100% 开源**: 完全透明，社区驱动，随心修改

## 🆕 v1.5.6 新功能

### 🪄 一键修复权限 (One-Click Fix)
针对 macOS 更新后常见的“辅助功能权限失效”问题，新版本在修复页面提供了一个蓝色大按钮。只需点击一下，App 会自动重置权限库并引导你重新勾选，无需再手动删除和添加应用。

### 🌍 环境感知润色 (App-Aware)
VTS 现在能识别你正在哪个 App 中输入：
- **Xcode / VS Code**: 保护代码术语，仅修正注释拼写
- **WeChat / Slack**: 保持自然口语，仅移除“额、那个”
- **Mail / Word**: 自动切换为商务正式风格

### 🧹 增强型语气词过滤
升级了正则过滤引擎，能瞬间移除重复词（如“我我我”、“那个那个”）和复杂的口癖，大幅降低上屏延迟。

### 🎨 品牌视觉重塑
全新的 Logo 设计，融合了声音波束与输入光标的理念，带来更现代、更简约的视觉体验。

---

## 🛠️ 如何开始

### 1. 获取 API Key
安装 VTS 后，你需要从以下任一服务商获取 API Key（只需一个）：
- **SiliconFlow (硅基流动)**: [点击获取 Key](https://cloud.siliconflow.cn/account/ak)
- **BigModel (智谱 AI)**: [点击获取 Key](https://open.bigmodel.cn/usercenter/apikeys)

### 2. 软件设置
1. **选择服务商**: 在下拉菜单中选择 SiliconFlow 或 BigModel
2. **选择模型**: 选择你想使用的模型（例如 SenseVoiceSmall, glm-4-voice）
3. **输入 Key**: 将 API Key 粘贴到输入框中保存
4. **开始使用**: 将光标放在任何输入框中，按住 **右侧 Command (⌘)** 键说话
5. **完成**: 松开按键，文字会自动上屏

## 常见问题

- **无法输入文字？**
  - 这是由于 macOS 的安全机制重置了权限。请打开 VTS 设置 > **Permissions** 页面，点击 **"One-Click Fix"** 蓝色按钮，然后在弹出的系统设置中重新勾选 VTS 即可。
- **听不到声音/没反应？**
  - 检查 **系统设置 > 隐私与安全性 > 麦克风** 权限是否已授予。
  - 在 VTS 设置的麦克风选项卡中点击"刷新"，确保选中了正确的设备。

## 🔒 隐私安全

- **不存储音频**: 音频实时处理，绝不保存到本地
- **Key 安全存储**: API Key 存储在 macOS 钥匙串 (Keychain) 中
- **加密传输**: 所有 API 通信均使用 HTTPS 加密
- **无遥测收集**: 完全离线运行，不收集任何使用数据

## ❤️ 致谢与说明

本项目 Optimized & Maintained by **Feng-H**。
基于 [j05u3/VTS](https://github.com/j05u3/VTS) 开发，感谢原作者的杰出工作！

### 参与贡献
如果你有任何需求或建议，欢迎提交 [Issue](https://github.com/Feng-H/VTS-silliconflow/issues)。

## 📄 许可证

MIT License - 详情见 [LICENSE](LICENSE) 文件。

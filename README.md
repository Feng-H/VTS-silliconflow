# VTS - Voice Typing Studio

<p align="center">
  <img src="public/logo.png" alt="VTS Logo" width="150">
  <br>
  <strong>等待已久的 macOS 开源语音输入工具！🚀</strong>
</p>
---

利用 **SiliconFlow (硅基流动)** 和 **BigModel (智谱 AI)** 的强大能力，让你的声音瞬间变成文字。告别 macOS 自带听写的限制，体验闪电般快速、精准的转写体验，还支持自定义全局快捷键！⚡️

## ✨ 为什么选择 VTS?

- 🤖 **AI 驱动的高精度**: 使用 SiliconFlow 和 BigModel 的顶尖模型，识别率远超系统自带功能
- 🔑 **你掌握控制权**: 使用你自己的 API Key，无需订阅，没有任何限制
- 🔄 **无缝替代**: 像原生听写一样工作，但更强大
- ⌨️ **按住说话**: 按住 **右侧 Command (⌘)** 键立即开始录音，松开即识别
- 🎯 **智能麦克风管理**: 自动选择最佳麦克风，支持无缝切换
- 💬 **上下文感知**: 支持自定义系统提示词 (Prompt)，让 AI 更懂你的专业术语
- 🔓 **100% 开源**: 完全透明，社区驱动，随心修改

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
  - 请检查 **系统设置 > 隐私与安全性 > 辅助功能**，确保 VTS 已开启。如果已经开启但无效，请尝试删除后重新添加。
- **听不到声音/没反应？**
  - 检查 **系统设置 > 隐私与安全性 > 麦克风** 权限是否已授予。
  - 在 VTS 设置的麦克风选项卡中点击“刷新”，确保选中了正确的设备。

## 🔒 隐私安全

- **不存储音频**: 音频实时处理，绝不保存到本地
- **Key 安全存储**: API Key 存储在 macOS 钥匙串 (Keychain) 中
- **加密传输**: 所有 API 通信均使用 HTTPS 加密

## ❤️ 致谢与说明

本项目 Fork 自 [j05u3/VTS](https://github.com/j05u3/VTS)，特别感谢原作者的杰出工作！

为了让应用更加轻量和纯净，我在本项目中**移除了**以下模块：
- **使用调研 (Telemetry)**
- **升级提醒 (Sparkle Update)**

这使得安装包体积更小，且完全专注于核心功能。

### 参与贡献
如果你有任何需求或建议，欢迎提交 [Issue](https://github.com/Feng-H/VTS-silliconflow/issues)。

当然，也非常欢迎你 **Fork** 本项目，开始你的 **Vibe Coding**，手搓一个最适合你自己的语音输入工具！

## 📄 许可证

MIT License - 详情见 [LICENSE](LICENSE) 文件。

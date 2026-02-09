# VTS - Voice Typing Studio

<p align="center">
  <img src="public/logo.png" alt="VTS Logo" width="150">
  <br>
  <strong>等待已久的 macOS 开源语音输入工具！🚀</strong>
  <br>
  <em>v1.4.0 - 全新 Typeless 风格功能</em>
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

> ⚠️ **安装提示**：由于本项目采用开源签名方式，首次打开时若提示 **"无法验证开发者"** 或 **"应用已损坏"**：
> 1. 请将 VTS 拖入 **"应用程序" (Applications)** 文件夹
> 2. 在"应用程序"中找到 VTS，**右键点击图标**，选择 **"打开"**
> 3. 在弹出的对话框中点击 **"打开"** 即可

---

利用 **SiliconFlow (硅基流动)** 和 **BigModel (智谱 AI)** 的强大能力，让你的声音瞬间变成文字。告别 macOS 自带听写的限制，体验闪电般快速、精准的转写体验，还支持自定义全局快捷键！⚡️

## ✨ 为什么选择 VTS?

- 🤖 **AI 驱动的高精度**: 使用 SiliconFlow 和 BigModel 的顶尖模型，识别率远超系统自带功能
- 🧠 **智能润色**: 内置 LLM 文本润色功能，自动去除语气词、修正逻辑，甚至将口语转换为正式书面语
- 🔑 **你掌握控制权**: 使用你自己的 API Key，无需订阅，没有任何限制
- 🔄 **无缝替代**: 像原生听写一样工作，但更强大
- ⌨️ **按住说话**: 按住 **右侧 Command (⌘)** 键立即开始录音，松开即识别
- 🎯 **智能麦克风管理**: 自动选择最佳麦克风，支持无缝切换
- 💬 **上下文感知**: 支持自定义系统提示词 (Prompt)，让 AI 更懂你的专业术语
- 🔓 **100% 开源**: 完全透明，社区驱动，随心修改

## 🆕 v1.4.0 新功能

本版本带来了 **Typeless 风格** 的全新功能，大幅提升听写体验：

### 🧹 填充词自动移除
自动过滤口语中的填充词，如 "um"、"uh"、"那个"、"额"、"嗯" 等，让转录文本更加干净流畅。支持三级强度调节：
- **最小**: 仅移除明显的犹豫声（um, uh, 额, 嗯）
- **适中**: 移除常见填充词和短语
- **激进**: 移除所有检测到的填充词

### 🎤 语音命令支持
通过语音插入标点和格式：
| 语音命令 | 效果 |
|---------|------|
| "逗号" / "comma" | 插入 ， |
| "句号" / "period" | 插入 。 |
| "问号" / "question mark" | 插入 ？ |
| "新段落" / "new paragraph" | 换行 |
| "引号" / "quote" | 插入 「 」 |

### 🌍 多语言混合识别
支持 6 种语言选项：
- 自动检测
- 中文 / 英文 / 中英混合
- 日语 / 韩语

### 📚 个人词典
添加专业术语、人名、品牌名，确保正确识别。支持分类管理和 JSON 导入导出。

### 🎯 应用感知模式
根据当前使用的应用自动调整润色风格：
- **邮件应用** → 正式商务风格
- **微信/Slack** → 轻松口语风格
- **Xcode/VS Code** → 技术精准风格

### 📜 听写历史记录
本地保存所有听写记录，支持：
- 按日期筛选和搜索
- 使用统计（频率、应用分布）
- 导出 CSV / JSON

### 🔒 隐私保障
在设置页明确展示隐私承诺：
- ✅ 不存储语音录音和转录文本
- ✅ API Key 安全存储在 macOS 钥匙串
- ✅ 无遥测数据收集

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
6. **(可选) 开启润色**: 在设置的 "Speech" 页面开启 "Intelligent Refinement"，让 AI 帮你自动优化文本

## 常见问题

- **无法输入文字？**
  - 请检查 **系统设置 > 隐私与安全性 > 辅助功能**，确保 VTS 已开启。如果已经开启但无效，请尝试删除后重新添加。
- **听不到声音/没反应？**
  - 检查 **系统设置 > 隐私与安全性 > 麦克风** 权限是否已授予。
  - 在 VTS 设置的麦克风选项卡中点击"刷新"，确保选中了正确的设备。

## 🔒 隐私安全

- **不存储音频**: 音频实时处理，绝不保存到本地
- **Key 安全存储**: API Key 存储在 macOS 钥匙串 (Keychain) 中
- **加密传输**: 所有 API 通信均使用 HTTPS 加密
- **无遥测收集**: 完全离线运行，不收集任何使用数据

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

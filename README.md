# my-claude-best-practices

> 🎨 我的 Claude Code 最佳实践配置 - 10 个实用技巧一键安装，让 Claude Code 发挥 100% 潜力

这是一份源自个人日常使用总结的 Claude Code 配置优化清单，通过 Claude Code 插件形式分发，**支持一键自动配置**所有推荐优化项。

## 🚀 功能特性

| 功能 | 状态 | 说明 |
|------|------|------|
| 📊 **上下文压缩阈值优化** | ✅ 自动配置 | 设置为 75%，防止 AI 在长对话中"失忆" |
| 📝 **CLAUDE.md 规则指南** | 📖 文档 | 教你如何通过 CLAUDE.md 控制 AI 行为 |
| 🎨 **代码自动格式化** | ✅ 内置脚本 | 支持多语言（JS/TS/Python/Go/Java/...）自动格式化 |
| 😄 **自定义中文 Spinner** | ✅ 自动配置 | 用中文提示词替换默认英文，等待更有趣 |
| 🔔 **任务完成自动通知** | ✅ 自动配置 | AI 完成任务后发送桌面通知，支持异步工作流 |
| 🎯 **设置 AI 输出风格** | 📖 文档 | 教你设置输出风格匹配工作节奏 |
| 🧹 **去掉 Git 联合署名** | ✅ 自动配置 | 禁用 Co-authored-by，保持提交历史纯净 |
| 🖥️ **Claude HUD 集成** | ✅ 自动安装 | 美观实用的状态仪表盘，显示上下文使用情况 |
| 🧠 **Claude-Mem 记忆** | ✅ 自动安装 | 跨会话持久化记忆，AI 记得你们聊过什么 |
| ⚡ **Code-Simplifier Agent** | ✅ 自动配置 | 官方代码简化专家，自动优化代码质量 |

## 📥 安装

### 从 GitHub 安装（推荐）

```
/plugin marketplace add xiaodizi/my-claude-best-practices
/plugin install my-claude-best-practices
```

### 从本地安装（开发）

```bash
git clone https://github.com/xiaodizi/my-claude-best-practices.git
cd my-claude-best-practices
/plugin install ./claude-best-practices
```

## ⚡ 快速开始

安装完成后，**只需两步**：

```bash
# 1. 一键自动配置所有推荐设置
/my-claude-best-practices:setup

# 2. 配置 Claude HUD
/claude-hud:setup
```

然后**重启 Claude Code**，所有优化就生效了！ 🎉

## 📖 文档

安装完成后，随时可以查看完整的最佳实践指南：

```
/my-claude-best-practices
```

指南包含了每个配置的原理说明，帮助你理解为什么要这么配置。

## ✨ 特性说明

### 自动安装依赖插件

安装 `my-claude-best-practices` 时，Claude Code 会**自动安装**：
- [claude-hud](https://github.com/jarrodwatts/claude-hud) - 美观的状态仪表盘
- [claude-mem](https://github.com/thedotmack/claude-mem) - 跨会话持久化记忆

### 自动配置项目

一键 `setup` 会自动帮你配置：
- 上下文压缩阈值设置为推荐值 75%
- 禁用 Git 提交的 Co-authored-by 自动署名
- 配置优雅的中文 Spinner 提示词
- 添加任务完成桌面通知（macOS）
- 配置 code-simplifier Agent

### 内置多语言格式化脚本

插件内置了文档推荐的 `format-code.sh` 智能调度脚本，支持多种编程语言自动格式化。你可以直接复制到你的项目中使用。

## 📝 手动配置可选

如果你不想自动配置，也可以按照文档中的指南，手动选择性应用你喜欢的配置。

## 👨‍💻 作者

lei.fu ([@xiaodizi](https://github.com/xiaodizi))

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- [Claude HUD](https://github.com/jarrodwatts/claude-hud) by @jarrodwatts
- [Claude Mem](https://github.com/thedotmack/claude-mem) by @thedotmack
- Claude Code 团队做出了这么棒的工具 👍

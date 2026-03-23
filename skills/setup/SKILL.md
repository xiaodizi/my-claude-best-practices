---
name: my-claude-best-practices:setup
description: 一键自动配置 Claude Code 最佳实践 - 包括上下文压缩阈值、Git 署名清理、自定义 spinner 等
---

# my-claude-best-practices:setup

一键自动配置文档中推荐的所有 Claude Code 最佳实践设置。

## 功能

这个命令会自动帮你配置：

1. **上下文压缩阈值**：设置为 75%（推荐值），防止 AI 在长对话中失忆
2. **去掉 Co-authored-by**：禁用自动添加 Git 联合署名，保持提交历史纯净
3. **自定义中文 Spinner**：用中文提示词替换默认的英文动词，等待更有趣
4. **任务完成自动提醒**：AI 完成任务后发送桌面通知，支持异步工作流
5. **code-simplifier Agent**：配置官方的代码简化 Agent，自动优化代码质量

## 执行

现在开始执行自动配置...

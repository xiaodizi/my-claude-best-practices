---
name: my-claude-best-practices:setup
description: 一键自动配置 Claude Code 最佳实装 - 包括上下文压缩阈值、Git 署名清理、自定义 spinner 等
---

# my-claude-best-practices:setup

一键自动配置文档中推荐的所有 Claude Code 最佳实装配置。

## 功能

这个命令会自动帮你配置：

1. **上下文压缩阈值**：设置为 75%（推荐值），防止 AI 在长对话中失忆
2. **去掉 Co-authored-by**：禁用自动添加 Git 联合署名，保持提交历史干净
3. **自定义中文 Spinner**：用中文提示词替换默认的英文动词，等待更有趣
4. **任务完成自动提醒**：AI 完成任务后发送桌面通知，支持异步工作流
5. **code-simplifier Agent**：配置官方的代码简化 Agent，自动优化代码质量
6. **关闭 Auto Memory（可选）**：优先推荐通过在 `~/.claude/settings.json` 的 `env` 段设置 `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` 来禁用 Claude Code 的内置 Auto Memory，避免与 claude-mem 插件重复注入上下文（这是最可靠的方式）。

在执行前会展示将写入的 JSON 片段，让用户确认（合并不覆盖）。

## 执行

运行此命令将以交互式方式询问你上面各项的开关与参数，随后：

- 我们会先展示要写入到 `~/.claude/settings.json` 的 JSON 片段；
- 你确认后我们会把片段“合并（merge）”到现有 settings 而不是覆盖整个文件；
- 如果你启用了“关闭 Auto Memory”选项，预览中会优先包含：

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1"
  }
}
```

> 说明：推荐做法是只通过设置 `env.CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` 来禁用内置 Auto Memory；在某些旧版本或边缘场景下，你也可以同时在 settings 中把 `"autoMemoryEnabled": false`（次选）以双保险方式设置，但 `env` 是首选且优先级更高。

### 如何手动关闭 Auto Memory（给关注细节的用户）

如果你想手工验证或手动关闭（不通过 setup）：

1. 打开设置文件：`~/.claude/settings.json`。
2. 在 `env` 段添加或确认：

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1"
  }
}
```

3. （可选）如果你希望额外变更，可以在同一文件中添加：

```json
{
  "autoMemoryEnabled": false
}
```

但请注意：在多数现代部署中，`env` 的方式足够且更可靠。

4. 重启 Claude Code 客户端以使设置生效。

> 另一种可视化方式：在 Claude Code 中运行 `/config`，进入 Context/Memory 设置页面，将 "Auto Memory / Auto‑inject" 的开关关闭，然后重启客户端（某些版本的 UI 选项可能不同）。

## 注意事项

- setup 不会在未征得你同意的情况下自动安装系统级依赖（如 go、black、google-java-format）；脚本会提示并给出安装命令。脚本示例见 `scripts/format-code.sh`。
- 我们遵循“先展示 → 用户确认 → 合并不覆盖”的原则，保证不会意外覆盖你的全局配置。


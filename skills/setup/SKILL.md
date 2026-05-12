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
7. **配置全局 CLAUDE.md（可选）**：将 Karpathy 的“编程四大原则”合并进全局 `~/.claude/CLAUDE.md`（若文件存在则追加/合并不删除原有内容；若不存在则创建）。

在执行前会展示将写入的 JSON 片段和/或将要合并的 CLAUDE.md 片段，让用户确认（合并不覆盖）。

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

### 一键配置全部选项（Configure all）

- 在交互开始时，setup 会提供三个模式供选择：
  1. 逐项选择（默认） — 逐条询问每个选项；
  2. 一键配置全部选项（Configure all） — 以推荐值预选所有可配置项并生成合并预览；
  3. 取消 — 退出不作任何变更。

- 如果选择“一键配置全部选项”，setup 会采用下列推荐默认值为预选项并合成一份合并预览：
  - 上下文压缩阈值：75%
  - 去掉 Co-authored-by：是（将 attribution.commit/pr 置空）
  - 自定义中文 Spinner：启用（替换 spinnerVerbs）
  - 任务完成自动提醒（Stop hook）：启用（建议 terminal-notifier / osascript）
  - code-simplifier Agent：启用并添加到 agents 列表
  - 关闭 Auto Memory：**若检测到 claude-mem 已安装，则默认勾选；否则保持为未勾选（仍向用户显示并可手动切换）**
  - 配置全局 CLAUDE.md：默认不自动添加（保持用户选择），但若用户选择“一键配置全部并包含 CLAUDE.md”，将把 Karpathy 四大原则合并到 `~/.claude/CLAUDE.md`（见下文）。

- 预览会以可编辑的 JSON 片段和 CLAUDE.md 合并预览形式显示，用户可以在确认前修改某些字段（例如 auto-compact 百分比或是否启用某个 hook）。所有写入行为仍遵循“先展示 → 用户确认 → 合并不覆盖”。

### 配置全局 CLAUDE.md（可选）

- 行为概述：当用户选择启用“配置全局 CLAUDE.md”时，setup 会：
  1. 检查 `~/.claude/CLAUDE.md` 是否存在；
  2. 读取现有内容（若存在），在合并前展示合并预览；
  3. 如果现有文件已包含相同的 Karpathy 文本（通过查找首行或特定标识串），则不重复添加；否则在文件末尾追加一个分隔头并插入 Karpathy 四大原则文本块；
  4. 在用户确认后写入（或创建） `~/.claude/CLAUDE.md`，绝不删除或截断原有内容，只做追加/合并操作。

- 合并示例预览：

```markdown
# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.


**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
```

- 额外说明：setup 会在预览中高亮指出“此次合并将向 CLAUDE.md 追加 Karpathy 四大原则内容；若你本地已有类似内容，系统会尝试检测并避免重复”。

### 如何手工合并（命令行 / 手动）

如果你想手动合并，而不通过 setup：

```bash
# 将 Karpathy 原文追加到全局 CLAUDE.md
cat >> ~/.claude/CLAUDE.md <<'EOF'
Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.
EOF
```

- 写入行为仍遵循：展示合并预览 → 用户确认 → 备份原文件（如果存在）→ 写入（append/merge）。

## 运行结束后的自动提示（检测 claude-mem）

- 如果 setup 在运行时检测到系统或 `~/.claude/settings.json` 的 `enabledPlugins` 中包含 `claude-mem`（例如 `"claude-mem@thedotmack": true`）或检测到本地目录 `~/.claude-mem`，在完成配置后会显示一条交互式提示：

  > 检测到 claude-mem 已安装。claude-mem 提供持久化、跨会话的记忆功能，为避免与 Claude Code 内置的 Auto Memory 重复注入上下文，建议禁用内置 Auto Memory。是否现在禁用？（是 / 否）

- 若用户选择“是”，setup 会合并以下片段到 `~/.claude/settings.json`（合并不覆盖）：

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1"
  }
}
```

- 作为可选的双保险，setup 会询问用户是否也要将 `"autoMemoryEnabled": false` 写入 settings（次选），若确认也会合并该片段：

```json
{
  "autoMemoryEnabled": false
}
```

- 提示会同时显示当前 settings 中 `autoMemoryEnabled` 的值与 `env.CLAUDE_CODE_DISABLE_AUTO_MEMORY` 是否已存在，便于用户做出决定。

## 注意事项

- setup 不会在未征得你同意的情况下自动安装系统級依赖（如 go、black、google-java-format）；脚本会提示并给出安装命令。脚本示例见 `scripts/format-code.sh`。
- 我们遵循“先展示 → 用户确认 → 合并不覆盖”的原则，保证不会意外覆盖你的全局配置。


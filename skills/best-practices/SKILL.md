---
name: my-claude-best-practices
description: Claude Code 最佳实践配置指南 - 10个提升效率的实用技巧，帮你发挥 Claude Code 的全部潜力
---

# Claude Code 最佳实践

这是一份总结了个人日常使用 Claude Code 经验的配置技巧清单，目标是让这个强大的工具发挥出 100% 的潜力。

---

# 一、默认设置：上下文压缩阈值，正在拖慢你的 AI

> **为什么这个设置很重要？**
> 这个设置决定了AI何时开始压缩其"短期记忆"（上下文窗口）。默认值（95%）太高，AI在开始压缩时可能已经忘记了对话早期的关键信息，导致后续回答质量下降。
>
> 将阈值调低（如75%）能促使AI更早、更主动地整理对话，保持对全局上下文更稳定的理解。对于复杂的编程任务，这是一个能显著提升AI表现和稳定性的关键优化，强烈建议设置。

Claude的上下文窗口就是它的工作记忆。填满之后，它会开始遗忘早期的细节，输出质量悄悄下滑。默认的自动压缩阈值是95%——这时候AI早就已经开始忘记早期内容了。

> **⚠️ 注意：设置方法已变更**
> 以下通过直接设置 `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` 环境变量的方式已经**过时**。虽然下面的例子仍然能够帮助理解其作用，但官方推荐使用新的配置方式。
>
> **当前推荐的方法是使用 `/config` 命令**：
> 1. 在终端输入 `/config`。
> 2. 在交互式菜单中选择 `Context`。
> 3. 选择 `Auto-compact threshold` 并输入你想要的百分比（例如 `75`）。
>
> 这种方法更安全、更直观，并会自动更新到正确的配置文件中。

熟悉的玩家通常会（**旧方法示例**），直接告诉Claude：

```
Set my auto-compact threshold to 75% in my user settings

```

这样，Claude就会自动更新 ~/.claude/settings.json，写入以下配置：

```json
{
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "75"
  }
}
```

推荐范围 60–75%，深度上下文任务可调到 85%。两个配套命令要记住：

- **/clear** 完全清空，切换到全新任务时用
- **/compact** 摘要式压缩，保留关键信息，适合长对话中途调用

还可以在 CLAUDE.md 里告诉Claude压缩时保留什么，比如当前编辑的文件路径、测试失败信息、本次会话的架构决策。

这样 Claude 会提前整理上下文，AI 的理解能力会稳定很多。

---

# 二、真正影响 AI 行为的是 CLAUDE.md

Claude Code 有一个非常重要的文件：

```
CLAUDE.md

```

它的作用类似：**AI 的行为规则。**

CLAUDE.md 就是你和Claude之间的"长期约定"，比任何其他设置对Claude行为的影响都更深远。它跨会话持续生效，每次打开Claude都自动加载。

个人全局配置放在 **~/.claude/CLAUDE.md**，适用于所有项目。直接告诉Claude你的偏好：

```
Create my personal CLAUDE.md at ~/.claude/CLAUDE.md. I prefer pnpm over npm, types over interfaces, Vitest over Jest, and concise PR descriptions.

```

Claude会生成类似这样的文件：

```

# Global preferences

- Use pnpm, not npm
- Prefer types over interfaces
- When writing tests, use Vitest not Jest
- Keep PR descriptions concise — summary + test plan only

```

注意一个关键原则：**控制在 50 行以内。**

研究发现：

- 明确规则 → **89% 执行率**
- 模糊规则 → **35% 执行率**

所以写规则时：

**不要写：**

```
write clean code

```

**要写：**

```
always run tests before committing

```

项目级配置用 /init 命令生成，但默认输出往往过于冗长，记得大幅精简，只保留真正重要的内容。

### 更厉害的 CLAUDE.md 玩法 (思路总结)

文章中提到的方法是基础，但 `CLAUDE.md` 的真正潜力在于将它与其他功能（如自定义输出、Hooks）结合，实现"组合技"。

#### 1. 角色扮演 + 精准指令 (Persona-Driven Behavior)

不只设置偏好，而是给 AI "赋予角色"，让它的行为模式完全改变。

**进阶玩法：** 在 `~/.claude/CLAUDE.md` 中定义一个角色和思考模式。
```markdown
# AI Persona: Senior Security Engineer

- **Your Role:** You are a senior security engineer reviewing code.
- **Primary Focus:** Your main goal is to find vulnerabilities (e.g., injection, XSS, insecure access control).
- **Output Standard:** When you suggest a fix, you must provide a hardened code snippet and explain *why* it's more secure.
- **Tool Preference:** When running a vulnerability scan, use `snyk`; do not use `npm audit`.
```
**效果**：这样一来，AI 在项目中的所有行为都会从一个"安全专家"的视角出发，回答的专业性和针对性会大幅提升。

#### 2. 联动"自定义输出格式" (Structured Output)

用 `CLAUDE.md` 命令 AI 在特定场景下必须使用某种你定义好的格式。

**操作步骤：**
1.  先在 `~/.claude/output-styles/` 目录下创建一个自定义的输出格式文件，例如 `code-review.md`。
2.  然后在项目的 `CLAUDE.md` 里规定：
    ```markdown
    # Project Rules: Code Review

    - When asked to review a file, you **must** use the "Code Review" output style.
    - Do not provide conversational chatter, only the structured output.
    ```

**效果**：强制 AI 在特定任务（如代码评审）下，以我们期望的、机器可读的结构化格式输出，方便后续做自动化处理或生成报告。

#### 3. 场景感知 + 动态规则 (Context-Aware Rules)

让 AI 根据当前的工作目录或文件名，动态切换自己的行为模式。

**示例 `CLAUDE.md`:**
```markdown
# Dynamic Behavior Rules

- **In `src/` directory:** Focus on writing clean, efficient, and well-documented application code.
- **In `tests/` directory:** Your sole purpose is to write and fix tests. Strictly follow existing test patterns. Do not add new application logic.
- **When editing `.md` files:** Act as a technical writer. Focus on clarity, grammar, and formatting.
```
**效果**：AI 变得"会看路"，在项目的不同部分承担不同的职责。

#### 4. "元指令"与自我修正 (Meta-Instructions)

教 AI 在"卡住"的时候该怎么办。

**示例 `CLAUDE.md`:**
```markdown
# Meta-Instructions

- If any instruction is ambiguous or contradicts a previous rule, you **must stop** and ask for clarification.
- List the specific points of ambiguity in a numbered list.
- Before making any destructive change (e.g., deleting a file), you must explain your reasoning and ask for confirmation by saying "Proceed?".
```
**效果**：这大大提升了 AI 的可控性和安全性，让它从一个"莽撞的实习生"变成一个"谨慎的助理"。

---

# 三、每次改代码自动格式化

每次Claude修改文件，你的格式化工具就自动跑一次——代码始终保持整洁，不需要你手动触发。

Claude 修改代码后，可以自动运行：

- Prettier
- ESLint
- Linter

配置一个 Hook 就行。

效果是：

只要 AI 改代码：

**代码立刻自动格式化。**

直接告诉Claude：

```
Set up a PostToolUse hook in the project settings that runs Prettier on any file after you edit or write it

```

这会在项目的 .claude/settings.json 里写入：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

---

### 深度解读：这个功能有必要吗？

它不是"必要"的，但对于追求代码规范和开发效率的团队或个人来说，它**价值很高**。

*   **优点（为什么推荐用）**:
    *   **保证代码风格一致**：AI 生成或修改的代码会自动符合你项目的格式化规范（比如 Prettier, ESLint, Black, gofmt 等）。你不再需要每次都手动去运行格式化命令，省心省力。
    *   **减少无用功**：让你专注于代码的逻辑和功能，而不是花时间在调整缩进、分号这些琐事上。
    *   **干净的提交记录**：避免你的 `git diff` 和提交记录里混入大量无意义的格式调整，让 Code Review 更轻松。

*   **缺点（为什么可以不用）**:
    *   **IDE 可能已实现**：如果你已经在 VS Code 或其他 IDE里配置了"保存时自动格式化"，那么这个功能确实有些重复。但它的优势在于，即使你只在命令行里让 AI 修改了文件，没有在 IDE 里打开，格式化依然会执行，保证了覆盖所有场景。
    *   **需要初始配置**：你需要花几分钟时间去 `.claude/settings.json` 文件里设置它。

**结论**：它属于"改善型"功能，而非"必需型"。如果你非常看重代码风格的统一，或者经常在纯命令行下工作，那么它就非常有价值。

---

### 高级玩法：如何支持多种语言？

文章里的例子只展示了 Prettier，如果你的项目里还有 Python, Go, Java 等，最好的方法是写一个**"调度脚本" (Dispatcher Script)**。

这个方法非常优雅和强大：

1.  **创建一个调度脚本**：
    在你的项目里，比如 `.claude/format-code.sh`，创建一个脚本文件。这个脚本会接收被修改的文件路径作为参数，然后根据文件后缀名调用不同的格式化工具。

    **.claude/format-code.sh (更智能的终极示例)**
    ```bash
    #!/bin/bash

    FILE_PATH="$1" # 接收被修改的文件路径

    # 检查命令是否存在，不存在则给出提示或尝试安装
    # 用法: ensure_command <command_name>
    ensure_command() {
      if ! command -v "$1" &> /dev/null; then
        case "$1" in
          "black")
            echo "Command 'black' not found, attempting to install with pip..."
            pip install black
            ;;
          "shfmt")
            echo "Command 'shfmt' not found, attempting to install with go..."
            # 自动安装 shfmt 需要本地有 Go 环境
            if command -v go &> /dev/null; then
              go install mvdan.cc/sh/v3/cmd/shfmt@latest
            else
              echo "Go is not installed. Please install Go, then run: go install mvdan.cc/sh/v3/cmd/shfmt@latest"
              return 1
            fi
            ;;
          "google-java-format")
            echo "Java formatter 'google-java-format' not found."
            echo "Please download it from https://github.com/google/google-java-format/releases and add it to your PATH."
            return 1
            ;;
        esac
        # 再次检查命令是否成功安装
        if ! command -v "$1" &> /dev/null; then
          echo "Failed to install '$1' automatically. Please install it manually."
          return 1
        fi
      fi
      return 0
    }

    # 使用 case 语句根据文件后缀名，执行不同的格式化命令
    case "$FILE_PATH" in
      *.js|*.ts|*.jsx|*.tsx)
        echo "Formatting JavaScript/TypeScript file..."
        # npx 会在本地或临时环境中查找并执行命令，无需全局安装
        npx prettier --write "$FILE_PATH" 2>/dev/null
        npx eslint --fix "$FILE_PATH" 2>/dev/null
        ;;
      *.py)
        if ensure_command "black"; then
            echo "Formatting Python file..."
            black "$FILE_PATH"
        fi
        ;;
      *.go)
        # gofmt 是 Go SDK 的一部分，通常与 go 命令一起存在
        if command -v gofmt &> /dev/null; then
            echo "Formatting Go file..."
            gofmt -w "$FILE_PATH"
        else
            echo "Command 'gofmt' not found. Please install the Go SDK."
        fi
        ;;
      *.java)
        if ensure_command "google-java-format"; then
            echo "Formatting Java file..."
            google-java-format -i "$FILE_PATH"
        fi
        ;;
      *.sh)
        if ensure_command "shfmt"; then
            echo "Formatting Shell script..."
            shfmt -w "$FILE_PATH"
        fi
        ;;
      *.sql)
        echo "Formatting SQL file..."
        # npx 会自动处理 sql-formatter
        npx sql-formatter -i "$FILE_PATH" 2>/dev/null
        ;;
      *)
        echo "No formatter configured for $FILE_PATH"
        ;;
    esac

    # 始终返回成功，避免阻塞 Claude
    exit 0
    ```
    *别忘了给这个脚本加上执行权限: `chmod +x .claude/format-code.sh`*

2.  **修改 `settings.json` 来调用这个脚本**：
    现在你的 `hooks` 配置就变得非常简洁，它只负责调用上面那个无所不能的调度脚本。

    **.claude/settings.json**
    ```json
    {
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "Edit|Write",
            "hooks": [
              {
                "type": "command",
                "command": "./.claude/format-code.sh \"$CLAUDE_FILE_PATH\""
              }
            ]
          }
        ]
      }
    }
    ```

**这样做的好处**：未来无论你增加多少种语言，都只需要去修改 `format-code.sh` 这个脚本文件，而 `settings.json` 保持不变，非常清晰和易于维护。

---

# 四、自定义等待动词：让枯燥的等待时间变有趣

Claude思考时，终端会显示一个带动词的 spinner，默认是些奇怪的英文词。你可以替换成任何你想看到的内容

Claude 思考时会显示：

```
Thinking...

```

其实你可以自定义这些提示。

直接告诉Claude，比如：

```
Replace my spinner verbs in user settings with these:
正在为你构建未来...
灵感正在迸发...
马上就到，坚持一下...
让魔法发生...
连接智慧的火花...
思考下一个绝妙的点子...
代码正在被赋予生命...
专注创造中...
马上呈现精彩...
组织完美的解决方案...
```

实际上，这会将以下内容添加到 ~/.claude/settings.json 文件中：

```json
{
  "spinnerVerbs": {
    "mode": "replace",
    "verbs": [
      "正在为你构建未来...",
      "灵感正在迸发...",
      "马上就到，坚持一下...",
      "让魔法发生...",
      "连接智慧的火花...",
      "思考下一个绝妙的点子...",
      "代码正在被赋予生命...",
      "专注创造中...",
      "马上呈现精彩...",
      "组织完美的解决方案..."
    ]
  }
}
```

如果你不想自己列清单？还可以直接告诉Claude想要什么风格，让它会帮你生成：

```
换成哈利波特咒语

```

Claude 会为你生成列表。这虽是个小功能，却能让等待更有趣。

你还可以使用 `spinnerTipsOverride` 自定义加载指示器提示（等待时显示的实用提示），并使用 `spinnerTipsEnabled` 启用或禁用它们。

---

# 五、任务完成自动提醒：音效或桌面通知

这个改动能彻底改变你的工作流：启动一个耗时较长的 AI 任务后，你就可以切换去做别的事，等收到提醒后再切回来。从"坐等 AI" 变成 "异步 AI 编程"，解放你的注意力。

这可以通过配置 `Stop` 钩子（Hook）来实现，它会在 AI 完成响应时自动执行一条命令。你有多种选择：

---
### 首选方案：高级桌面通知 (需安装 `terminal-notifier`)

对于习惯静音工作的用户，桌面通知是最佳选择。`terminal-notifier` 是一个功能强大的工具，可以发送带图标、按钮和点击行为的通知。

**1. 安装:**
推荐使用 Homebrew 安装：
```bash
brew install terminal-notifier
```

**2. 配置:**
我最推荐的配置是"点击通知后自动切换回终端"，非常高效。

假设你使用的是 iTerm2，更新你的 `~/.claude/settings.json`：
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "terminal-notifier -title 'Claude Code' -message '任务已完成' -activate 'com.googlecode.iterm2'"
          }
        ]
      }
    ]
  }
}
```
*(如果你用的是系统默认终端，可以将 `com.googlecode.iterm2` 换成 `com.apple.Terminal`)*

---
#### Pro-Tip：如何查找并使用你自己的终端？

上面的例子用了 iTerm2 和系统终端，但如果你在使用其他终端（比如 Warp, Kitty, or Ghostty），要怎么配置呢？

很简单，你只需要找到那个应用的 **Bundle Identifier** (包标识符)。

**查找方法：**
在终端里运行以下命令，把 `应用名称` 换成你的终端名称：
```bash
osascript -e 'id of app "应用名称"'
```

**示例：**
*   查找 **Ghostty** 的 ID:
    ```bash
    osascript -e 'id of app "Ghostty"'
    # 输出: com.mitchellh.ghostty
    ```
*   查找 **Warp** 的 ID:
    ```bash
    osascript -e 'id of app "Warp"'
    # 输出: dev.warp.Warp-Stable
    ```

找到 ID 后，把它替换到 `terminal-notifier` 命令的 `-activate` 参数里就行了。例如，Ghostty 用户的最终配置命令就是：
`terminal-notifier -title 'Claude Code' -message '任务已完成' -activate 'com.mitchellh.ghostty'`

---
### 备选方案 1：基础桌面通知 (系统自带)

如果你不想安装任何额外工具，macOS 自带的 `osascript` 也能发送通知，只是样式比较基础。

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"AI 任务已完成\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

---
### 备选方案 2：声音提醒 (系统自带)

如果你不介意声音，这是最简单直接的方式，也是原文提供的方法。

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "/usr/bin/afplay /System/Library/Sounds/Glass.aiff"
          }
        ]
      }
    ]
  }
}
```

---

# 六、设置 AI 输出风格：匹配你当前的工作状态

输出风格决定Claude回答的详细程度和表达方式。运行 /config 选择，或直接告诉Claude：

```
Set my output style to Concise

```

三种内置风格：

- **▸ Explanatory（详解型）：**逐步拆解，适合学习新技术或理解复杂逻辑
- **▸ Concise（简洁型）：**直接给结果，适合快速推进项目
- **▸ Technical（技术型）：**精准使用专业术语，适合深度工程任务

还可以创建自定义风格文件放在 ~/.claude/output-styles/ 里，比如专门为代码评审定制的"严格挑毛病型"，或为写文档定制的"结构化全面型"，用 Markdown + YAML 前置元数据定义，自动出现在 /config 选项中。

两个额外的有用设置：showTurnDuration 显示每次响应耗时（帮你判断是否该换模型），prefersReducedMotion 关闭动画效果。

大部分工程师都会选：

```
Concise

```

因为 AI 的回答：**越短越高效。**

---

# 七、去掉"Co-authored-by"：保持 Git 历史纯净

这是一个非常实用的高级技巧，能让你完全掌控自己的 Git 提交历史。

**默认行为：**
当你使用 AI 助手帮你生成 commit message 时，它通常会自动在末尾添加一个"联合署名"信息，例如：`Co-authored-by: Claude Code <claude@anthropic.com>`。

**为什么你可能想去掉它？**
1.  **个人偏好**：你可能认为 AI 是一个"工具"而非"合作者"。
2.  **公司政策**：一些公司对 Git 提交历史有严格规范。
3.  **保持历史干净**：对于 AI 生成的琐碎修改，加上署名会显得冗余。

**如何操作：**
在你的 `~/.claude/settings.json` 文件里，添加 `"attribution"` 配置，并将其值设为空字符串：

```json
{
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
```

这样设置后，AI 就不会再自动添加联合署名了，让你的 Git log 保持纯净。

---

# 八、集成 Claude HUD：一个更美观的状态仪表盘

之前我们删除了手动编写"状态行"的章节，现在我们有了一个更强大、更美观的替代品：`Claude HUD`。这是一个社区开发的优秀插件，可以为你提供一个信息丰富的"平视显示器 (HUD)"，让你对 AI 的工作状态了如指掌。

### Claude HUD 有什么用？

它在你输入命令的下方，实时显示各种关键信息：

*   **上下文健康度 (Context health)**：用进度条清晰展示上下文窗口的使用情况，并用颜色预警。
*   **工具活动 (Tool activity)**：实时看到 Claude 正在读取、编辑或搜索哪些文件。
*   **Agent 追踪 (Agent tracking)**：监控子 Agent 的运行状态和任务。
*   **任务进度 (Todo progress)**：如果你使用了任务列表，这里会显示完成进度。
*   **环境信息**：当前项目路径、Git 分支状态、使用的模型等。

### 安装与设置

安装过程非常简单，完全在 Claude Code 内部通过命令完成：

**第一步：添加插件市场**
```
/plugin marketplace add jarrodwatts/claude-hud
```

**第二步：安装插件**
```
/plugin install claude-hud
```

**第三步：配置状态行**
这一步会自动帮你把 `claude-hud` 设置为你的状态行工具。
```
/claude-hud:setup
```

全部完成后，**彻底重启 Claude Code**，你就能看到全新的 HUD 了。

### 如何定制你的 HUD？

`claude-hud` 提供了从简单到复杂的多种配置方式。

1.  **简单配置 (推荐)**:
    直接运行配置命令，它会提供一个交互式的向导，让你轻松选择布局、开关各种显示元素。
    ```
    /claude-hud:configure
    ```

2.  **高级配置**:
    对于更精细的调整（如修改颜色、阈值等），你可以直接编辑它的配置文件：
    `~/.claude/plugins/claude-hud/config.json`

    下面是一个高级配置的示例，你可以参考它来定制自己的 `config.json`：
    ```json
    {
      "lineLayout": "expanded",
      "pathLevels": 2,
      "elementOrder": ["project", "tools", "context", "usage", "environment", "agents", "todos"],
      "gitStatus": {
        "enabled": true,
        "showDirty": true,
        "showAheadBehind": true,
        "showFileStats": true
      },
      "display": {
        "showTools": true,
        "showAgents": true,
        "showTodos": true,
        "showConfigCounts": true,
        "showDuration": true
      },
      "colors": {
        "context": "cyan",
        "usage": "cyan",
        "warning": "yellow",
        "usageWarning": "magenta",
        "critical": "red"
      }
    }
    ```

---

# 九、安装 Claude-Mem：赋予 AI 跨会话的长期记忆

默认情况下，AI 就像金鱼一样，每次开启新会话都会忘记之前的所有内容。`claude-mem` 这个插件解决了这个核心痛点，它能无缝地在多个会话之间保存上下文，让 Claude 拥有"长期记忆"。

### Claude-Mem 有什么用？

*   🧠 **持久化记忆**：关闭终端再打开，AI 依然记得你们上次聊的项目和代码。
*   🖥️ **Web 可视化界面**：通过 `http://localhost:37777` 可以实时看到 AI 的记忆流。
*   🔍 **强大的搜索能力**：提供了 `/mem-search` 技能，让你能用自然语言搜索过去的所有项目历史。
*   🔒 **隐私控制**：可以在代码或文本中使用 `<private>` 标签，被标记的内容将不会被记录到记忆中。
*   🤖 **全自动运行**：安装后，记忆的捕捉和注入都是自动的，无需手动干预。

### 安装与使用

安装和 `claude-hud` 一样简单：

**第一步：添加插件市场**
```
/plugin marketplace add thedotmack/claude-mem
```

**第二步：安装插件**
```
/plugin install claude-mem
```

安装完成后，**重启 Claude Code**。就这么简单！之后 `claude-mem` 就会在后台自动工作。当你开启一个新会话时，它会自动把相关的历史记忆注入到上下文里。

如果你想主动搜索记忆，可以使用 `/mem-search` 这个技能，或者访问 `http://localhost:37777` 这个地址来浏览和管理你的 AI 记忆。

---

# 十、配置 "代码简化" Agent：让 AI 自动优化你的代码

除了全局的 `CLAUDE.md` 规则外，Claude Code 还支持一个更强大的概念：**Agent**。你可以把它理解为为特定任务预先配置好的"专家人格"，它拥有更详细、更复杂的指令集。

`code-simplifier` 就是一个官方提供的、非常强大的专家 Agent，专门负责优化和重构代码。

### Code-Simplifier Agent 是做什么的？

它就像一位代码审查专家，在你（或者 AI）修改完代码后，它会自动介入，对**新修改的代码**进行分析和优化，目标是：
*   **保持功能不变**：只改变代码的写法，不改变其逻辑和行为。
*   **提升代码质量**：增强代码的可读性、一致性和可维护性。
*   **应用项目规范**：严格遵守 `CLAUDE.md` 中定义的项目级编码标准。
*   **追求清晰而非简短**：避免写出过于"聪明"但难以理解的代码。

简单来说，它就是你的**贴身代码质量管家**。

### 如何配置？

你需要把这个 Agent 的"人格定义"添加到你的 `~/.claude/settings.json` 文件中。

```json
{
  "agents": {
    "code-simplifier": {
      "description": "Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality.",
      "model": "opus",
      "prompt": "You are an expert code simplification specialist focused on enhancing code clarity, consistency, and maintainability while preserving exact functionality. Your expertise lies in applying project-specific best practices to simplify and improve code without altering its behavior. You prioritize readable, explicit code over overly compact solutions. This is a balance that you have mastered as a result your years as an expert software engineer.

You will analyze recently modified code and apply refinements that:

Preserve Functionality: Never change what the code does - only how it does it. All original features, outputs, and behaviors must remain intact.

Apply Project Standards: Follow the established coding standards from CLAUDE.md including:

Use ES modules with proper import sorting and extensions
Prefer function keyword over arrow functions
Use explicit return type annotations for top-level functions
Follow proper React component patterns with explicit Props types
Use proper error handling patterns (avoid try/catch when possible)
Maintain consistent naming conventions
Enhance Clarity: Simplify code structure by:

Reducing unnecessary complexity and nesting
Eliminating redundant code and abstractions
Improving readability through clear variable and function names
Consolidating related logic
Removing unnecessary comments that describe obvious code
IMPORTANT: Avoid nested ternary operators - prefer switch statements or if/else chains for multiple conditions
Choose clarity over brevity - explicit code is often better than overly compact code
Maintain Balance: Avoid over-simplification that could:

Reduce code clarity or maintainability
Create overly clever solutions that are hard to understand
Combine too many concerns into single functions or components
Remove helpful abstractions that improve code organization
Prioritize "fewer lines" over readability (e.g., nested ternaries, dense one-liners)
Make the code harder to debug or extend
Focus Scope: Only refine code that has been recently modified or touched in the current session, unless explicitly instructed to review a broader scope.

Your refinement process:

Identify the recently modified code sections
Analyze for opportunities to improve elegance and consistency
Apply project-specific best practices and coding standards
Ensure all functionality remains unchanged
Verify the refined code is simpler and more maintainable
Document only significant changes that affect understanding
You operate autonomously and proactively, refining code immediately after it's written or modified without requiring explicit requests. Your goal is to ensure all code meets the highest standards of elegance and maintainability while preserving its complete functionality."
    }
  }
}
```

*注意：你需要将上面的 `agents` 字段与 `settings.json` 中已有的其他配置（如 `hooks`）合并在一起，而不是直接覆盖。*

### 终极玩法：全自动"格式化 + 简化"流水线

最强大的地方在于，我们可以把这个 Agent 和我们之前设置的 `PostToolUse` 钩子结合起来，打造一个全自动的代码优化流水线。

修改你的 `.claude/settings.json` 中的 `hooks` 部分，让它在每次编辑文件后，**先调用格式化脚本，再调用代码简化 Agent**。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "./.claude/format-code.sh \"$CLAUDE_FILE_PATH\""
          },
          {
            "type": "agent",
            "agent": "code-simplifier"
          }
        ]
      }
    ]
  }
}
```

*(这里的 `"type": "agent"` 是一个示例，它代表了调用 Agent 的一种可能方式。具体的调用方式可能需要参考 Claude Code 的确切文档，但这展示了其强大的自动化潜力)*

**效果**：现在，每当 AI 修改了一个文件，它会：
1.  自动运行你的 `format-code.sh` 脚本，完成**语法层面**的格式化。
2.  紧接着，自动召唤 `code-simplifier` Agent，对刚刚修改的代码进行**逻辑和结构层面**的优化。

这套组合拳下来，AI 提交给你的，永远是既符合格式规范、又清晰可维护的"双优"代码。

---

# 从哪里开始？一个可执行的上手顺序

不用一次全部配完，按下面的分类和顺序来，每一步解决一个具体痛点：

### 核心体验优化
*   **1. 调整上下文压缩阈值**：防止 AI 在长对话中"失忆"。
*   **2. 安装 Claude HUD**：获得一个美观、实用的状态仪表盘。
*   **3. 设置任务完成提醒**：用桌面通知解放你的注意力，实现异步工作流。

### 高级工作流定制
*   **4. 定义 CLAUDE.md**：通过角色扮演、动态规则等方式，固化 AI 的行为模式。
*   **5. 配置自动格式化**：通过调度脚本，让 AI 生成的代码永远符合规范。
*   **6. 安装 Claude-Mem 插件**：赋予 AI 跨会话的长期记忆。
*   **7. 配置 Code-Simplifier Agent**：打造一个全自动的代码审查和优化流水线。

### 个性化调整
*   **8. 去掉 Git 署名**：让你的 Git 提交历史保持纯净。
*   **9. 自定义等待动词**：让等待过程变得更有趣。
*   **10. 设置输出风格**：让 AI 的回答方式更符合你的需求。

这些定制项覆盖的是你每天都会遇到的摩擦点。

大多数只需要告诉Claude你想要什么——它会帮你设置好。配置完成后，所有东西都在三个地方：Shell配置文件（别名）、~/.claude/settings.json（全局设置与钩子）、~/.claude/CLAUDE.md（个人指令）。

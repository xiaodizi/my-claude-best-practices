#!/bin/bash

# 自动格式化调度脚本 - 支持多种编程语言
# 使用方法: ./format-code.sh <file-path>

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

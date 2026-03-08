#!/bin/bash
# PostToolUse Hook: C# ファイル変更後にコンパイルチェックを促す
# 対象: Edit, Write, MultiEdit
# mcp-unity の recompile_scripts / get_console_logs をトリガーとして使う

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# C# ファイル以外は無視
[[ "$FILE_PATH" != *.cs ]] && exit 0

echo "C# file modified: $FILE_PATH"
echo "ACTION REQUIRED: MCP (mcp-unity) で recompile_scripts を実行し、get_console_logs でエラーを確認してください。"
exit 0
